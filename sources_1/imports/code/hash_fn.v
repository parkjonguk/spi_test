`define IDX64(x) 64*(x+1)-1:64*(x)
module hash_fn (/*AUTOARG*/
   // Outputs
   hash_o,
   // Inputs
   clk, rst_n, fn_op, fn_en, h_flg_384, kw_vld, kw_done, kw_flg0, kw, hash_f,
   hash_i
   ) ;
   // System Input
   input          clk, rst_n;
   // CU
   input [1:0]    fn_op;
   input          fn_en;
   // FLAG
   input          h_flg_384;
   // W
   input          kw_vld;
   input          kw_done;
   input          kw_flg0;
   input  [63:0]  kw;
   // HASH
   input  [511:0] hash_f;
   input  [511:0] hash_i;

   output [511:0] hash_o;

   reg [511:0]    hash_o;

   wire [63:0]    a, b, c, d, e, f, g, h;
   assign a = hash_o[`IDX64(7)];
   assign b = hash_o[`IDX64(6)];
   assign c = hash_o[`IDX64(5)];
   assign d = hash_o[`IDX64(4)];
   assign e = hash_o[`IDX64(3)];
   assign f = hash_o[`IDX64(2)];
   assign g = hash_o[`IDX64(1)];
   assign h = hash_o[`IDX64(0)];


   /* A Sum */
   wire [63:0]    a_sum;
   wire [63:0]    a_ror2,  a_ror13, a_ror22; // 256
   wire [63:0]    a_ror28, a_ror34, a_ror39; // 384

	 assign a_ror2  = {b[33:32], b[63:34], 32'd0};
	 assign a_ror13 = {b[44:32], b[63:45], 32'd0};
	 assign a_ror22 = {b[53:32], b[63:54], 32'd0};
	 assign a_ror28 = {b[27:0], b[63:28]};
	 assign a_ror34 = {b[33:0], b[63:34]};
	 assign a_ror39 = {b[38:0], b[63:39]};
   assign a_sum   = h_flg_384 ? (a_ror28 ^ a_ror34 ^ a_ror39) : (a_ror2 ^ a_ror13 ^ a_ror22);

   // MAJ
   wire [63:0]      a_and_b, a_and_c, b_and_c, maj;
	 assign a_and_b = b & c;
	 assign a_and_c = b & d;
	 assign b_and_c = c & d;
	 assign maj     = a_and_b ^ a_and_c ^ b_and_c;

   // MAJ_A
   wire [63:0]    temp0;
   wire [63:0]    maj_a;
   assign temp0 = maj + a_sum;
   assign maj_a = kw_flg0 ? 63'd0 : temp0;

   //e_sum;
   wire [63:0]    e_sum;
   wire [63:0]    e_ror6,  e_ror11, e_ror25;
   wire [63:0]    e_ror14, e_ror18, e_ror41;

	 assign e_ror6  = {f[37:32],f[63:38],32'd0};
	 assign e_ror11 = {f[42:32],f[63:43],32'd0};
	 assign e_ror25 = {f[56:32],f[63:57],32'd0};
	 assign e_ror14 = {f[13:0],f[63:14]};
	 assign e_ror18 = {f[17:0],f[63:18]};
	 assign e_ror41 = {f[40:0],f[63:41]};
	 assign e_sum   = h_flg_384 ? (e_ror14 ^ e_ror18 ^ e_ror41) : (e_ror6 ^ e_ror11 ^ e_ror25);


   //Ch
   wire [63:0]    e_and_f, ne_and_g, ch;
   assign e_and_f  =   f  & g;
   assign ne_and_g = (~f) & h;
   assign ch       = e_and_f ^ ne_and_g;

   wire [63:0]    temp1;
   wire [63:0]    ch_e;
   assign temp1 = ch + e_sum;
   assign ch_e  = kw_flg0 ? 63'd0 : temp1;

   //Next A
   wire [63:0]    a_nxt, b_nxt, e_nxt, f_nxt;
   assign a_nxt = h + kw;
   assign b_nxt = a + maj_a + ch_e;
   assign e_nxt = kw_done ? d : d + a_nxt;
   assign f_nxt = e + ch_e;

   wire [511:0] hr;
   assign hr    = {a_nxt, b_nxt, b, c, e_nxt, f_nxt, f, g};

   /* HASH Function Input Value */
   // HASH INIT VALUE
   localparam H256_H = 256'h6a09e66700000000bb67ae85000000003c6ef37200000000a54ff53a00000000;
   localparam H256_L = 256'h510e527f000000009b05688c000000001f83d9ab000000005be0cd1900000000;
   localparam H384_H = 256'hcbbb9d5dc1059ed8629a292a367cd5079159015a3070dd17152fecd8f70e5939;
   localparam H384_L = 256'h67332667ffc00b318eb44a8768581511db0c2e0d64f98fa747b5481dbefa4fa4;
   wire [511:0]   h0;
   assign  h0    = h_flg_384 ? {H384_H, H384_L} : {H256_H, H256_L};

   // HASH Final Temp Value
   wire [511:0]   hk;
   wire [63:0]    hk7, hk6, hk5, hk4, hk3, hk2, hk1, hk0;
   assign hk7 = hash_f[`IDX64(7)] + hash_o[`IDX64(6)];
   assign hk6 = hash_f[`IDX64(6)] + hash_o[`IDX64(5)];
   assign hk5 = hash_f[`IDX64(5)] + hash_o[`IDX64(4)];
   assign hk4 = hash_f[`IDX64(4)] + hash_o[`IDX64(3)];
   assign hk3 = hash_f[`IDX64(3)] + hash_o[`IDX64(2)];
   assign hk2 = hash_f[`IDX64(2)] + hash_o[`IDX64(1)];
   assign hk1 = hash_f[`IDX64(1)] + hash_o[`IDX64(0)];
   assign hk0 = hash_f[`IDX64(0)] + hash_o[`IDX64(7)];
   assign hk  = {hk7,hk6,hk5,hk4,hk3,hk2,hk1,hk0};

   /* Hash Register */
   // Selector
   reg   [511:0] o_nxt;
   always @ (*) begin
      case (fn_op)
        2'b00 : o_nxt = hash_i;
        2'b01 : o_nxt = h0;
        2'b10 : o_nxt = hk;
        2'b11 : o_nxt = 512'd0;
      endcase // case (fn_op)
   end

   // Register
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         hash_o <= 512'd0;
      end else begin
         if(fn_en) begin
            hash_o <= o_nxt;
         end else if(kw_vld) begin
            hash_o <= hr;
         end
      end
   end

endmodule // hash_fn
