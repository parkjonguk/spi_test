module ecc_core_rcv (/*AUTOARG*/
   // Outputs
   rcv_done,
   // Inputs
   clk, rst_n, wr_en, wr_size, load_rcv
   ) ;
   input           clk, rst_n;
   input           wr_en;
   input [15:0]    wr_size;

   input           load_rcv;
   output          rcv_done;

   reg [15:0]      size;
   wire            size_lst;
   wire [15:0]     size_sub;
   wire [15:0]     size_nxt;
   wire            rcv_done;

   assign size_lst = (size < 16'd5) ? 1 : 0;
   assign size_sub = size - 16'd4;
   assign size_nxt = size_lst ? 16'd0 : size_sub;
   assign rcv_done = (size == 16'd0) ? 1 : 0;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         size <= wr_size;
      end else begin
         if(load_rcv) begin
            size <= wr_size;
         end else if(wr_en) begin
            size <= size_nxt;
         end
      end
   end
endmodule // ecc_core_rcv
