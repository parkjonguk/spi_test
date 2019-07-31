module rcv_ctrl (/*AUTOARG*/
   // Outputs
   rcv_last, rcv_done, rcv_size,
   // Inputs
   clk, rst_n, wr_size, cmd_extend, rcv_wr_d, rcv_bc_d, rcv_clr, rcv_nxt0,
   rcv_nxt1, rcv_nxtk
   ) ;
   // System Input
   input           clk, rst_n;

   input  [15:0]   wr_size;
   input  [15:0]   cmd_extend;

   input           rcv_wr_d;
   input           rcv_bc_d;
   input           rcv_clr;

   input           rcv_nxt0;
   input           rcv_nxt1;
   input           rcv_nxtk;

   output          rcv_last;
   output          rcv_done;
   output [15:0]   rcv_size;


   reg  [15:0]     rcv_size;

   wire [15:0]     rcv_size_sub;
   wire [15:0]     rcv_size_nxt;
   wire            rcv_done;
   wire            rcv_last;

   wire            rcv_en;

   assign rcv_size_sub = rcv_size - 16'd4;
   assign rcv_size_nxt = rcv_last ? 16'd0 : rcv_size_sub;
   assign rcv_last     = (rcv_size <  16'd5) ? 1 : 0;
   assign rcv_done     = (rcv_size == 16'd0) ? 1 : 0;

   assign rcv_en       = rcv_nxt0 | rcv_nxt1 | rcv_nxtk;


   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         rcv_size <= 16'd0;
      end else begin
         if(rcv_clr) begin
            rcv_size <= 16'd0;
         end else if(rcv_wr_d) begin
            rcv_size <= wr_size;
         end else if(rcv_bc_d) begin
            rcv_size <= cmd_extend;
         end else if(rcv_en) begin
            rcv_size <= rcv_size_nxt;
         end
      end
   end
endmodule // rcv_ctrl
