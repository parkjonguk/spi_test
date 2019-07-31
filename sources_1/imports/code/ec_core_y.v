//-----------------------------------------------------------------------------
// Title         : EC Core Y Register
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : ec_core_y.v
// Author        : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 21.12.2018
// Last modified : 25.12.2018
//-----------------------------------------------------------------------------
// Description :
// EC Core Y Register For EC Operation
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
module ec_core_y (/*AUTOARG*/
   // Outputs
   ma_yp, ma_yn,
   // Inputs
   clk, rst_n, y_op, y_en, y_clr, x, y, s, ecp1_xp, ecp1_xn, ecp1_yp, ecp1_yn,
   ma_zp, ma_zn
   ) ;
   input          clk, rst_n;
   input [2:0]    y_op;
   input          y_en;
   input          y_clr;

   input [255:0]  x, y, s;

   input [255:0]  ecp1_xp, ecp1_xn;
   input [255:0]  ecp1_yp, ecp1_yn;

   input [255:0]  ma_zp, ma_zn;

   output [255:0] ma_yp, ma_yn;

   /* Output Type */
   reg   [255:0] ma_yp, ma_yn;
   reg   [255:0] ma_yp_nxt, ma_yn_nxt;

   localparam AP  = 256'h0000000800000020000000000000000000000020000000000000000000000008;
   localparam AN  = 256'h0000001400000014000000000000000000000014000000000000000000000014;

   /* Operation Code */
   localparam Y_SET_Y       = 3'b000;
   localparam Y_SET_S       = 3'b001;
   localparam Y_SET_2       = 3'b010;
   localparam Y_SET_A       = 3'b011;
   localparam Y_SET_T       = 3'b100;
   localparam Y_SET_CZ      = 3'b101;
   localparam Y_SET_ECP1X   = 3'b110;
   localparam Y_SET_ECP1Y   = 3'b111;

   always @ ( * ) begin
      case (y_op)
        Y_SET_Y     : ma_yp_nxt = y;
        Y_SET_S     : ma_yp_nxt = s;
        Y_SET_2     : ma_yp_nxt = 256'd2;
        Y_SET_A     : ma_yp_nxt = AP;
        Y_SET_T     : ma_yp_nxt = x;
        Y_SET_CZ    : ma_yp_nxt = ma_zp;
        Y_SET_ECP1X : ma_yp_nxt = ecp1_xp;
        Y_SET_ECP1Y : ma_yp_nxt = ecp1_yp;
      endcase // case (x_op)
   end

   always @ ( * ) begin
      case (y_op)
        Y_SET_Y     : ma_yn_nxt = 256'd0;
        Y_SET_S     : ma_yn_nxt = 256'd0;
        Y_SET_2     : ma_yn_nxt = 256'd0;
        Y_SET_A     : ma_yn_nxt = AN;
        Y_SET_T     : ma_yn_nxt = y;
        Y_SET_CZ    : ma_yn_nxt = ma_zn;
        Y_SET_ECP1X : ma_yn_nxt = ecp1_xn;
        Y_SET_ECP1Y : ma_yn_nxt = ecp1_yn;
      endcase // case (x_op)
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         ma_yp <= 256'd0;
         ma_yn <= 256'd0;
      end else begin
         if(y_clr) begin
            ma_yp <= 256'd0;
            ma_yn <= 256'd0;
         end else if (y_en) begin
            ma_yp <= ma_yp_nxt;
            ma_yn <= ma_yn_nxt;
         end
      end
   end

endmodule // ec_core_y


