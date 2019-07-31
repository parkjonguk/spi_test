`define IDX32(x) 32*(x+1)-1:32*(x)
module hash_lst (/*AUTOARG*/
   // Outputs
   hash_f,
   // Inputs
   clk, rst_n, h_flg_384, h_clr, lst_op, lst_en, hash_i, hash_o
   ) ;
   // System Input
   input          clk, rst_n;
   // CU
   input          h_flg_384;
   input          h_clr;

   input [1:0]    lst_op; // H0,HK,RES,CLR
   input          lst_en;

   input [511:0]  hash_i;
   input [511:0]  hash_o;

   output [511:0] hash_f;

   reg [511:0]    hash_f;

   localparam H256_H = 256'h6a09e66700000000bb67ae85000000003c6ef37200000000a54ff53a00000000;
   localparam H256_L = 256'h510e527f000000009b05688c000000001f83d9ab000000005be0cd1900000000;
   localparam H384_H = 256'hcbbb9d5dc1059ed8629a292a367cd5079159015a3070dd17152fecd8f70e5939;
   localparam H384_L = 256'h67332667ffc00b318eb44a8768581511db0c2e0d64f98fa747b5481dbefa4fa4;

   wire [511:0]   h0, hf;
   wire [127:0]   t0, t1;
   assign  h0    = h_flg_384 ? {H384_H, H384_L} : {H256_H, H256_L};
   assign  hf    = h_flg_384 ? {hash_o[511:128], 128'd0} : {t0, t1, 256'd0};
   assign  t0    = {hash_o[`IDX32(15)], hash_o[`IDX32(13)], hash_o[`IDX32(11)], hash_o[`IDX32(9)]};
   assign  t1    = {hash_o[`IDX32( 7)], hash_o[`IDX32( 5)], hash_o[`IDX32( 3)], hash_o[`IDX32(1)]};

   reg [511:0]    f_nxt;
   always @ (*) begin
      case (lst_op)
        2'b00 : f_nxt = hash_i;
        2'b01 : f_nxt = h0;
        2'b10 : f_nxt = hf;
        2'b11 : f_nxt = hash_o;
      endcase // case (lst_op)
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         hash_f <= 512'd0;
      end else begin
         if(h_clr) begin
            hash_f <= 512'd0;
         end else if(lst_en) begin
            hash_f <= f_nxt;
         end
      end
   end
endmodule // hash_lst
