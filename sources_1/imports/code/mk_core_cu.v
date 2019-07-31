module mk_core_cu (/*AUTOARG*/
   // Outputs
   cmd_rdy, ss_clr, ss_set, wr_open, rd_open, resp_done, resp_err,
   // Inputs
   clk, rst_n, clr_mk, cmd_en, cmd_op, cmd_extend, l3_id, ssid, ssid_vld,
   wr_size, wr_addr, wr_en
   ) ;
   input           clk, rst_n;
   input           clr_mk;
   // L3 Communication
   output          cmd_rdy;
   input           cmd_en;
   input [7:3]     cmd_op;
   input [15:0]    cmd_extend;

   input [2:0]     l3_id;
   input [2:0]     ssid;
   input           ssid_vld;
   output          ss_clr;
   output          ss_set;

   input [15:0]    wr_size;
   input [13:0]    wr_addr;
   input           wr_en;
   output          wr_open;
   output          rd_open;

   output          resp_done;
   output [1:0]    resp_err;

   reg             cmd_rdy;
   reg             wr_open;
   reg             rd_open;
   reg             ss_clr;
   reg             ss_set;
   reg [1:0]       resp_err;
   reg             resp_done;

   // MK Clear
   localparam ERR_CMD      = 2'b01;
   localparam ERR_SIZE     = 2'b10;
   localparam ERR_PRM      = 2'b11;

   localparam IDLE          = 10'b0000000001;
   localparam RD_KEY        = 10'b0000000010;
   localparam WR_KEY        = 10'b0000000100;
   localparam WR_WAIT       = 10'b0000001000;
   localparam SS_SETUP      = 10'b0000010000;
   localparam SS_CLEAR      = 10'b0000100000;
   localparam DONE          = 10'b0001000000;
   localparam RESP_ERR_CMD  = 10'b0010000000;
   localparam RESP_ERR_SIZE = 10'b0100000000;
   localparam RESP_ERR_PRM  = 10'b1000000000;

   reg [9:0]       state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(clr_mk) begin
            state <= IDLE;
         end else begin
            state <= state_nxt;
         end
      end
   end

   always @ (*) begin
      state_nxt   = state;
      cmd_rdy     = 0;
      ss_set      = 0;
      ss_clr      = 0;
      wr_open     = 0;
      rd_open     = 0;
      resp_err    = 2'b00;
      resp_done   = 0;
      case (state)
        IDLE : begin
           cmd_rdy     = 1;
           if(cmd_en) begin
              if(cmd_op[7:4] == 4'b1000) begin
                 state_nxt = RD_KEY;
              end else if (cmd_op[7:4] == 4'b0100) begin
                 state_nxt = WR_KEY;
              end else if (cmd_op[7:4] == 4'b0011) begin
                 state_nxt = SS_SETUP;
              end else if (cmd_op[7:4] == 4'b0010) begin
                 state_nxt = SS_CLEAR;
              end else begin
                 state_nxt = RESP_ERR_CMD;
              end
           end
        end
        RD_KEY : begin
           if((wr_size != 16'd0) | (cmd_extend != 16'd32)) begin
              state_nxt = RESP_ERR_SIZE;
           end else begin
              rd_open = 1;
              state_nxt = DONE;
           end
        end
        WR_KEY : begin
           if((wr_size != 16'd32) | (cmd_extend != 16'd0)) begin
              state_nxt = RESP_ERR_SIZE;
           end else begin
              wr_open = 1;
              state_nxt = WR_WAIT;
           end
        end
        WR_WAIT : begin
           if(wr_en & (wr_addr == 14'd7)) begin
              state_nxt = DONE;
           end
        end
        SS_SETUP : begin
           if((wr_size != 16'd0) | (cmd_extend != 16'd0)) begin
              state_nxt = RESP_ERR_SIZE;
           end else if(ssid_vld | cmd_op[3])begin
              state_nxt = RESP_ERR_PRM;
           end else begin
              ss_set    = 1;
              state_nxt = DONE;
           end
        end
        SS_CLEAR : begin
           if((wr_size != 16'd0) | (cmd_extend != 16'd0)) begin
              state_nxt = RESP_ERR_SIZE;
           end else if(!ssid_vld) begin
              state_nxt = DONE;
              ss_clr    = 1;
           end else if(cmd_op[3] | (ssid[2:0] != l3_id[2:0]))begin
              state_nxt = RESP_ERR_PRM;
           end else begin
              ss_clr    = 1;
              state_nxt = DONE;
           end
        end
        DONE : begin
           state_nxt = IDLE;
           resp_done = 1;
        end
        RESP_ERR_CMD : begin
           state_nxt = IDLE;
           resp_done = 1;
           resp_err  = ERR_CMD;
        end
        RESP_ERR_PRM : begin
           state_nxt = IDLE;
           resp_done = 1;
           resp_err  = ERR_PRM;
        end
        RESP_ERR_SIZE : begin
           state_nxt = IDLE;
           resp_done = 1;
           resp_err  = ERR_SIZE;
        end
      endcase // case (state)
   end

endmodule // mk_core_cu
