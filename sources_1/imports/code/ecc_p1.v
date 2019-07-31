//-----------------------------------------------------------------------------
// Title         : ECC Core P1 Register
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : ecc_p1.v
// Author        : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 23.12.2018
// Last modified : 25.12.2018
//-----------------------------------------------------------------------------
// Description :
// ECC Core P1 Register
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 23.12.2018 : created by Haeyoung Kim
// 25.12.2018 : Function Verification Done and Code Refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module ecc_p1 (/*AUTOARG*/
   // Outputs
   ecp1_xp, ecp1_xn, ecp1_yp, ecp1_yn,
   // Inputs
   clk, rst_n, p1_op, p1_en, p1_clr, Qx, Qy, x, y, ecp3_xp, ecp3_xn, ecp3_yp,
   ecp3_yn
   ) ;
   input         clk, rst_n;
   input [1:0]   p1_op;
   input         p1_en;
   input         p1_clr;

   input  [255:0] Qx, Qy;
   input  [255:0] x, y;

   input  [255:0] ecp3_xp, ecp3_xn;
   input  [255:0] ecp3_yp, ecp3_yn;

   output [255:0] ecp1_xp, ecp1_xn;
   output [255:0] ecp1_yp, ecp1_yn;

   localparam P1_SET_Q    = 2'b00;
   localparam P1_SET_T    = 2'b01;
   localparam P1_SET_N    = 2'b10;
   localparam P1_SET_M    = 2'b11;

   localparam P1_MXP = 256'h7fffbffeaa455255d024aaa44511288452555022f7fffffdf7fffffffffffeff;
   localparam P1_MXN = 256'h1dbe42241567fb3be836ddf6678894427b6af831784927f810633caf9d5bae0f;
   localparam P1_MYP = 256'h2b93f8c55445142aa94454492910a954aaaa4922d0cf22e6ef929abe74aab054;
   localparam P1_MYN = 256'h15cbfc62be239e155da23a25b488dcbe7d7f6591e867917377c94d5f3a55582a;

   reg [255:0]   ecp1_xp, ecp1_xp_nxt;
   reg [255:0]   ecp1_xn, ecp1_xn_nxt;
   reg [255:0]   ecp1_yp, ecp1_yp_nxt;
   reg [255:0]   ecp1_yn, ecp1_yn_nxt;

   always @ (*) begin
      case (p1_op)
        P1_SET_Q  : ecp1_xp_nxt = Qx;
        P1_SET_T  : ecp1_xp_nxt = x;
        P1_SET_N  : ecp1_xp_nxt = ecp3_xp;
        P1_SET_M  : ecp1_xp_nxt = P1_MXP;
      endcase // case (p1_op)
   end

   always @ (*) begin
      case (p1_op)
        P1_SET_Q  : ecp1_xn_nxt = 256'd0;
        P1_SET_T  : ecp1_xn_nxt = 256'd0;
        P1_SET_N  : ecp1_xn_nxt = ecp3_xn;
        P1_SET_M  : ecp1_xn_nxt = P1_MXN;
      endcase // case (p1_op)
   end

   always @ (*) begin
      case (p1_op)
        P1_SET_Q  : ecp1_yp_nxt = Qy;
        P1_SET_T  : ecp1_yp_nxt = y;
        P1_SET_N  : ecp1_yp_nxt = ecp3_yp;
        P1_SET_M  : ecp1_yp_nxt = P1_MYP;
      endcase // case (p1_op)
   end

   always @ (*) begin
      case (p1_op)
        P1_SET_Q  : ecp1_yn_nxt = 256'd0;
        P1_SET_T  : ecp1_yn_nxt = 256'd0;
        P1_SET_N  : ecp1_yn_nxt = ecp3_yn;
        P1_SET_M  : ecp1_yn_nxt = P1_MYN;
      endcase // case (p1_op)
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         ecp1_xp   <= 256'd0;
         ecp1_xn   <= 256'd0;
         ecp1_yp   <= 256'd0;
         ecp1_yn   <= 256'd0;
      end else begin
         if(p1_clr) begin
            ecp1_xp   <= 256'd0;
            ecp1_xn   <= 256'd0;
            ecp1_yp   <= 256'd0;
            ecp1_yn   <= 256'd0;
         end else if (p1_en) begin
            ecp1_xp   <= ecp1_xp_nxt;
            ecp1_xn   <= ecp1_xn_nxt;
            ecp1_yp   <= ecp1_yp_nxt;
            ecp1_yn   <= ecp1_yn_nxt;
         end
      end
   end

endmodule // ecc_p1

