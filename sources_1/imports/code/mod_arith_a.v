//-----------------------------------------------------------------------------
// Title         : A Register For Modular Arithmetic
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : mod_arith_a.v
// Author        : Haeyoung Kim  <ryoung0327@gmail.com>
// Created       : 17.11.2018
// Last modified : 15.12.2018
//-----------------------------------------------------------------------------
// Description :
//  - A Register For Modular Arithmetic
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 17.11.2018 : created by Haeyoung Kim
// 15.12.2018 : Code refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module mod_arith_a (/*AUTOARG*/
   // Outputs
   ap, an, ap_nxt, an_nxt, flg_povf, flg_novf,
   // Inputs
   clk, rst_n, a_op, opt_adsb, a_en, a_clr, flg_mul, opt_acca, bp, bn, xp, xn
   ) ;
   input          clk, rst_n;

   input [1:0]    a_op;
   input [1:0]    opt_adsb;
   input          a_en;
   input          a_clr;

   input          flg_mul;
   input          opt_acca;

   input [255:0]  bp, bn;
   input [255:0]  xp, xn;

   output [255:0] ap, an;
   output [1:0]   ap_nxt, an_nxt;
   output         flg_povf;
   output         flg_novf;

   localparam OP_A_SETX   = 2'b00;
   localparam OP_A_MHLV   = 2'b01;
   localparam OP_A_MQRTR  = 2'b10;
   localparam OP_A_ADSB   = 2'b11;

   /* Output Type */
   wire [255:0]   ap, an;
   wire [1:0]     ap_nxt, an_nxt;
   wire           flg_povf;
   wire           flg_novf;

   /* Internal Register */
   reg [256:0]    r_ap, r_an;
   reg [256:0]    r_ap_nxt, r_an_nxt;

   assign     ap = r_ap[255:0];
   assign     an = r_an[255:0];
   assign ap_nxt = r_ap_nxt[1:0];
   assign an_nxt = r_an_nxt[1:0];

   /* Function : Accumulation Mode Selector */
   wire [255:0]      sel_xp, sel_xn;

   assign   sel_xp = opt_acca ? bp : xp;
   assign   sel_xn = opt_acca ? bn : xn;

   /* Function : FLG_SUB SETUP */
   wire [1:0]        add_ab;
   wire              mqrtr_sub;
   wire              flg_sub_a;
   wire              flg_sub_b0;
   wire              flg_sub_b1;
   wire              flg_sub_b;

   assign add_ab         = r_ap[1:0] - r_an[1:0] + bp[1:0] - bn[1:0];
   assign mqrtr_sub      = |add_ab;
   assign flg_sub_a      = ( a_op == OP_A_ADSB ) ? opt_adsb[1]  : 0;

   assign flg_sub_b0     = ( a_op == OP_A_MQRTR) ? mqrtr_sub : 0;
   assign flg_sub_b1     = ( a_op == OP_A_ADSB ) ? opt_adsb[0]  : 0;
   assign flg_sub_b      = flg_sub_b0 | flg_sub_b1;

   /* Function : Select RSD Input */
   wire [256:0]      rsd0_xp;
   wire [256:0]      rsd0_xnn;
   wire [255:0]      sel_bp;
   wire [255:0]      sel_bn;
   wire [256:0]      rsd0_yp;
   wire [256:0]      rsd0_ynn;

   assign rsd0_xp        = flg_sub_a ?  r_an :  r_ap;
   assign rsd0_xnn       = flg_sub_a ? ~r_ap : ~r_an;
   assign sel_bp         = flg_sub_b ?  bn :  bp;
   assign sel_bn         = flg_sub_b ?  bp :  bn;
   assign rsd0_yp        = flg_mul ?   257'd0 :  {1'b0, sel_bp};
   assign rsd0_ynn       = flg_mul ? ~(257'd1): ~{1'b0, sel_bn};

   /* Function : RSD Adder */

   wire [257:0]   rsd0_c;
   wire [256:0]   rsd0_s;

   wire [257:0]   rsd0_zp, rsd0_znn, rsd0_zn;

   // RSD ADDER 0 LAYER1
   genvar         i;
   assign rsd0_c[0] = 1;
   generate
      for(i = 0; i < 257; i = i+1) begin : rsd0_layer1
         assign {rsd0_c[i+1], rsd0_s[i]} = rsd0_xnn[i] + rsd0_ynn[i] + rsd0_xp[i];
      end
   endgenerate

   // RSD ADDER 0 LAYER2
   generate
      for(i = 0; i < 257; i = i+1) begin : rsd0_layer2
         assign {rsd0_zp[i+1], rsd0_znn[i]} = rsd0_c[i] + rsd0_s[i] + rsd0_yp[i];
      end
   endgenerate
   assign rsd0_znn[257]    = rsd0_c[257];
   assign rsd0_zp[0]       = 0;
   assign rsd0_zn          = ~rsd0_znn;


   /* Internal Function 3 : SELECT MQRTR INPUT*/
   wire   [1:0]   bin_a;
   wire   [255:0] mqrtr_ap, mqrtr_an;
   wire [1:0]     p_sub_n;
   wire [1:0]     n_sub_p;
   wire [256:0]   madd_zp, madd_zn;

   assign      bin_a = r_ap[1:0] - r_an[1:0];
   assign   mqrtr_ap = (bin_a[1:0] == 2'b00) ? {2'b00, r_ap[255:2]} : {1'b0, rsd0_zp[256:2]};
   assign   mqrtr_an = (bin_a[1:0] == 2'b00) ? {2'b00, r_an[255:2]} : {1'b0, rsd0_zn[256:2]};
   assign    p_sub_n = rsd0_zp[257:255] - rsd0_zn[257:255];
   assign    n_sub_p = rsd0_zn[257:255] - rsd0_zp[257:255];
   assign    madd_zp = (rsd0_zp[257:255] > rsd0_zn[257:255]) ? {p_sub_n, rsd0_zp[254:0]} : {2'b00, rsd0_zp[254:0]};
   assign    madd_zn = (rsd0_zp[257:255] > rsd0_zn[257:255]) ? {2'b00, rsd0_zn[254:0]} : {n_sub_p, rsd0_zn[254:0]};

   assign flg_povf = madd_zp[256];
   assign flg_novf = madd_zn[256];

   always @ (*) begin
      case ( a_op)
        OP_A_SETX  : r_ap_nxt = {1'b0, sel_xp};
        OP_A_MHLV  : r_ap_nxt = {2'b00, r_ap[255:1]};
        OP_A_MQRTR : r_ap_nxt = {1'b0, mqrtr_ap};
        OP_A_ADSB  : r_ap_nxt = madd_zp;
      endcase // case (b_op)
   end

   always @ (*) begin
      case ( a_op)
        OP_A_SETX  : r_an_nxt = {1'b0, sel_xn};
        OP_A_MHLV  : r_an_nxt = {2'b00, r_an[255:1]};
        OP_A_MQRTR : r_an_nxt = {1'b0, mqrtr_an};
        OP_A_ADSB  : r_an_nxt = madd_zn;
      endcase // case (b_op)
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         r_ap <= 257'd0;
         r_an <= 257'd0;
      end else begin
         if( a_clr) begin
            r_ap <= 257'd0;
            r_an <= 257'd0;
         end else if ( a_en) begin
            r_ap <= r_ap_nxt;
            r_an <= r_an_nxt;
         end
      end
   end

endmodule // mod_arith_a
