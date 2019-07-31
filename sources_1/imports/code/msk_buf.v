module msk_buf (/*AUTOARG*/
   // Outputs
   msk,
   // Inputs
   clk, rst_n, msk_clr, msk_en0, msk_en1, hash_f
   ) ;
   // System Input
   input           clk, rst_n;
   // CU
   input           msk_clr;
   input           msk_en0;
   input           msk_en1;
   input [511:128] hash_f;
   output [383:0]  msk;

   reg [383:0]     msk;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         msk <= 384'd0;
      end else begin
         if(msk_clr) begin
            msk <= 384'd0;
         end else if(msk_en0) begin
            msk <= hash_f[511:128];
         end else if(msk_en1) begin
            msk <= {msk[383:128], hash_f[511:384]};
         end
      end
   end


endmodule // msk_buf
