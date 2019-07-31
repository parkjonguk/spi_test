//-----------------------------------------------------------------------------
// Title         : U Register For Modular Arithmetic
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : mod_arith_u.v
// Author        : Haeyoung Kim  <ryoung0327@gmail.com>
// Created       : 14.11.2018
// Last modified : 15.12.2018
//-----------------------------------------------------------------------------
// Description :
//  - U Register Module for ECC Modular Arithmetic Function
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 14.11.2018 : created by Haeyoung Kim
// 15.12.2018 : Code refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module mod_arith_u (/*AUTOARG*/
   // Outputs
   up, un,
   // Inputs
   clk, rst_n, u_op, u_en, ap, an, bp, bn, flg_mod, flg_mul, vp, vn
   ) ;
   /* I/O */
   input          clk, rst_n;

   input [1:0]    u_op;
   input          u_en;

   input [1:0]    ap;
   input [1:0]    an;

   input [1:0]    bp;
   input [1:0]    bn;

   input          flg_mod;
   input          flg_mul;

   input [255:0]  vp;
   input [255:0]  vn;

   output [255:0]  up;
   output [255:0]  un;

   /* Local Parameter */
   localparam OP_U_SETV     = 2'b00;
   localparam OP_U_MHLV     = 2'b01;
   localparam OP_U_MQRTR    = 2'b10;
   localparam OP_U_CLEAR    = 2'b11;

   localparam MQRTR_ADD     = 2'b00;

   localparam MP0 = 256'hFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF;
   localparam MP1 = 256'hFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551;

   genvar         i;

   /* Output Type Definition */
   wire [255:0]   up;
   wire [255:0]   un;

   reg [255:0]    r_up;
   reg [255:0]    r_un;

   assign up = r_up;
   assign un = r_un;

   /* Internal Register */
   reg [255:0]    r_up_nxt;
   reg [255:0]    r_un_nxt;

   /* Internal Function : MQRTR OP Selector*/
   wire [1:0]     mqrtr_op_div;
   wire [1:0]     mqrtr_op_mul;
   wire [1:0]     mqrtr_op;

   assign mqrtr_op_div = ap - an + bp - bn;
   assign mqrtr_op_mul = ap - an - 2'd1;
   assign mqrtr_op     = (flg_mul == 1'b1) ? mqrtr_op_mul : mqrtr_op_div;


   /* Internal Function : RSD ADDER0 X SELECTOR*/
   wire [255:0]   rsd0_xp, rsd0_xnn;
   assign rsd0_xp     =  r_up;
   assign rsd0_xnn    = ~r_un;

   /* Internal Function : RSD ADDER0 Y SELECTOR*/
   wire [255:0]   rsd0_yp, rsd0_ynn;
   assign rsd0_yp     = (mqrtr_op == MQRTR_ADD) ?  vp :  vn;
   assign rsd0_ynn    = (mqrtr_op == MQRTR_ADD) ? ~vn : ~vp;

   /* Internal Function : RSD ADDER0 ADDER Operation */
   wire [256:0]   rsd0_c;
   wire [255:0]   rsd0_s;
   wire [256:0]   rsd0_zp, rsd0_znn;
   assign rsd0_c[0] = 1;

   generate
      for(i = 0; i < 256; i = i+1) begin : rsd0_layer1
         assign {rsd0_c[i+1], rsd0_s[i]} = rsd0_xnn[i] + rsd0_ynn[i] + rsd0_xp[i];
      end
   endgenerate

   generate
      for(i = 0; i < 256; i = i+1) begin : rsd0_layer2
         assign {rsd0_zp[i+1], rsd0_znn[i]} = rsd0_c[i] + rsd0_s[i] + rsd0_yp[i];
      end
   endgenerate

   assign rsd0_znn[256]     = rsd0_c[256];
   assign rsd0_zp[0]        = 0;

   /* Internal Function : RSD ADDER1 X SELECTOR*/
   wire           flg_rsd1_u;
   wire [1:0]     bin_a;
   wire [256:0]   rsd1_xp, rsd1_xnn;

   assign flg_rsd1_u  = u_op[0] | (u_op[1] & (bin_a == 2'b00));
   assign bin_a       = ap - an;
   assign rsd1_xp     = (flg_rsd1_u == 1'b1) ?  {1'b0, r_up} : rsd0_zp;
   assign rsd1_xnn    = (flg_rsd1_u == 1'b1) ? ~{1'b0, r_un} : rsd0_znn;

   /* Internal Function : RSD ADDER1 M SELECTOR*/
   wire [1:0]     bin_u;
   wire           flg_rsd1_2m;
   wire [1:0]     selm_si;
   reg [256:0]    selm_do;

   assign bin_u          = rsd1_xp[1:0] - (~rsd1_xnn[1:0]);
   assign flg_rsd1_2m    = u_op[1] & !bin_u[0] &  bin_u[1];
   assign selm_si        = {flg_rsd1_2m, flg_mod};

   always @ (*) begin
      case (selm_si)
        2'b00: selm_do = {1'b0, MP0};
        2'b01: selm_do = {1'b0, MP1};
        2'b10: selm_do = {MP0, 1'b0};
        2'b11: selm_do = {MP1, 1'b0};
      endcase // case (sel1_si)
   end

   /* Internal Function : RSD ADDER1 Y SELECTOR*/
   wire           flg_rsd1_msub;
   wire           flg_rsd1_madd;
   wire [256:0]   rsd1_yp, rsd1_ynn;

   assign flg_rsd1_msub  = u_op[1] &  bin_u[0] & (bin_u[1] ^ flg_mod);
   assign flg_rsd1_madd  = flg_rsd1_2m | (u_op[0] &  bin_u[0]) | (u_op[1] &  bin_u[0] & (bin_u[1] ^ !flg_mod));
   assign rsd1_yp        = (flg_rsd1_madd == 1'b1) ? ( selm_do) : {267{1'b0}};
   assign rsd1_ynn       = (flg_rsd1_msub == 1'b1) ? (~selm_do) : {267{1'b1}};

   /* Internal Function : RSD ADDER1 ADDER Opeartion */
   wire [257:0]   rsd1_c;
   wire [256:0]   rsd1_s;
   wire [257:0]   rsd1_zp;
   wire [257:0]   rsd1_zn, rsd1_znn;

   assign rsd1_c[0] = 1;
   generate
      for(i = 0; i < 257; i = i+1) begin : rsd1_layer1
         assign {rsd1_c[i+1], rsd1_s[i]} = rsd1_xnn[i] + rsd1_ynn[i] + rsd1_xp[i];
      end
   endgenerate

   generate
      for(i = 0; i < 257; i = i+1) begin : rsd1_layer2
         assign {rsd1_zp[i+1], rsd1_znn[i]} = rsd1_c[i] + rsd1_s[i] + rsd1_yp[i];
      end
   endgenerate
   assign rsd1_zp[0]    = 0;
   assign rsd1_znn[257] = rsd1_c[257];
   assign rsd1_zn       = ~rsd1_znn;

   /* Internal Function : NEXT U REG SELECTOR */

   always @ (*) begin
      case (u_op)
        OP_U_SETV  : r_up_nxt = vp;
        OP_U_MHLV  : r_up_nxt = rsd1_zp[256:1];
        OP_U_MQRTR : r_up_nxt = rsd1_zp[257:2];
        OP_U_CLEAR : r_up_nxt = 256'd0;
      endcase // case (op)
   end

   always @ (*) begin
      case (u_op)
        OP_U_SETV  : r_un_nxt = vn;
        OP_U_MHLV  : r_un_nxt = rsd1_zn[256:1];
        OP_U_MQRTR : r_un_nxt = rsd1_zn[257:2];
        OP_U_CLEAR : r_un_nxt = 256'd0;
      endcase // case (op)
   end

   /* Internal Function : U Resgier */

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         r_up <= 256'd0;
         r_un <= 256'd0;
      end else begin
         if(u_en) begin
            r_up <= r_up_nxt;
            r_un <= r_un_nxt;
         end
      end
   end

endmodule // mod_arith_u
