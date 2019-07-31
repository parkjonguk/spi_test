//-----------------------------------------------------------------------------
// Title         : B Register For Modular Arithmetic
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : mod_arith_b.v
// Author        : Haeyoung Kim  <ryoung0327@gmail.com>
// Created       : 17.11.2018
// Last modified : 15.12.2018
//-----------------------------------------------------------------------------
// Description :
//  - B Register For Modular Arithmetic
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 17.11.2018 : created by Haeyoung Kim
// 15.12.2018 : Code refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module mod_arith_b (/*AUTOARG*/
   // Outputs
   bp, bn,
   // Inputs
   clk, rst_n, b_op, b_en, flg_mod, ap, an, yp, yn, up, un, vp, vn
   ) ;
   input          clk, rst_n;

   input [2:0]    b_op;
   input          b_en;
   input          flg_mod;

   input [255:0]  ap, an;
   input [255:0]  yp, yn;
   input [255:0]  up, un;
   input [255:0]  vp, vn;

   output [255:0] bp, bn;

   localparam MP0 = 256'hFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF;
   localparam MP1 = 256'hFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551;
   localparam INV = 256'h4FFFFFFFDFFFFFFFFFFFFFFFEFFFFFFFBFFFFFFFF00000000000000030;
   localparam ONE = 256'd1;

   localparam OP_B_SETY      = 3'b000;
   localparam OP_B_SETA      = 3'b001;
   localparam OP_B_SETU      = 3'b010;
   localparam OP_B_SETV      = 3'b011;
   localparam OP_B_DIVINIT   = 3'b100;
   localparam OP_B_MONT      = 3'b101;
   localparam OP_B_MONTINV   = 3'b110;
   localparam OP_B_CLEAR     = 3'b111;

   /* Output Type */
   reg [255:0]    bp, bn;
   reg [255:0]    bp_nxt, bn_nxt;

   /* Function : Modular Selector */
   wire [255:0]   modular;
   assign modular   = (flg_mod == 1'b1) ? MP1 : MP0;


   always @ (*) begin
      case (b_op)
        OP_B_SETY     : bp_nxt = yp;
        OP_B_SETA     : bp_nxt = ap;
        OP_B_SETU     : bp_nxt = up;
        OP_B_SETV     : bp_nxt = vp;
        OP_B_DIVINIT  : bp_nxt = modular;
        OP_B_MONT     : bp_nxt = INV;
        OP_B_MONTINV  : bp_nxt = ONE;
        OP_B_CLEAR    : bp_nxt = 256'd0;
      endcase // case (b_op)
   end


   always @ (*) begin
      case (b_op)
        OP_B_SETY     : bn_nxt = yn;
        OP_B_SETA     : bn_nxt = an;
        OP_B_SETU     : bn_nxt = un;
        OP_B_SETV     : bn_nxt = vn;
        OP_B_DIVINIT  : bn_nxt = 256'd0;
        OP_B_MONT     : bn_nxt = 256'd0;
        OP_B_MONTINV  : bn_nxt = 256'd0;
        OP_B_CLEAR    : bn_nxt = 256'd0;
      endcase // case (b_op)
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         bp <= 256'd0;
         bn <= 256'd0;
      end else begin
         if(b_en) begin
            bp <= bp_nxt;
            bn <= bn_nxt;
         end
      end
   end

endmodule // mod_arith_b
