module ssk_core_cu (/*AUTOARG*/
   // Outputs
   cmd_rdy, wr_open, rd_open, resp_done, resp_err,
   // Inputs
   clk, rst_n, clr_ssk, ss_expire, cmd_en, cmd_op, cmd_extend, wr_size, wr_en
   ) ;
   input           clk, rst_n;
   input           clr_ssk;
   input           ss_expire;
   // L3 Communication
   output          cmd_rdy;
   input           cmd_en;
   input [7:0]     cmd_op;
   input [15:0]    cmd_extend;
   input [15:0]    wr_size;
   input           wr_en;

   output          wr_open;
   output          rd_open;

   output          resp_done;
   output [1:0]    resp_err;

   reg             cmd_rdy;
   reg             wr_open;
   reg             rd_open;
   reg [1:0]       resp_err;
   reg             resp_done;
   reg             rcv_start;


   localparam ERR_CMD      = 2'b01;
   localparam ERR_SIZE     = 2'b10;
   localparam ERR_PRM      = 2'b11;

   localparam IDLE          = 8'b00000001;
   localparam RD_KEY        = 8'b00000010;
   localparam WR_KEY        = 8'b00000100;
   localparam WR_WAIT       = 8'b00001000;
   localparam DONE          = 8'b00010000;
   localparam RESP_ERR_CMD  = 8'b00100000;
   localparam RESP_ERR_SIZE = 8'b01000000;
   localparam RESP_ERR_PRM  = 8'b10000000;

   wire            rcv_lst;
   wire [15:0]     size_sub;
   wire [15:0]     size_nxt;
   reg [15:0]      size;
   wire            rcv_done;

   assign rcv_done = (size == 16'd0) ? 1 : 0;
   assign size_sub  = size - 16'd4;
   assign size_lst  = (size < 16'd5) ? 1 : 0;
   assign size_nxt  = size_lst ? 16'd0 : size_sub;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         size <= 16'd0;
      end else begin
         if(rcv_start) begin
            size <= wr_size;
         end else if(wr_en) begin
            size <= size_nxt;
         end
      end
   end







   reg [7:0]       state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(clr_ssk | ss_expire) begin
            state <= IDLE;
         end else begin
            state <= state_nxt;
         end
      end
   end

   always @ (*) begin
      state_nxt   = state;
      cmd_rdy     = 0;
      wr_open     = 0;
      rd_open     = 0;
      resp_err    = 2'b00;
      resp_done   = 0;
      rcv_start   = 0;
      case (state)
        IDLE : begin
           cmd_rdy     = 1;
           if(cmd_en) begin
              if((cmd_op[7:4] == 4'd0) & (cmd_op[3:0] > 4'd1)) begin
                 state_nxt = RD_KEY;
              end else if((cmd_op[7:4] == 4'd1) & (cmd_op[3:0] > 4'd1)) begin
                 state_nxt = WR_KEY;
              end else begin
                 state_nxt = RESP_ERR_CMD;
              end
           end
        end
        RD_KEY : begin
           if(wr_size != 16'd0) begin
              state_nxt = RESP_ERR_SIZE;
           end else if(cmd_extend > {9'd0, cmd_op[3:1], 4'd0}) begin
              state_nxt = RESP_ERR_SIZE;
           end else begin
              rd_open   = 1;
              state_nxt = IDLE;
           end
        end
        WR_KEY : begin
           if(cmd_extend != 16'd0) begin
              state_nxt = RESP_ERR_SIZE;
           end else if(wr_size > {9'd0, cmd_op[3:1], 4'd0}) begin
              state_nxt = RESP_ERR_SIZE;
           end else begin
              wr_open   = 1;
              rcv_start = 1;
              state_nxt = WR_WAIT;
           end
        end
        WR_WAIT : begin
           if(rcv_done) begin
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
endmodule // ssk_core_cu
