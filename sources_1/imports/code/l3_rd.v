module l3_rd (/*AUTOARG*/
   // Outputs
   core_rd_vld, core_rd, rd_addr, rd_en,
   // Inputs
   clk, rst_n, clr_core, cmd_en, cmd_extend, rd_open, l3_rd_rdy, rd_d
   ) ;
   input           clk, rst_n;
   input           clr_core;
   input           cmd_en;
   input  [15:0]   cmd_extend;
   input           rd_open;

   input           l3_rd_rdy;
   output          core_rd_vld;
   output [31:0]   core_rd;

   input  [31:0]   rd_d;
   output [13:0]   rd_addr;
   output          rd_en;   // For FIFO Control

   reg             core_rd_vld;
   reg             rd_en;
   reg [31:0]      core_rd;
   reg             nxt_data;
   wire [13:0]     rd_addr;

   reg             i_clr;
   reg  [15:0]     cntr;
   wire [15:0]     cntr_nxt;
   wire            run;
   assign cntr_nxt = cntr + 16'd4;
   assign run      = (cmd_extend > cntr) ? 1'b1 : 1'b0;
   assign rd_addr  = cntr[15:2];

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         cntr <= 16'd0;
      end else begin
         if(clr_core | rd_open | i_clr) begin
            cntr <= 16'd0;
         end else if(nxt_data) begin
            cntr <= cntr_nxt;
         end
      end
   end


   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         core_rd <= 32'd0;
      end else begin
         if(i_clr | clr_core | cmd_en) begin
            core_rd <= 32'd0;
         end else if(nxt_data) begin
            core_rd <= rd_d;
         end
      end
   end


   localparam IDLE     = 4'b0001;
   localparam RD_DATA  = 4'b0010;
   localparam TX_DATA  = 4'b0100;
   localparam CLEAR    = 4'b1000;

   reg [3:0]       state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(clr_core | cmd_en) begin
            state <= IDLE;
         end else begin
            state <= state_nxt;
         end
      end
   end

   always @ (*) begin
      state_nxt    = state;
      core_rd_vld  = 0;
      rd_en        = 0;
      i_clr        = 0;
      nxt_data     = 0;
      case (state)
        IDLE    : begin
           if(rd_open) begin
              state_nxt = RD_DATA;
              rd_en      = 1;
           end
        end
        RD_DATA  : begin
           state_nxt  = TX_DATA;
           nxt_data   = 1;
        end
        TX_DATA  : begin
           core_rd_vld  = 1;
           if(l3_rd_rdy)begin
              if(!run) begin
                 state_nxt = CLEAR;
              end else begin
                 state_nxt = RD_DATA;
                 rd_en      = 1;
              end
           end
        end
        CLEAR    : begin
           i_clr      = 1;
           state_nxt  = IDLE;
        end
      endcase // case (state)
   end

endmodule // l3_rd
