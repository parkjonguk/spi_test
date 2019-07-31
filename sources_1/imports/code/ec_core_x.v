//-----------------------------------------------------------------------------
// Title         : EC Core X Register
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : ec_core_x.v
// Author        : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 21.12.2018
// Last modified : 25.12.2018
//-----------------------------------------------------------------------------
// Description :
// EC Core X Register For EC Operation
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 21.12.2018 : created by Haeyoung Kim
// 23.12.2018 : Spyglass Check by Haeyoung Kim
// 25.12.2018 : Function Verification Done and Code Refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module ec_core_x (/*AUTOARG*/
   // Outputs
   ma_xp, ma_xn,
   // Inputs
   clk, rst_n, x_op, x_en, x_clr, x, ecp1_xp, ecp1_xn, ecp2_x, ecp1_yp, ecp1_yn,
   ecp2_y, ma_zp, ma_zn, ma_prev_zp, ma_prev_zn
   ) ;
   input          clk, rst_n;
   input [2:0]    x_op;
   input          x_en;
   input          x_clr;

   input [255:0]  x;

   input [255:0]  ecp1_xp, ecp1_xn;
   input [255:0]  ecp2_x;

   input [255:0]  ecp1_yp, ecp1_yn;
   input [255:0]  ecp2_y;

   input [255:0]  ma_zp, ma_zn;
   input [255:0]  ma_prev_zp, ma_prev_zn;

   output [255:0] ma_xp, ma_xn;

   /* Output Type */
   reg   [255:0] ma_xp, ma_xn;
   reg   [255:0] ma_xp_nxt, ma_xn_nxt;

   localparam SIG_MONT      = 256'h6e12d9553d9561fc845b2392b6bec595fc2db9b2b149434a7bea08c9fd4c0a3a;

   /* Operation Code */
   localparam X_SET_X       = 3'b000;
   localparam X_SET_SM      = 3'b001;
   localparam X_SET_ECP2X   = 3'b010;
   localparam X_SET_ECP2Y   = 3'b011;
   localparam X_SET_ECP1X   = 3'b100;
   localparam X_SET_ECP1Y   = 3'b101;
   localparam X_SET_CZ      = 3'b110;
   localparam X_SET_PZ      = 3'b111;

   always @ ( * ) begin
      case (x_op)
        X_SET_X     : ma_xp_nxt = x;
        X_SET_SM    : ma_xp_nxt = SIG_MONT;
        X_SET_ECP2X : ma_xp_nxt = ecp2_x;
        X_SET_ECP2Y : ma_xp_nxt = ecp2_y;
        X_SET_ECP1X : ma_xp_nxt = ecp1_xp;
        X_SET_ECP1Y : ma_xp_nxt = ecp1_yp;
        X_SET_CZ    : ma_xp_nxt = ma_zp;
        X_SET_PZ    : ma_xp_nxt = ma_prev_zp;
      endcase // case (x_op)
   end

   always @ ( * ) begin
      case (x_op)
        X_SET_X     : ma_xn_nxt = 256'd0;
        X_SET_SM    : ma_xn_nxt = 256'd0;
        X_SET_ECP2X : ma_xn_nxt = 256'd0;
        X_SET_ECP2Y : ma_xn_nxt = 256'd0;
        X_SET_ECP1X : ma_xn_nxt = ecp1_xn;
        X_SET_ECP1Y : ma_xn_nxt = ecp1_yn;
        X_SET_CZ    : ma_xn_nxt = ma_zn;
        X_SET_PZ    : ma_xn_nxt = ma_prev_zn;
      endcase // case (x_op)
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         ma_xp <= 256'd0;
         ma_xn <= 256'd0;
      end else begin
         if(x_clr) begin
            ma_xp <= 256'd0;
            ma_xn <= 256'd0;
         end else if (x_en) begin
            ma_xp <= ma_xp_nxt;
            ma_xn <= ma_xn_nxt;
         end
      end
   end

endmodule // ec_core_x

