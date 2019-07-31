//-----------------------------------------------------------------------------
// Title         : ARIA Block Round Layer 2 Module
// Project       : ARIA 1.1
//-----------------------------------------------------------------------------
// File          : aria_round_l2.v
// Author        : Haeyoung Kim  <ryoung0327@gmail.com>
// Created       : 08.12.2018
// Last modified : 14.12.2018
//-----------------------------------------------------------------------------
// Description :
// ARIA Round Function Layer 2
//  - L2_EN       : DIFF 1/4 FUNCTION
//  - FLG_RKDIF   : DECRYPT KEY DIFF FUNCTION
//  - L2_OPT_EVEN : DIFF 1/4 ROUND 2 AND 4
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by aria_round This model is the confidential and
// proprietary property of aria_round and the possession or use of this
// file requires a written license from aria_round.
//------------------------------------------------------------------------------
// Modification history :
// 08.12.2018 : created by Haeyoung Kim
// 14.12.2018 : code refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module aria_round_l2 (/*AUTOARG*/
   // Outputs
   l2,
   // Inputs
   clk, rst_n, r_ready, flg_rkdf, xfb_en, xfb_clr, xfb_din, l1, l2_en,
   l2_clr, l2_opt_even
   );
   input          clk, rst_n;

   input          r_ready;
   input          flg_rkdf;

   input          xfb_en;
   input          xfb_clr;
   input [127:0]  xfb_din;

   input [127:0]  l1;

   input          l2_en;
   input          l2_clr;
   output [127:0] l2;
   input          l2_opt_even;

   /* Output Type */
   reg [127:0]    l2;

   /* ARIA DIFF Function (4CLK Need) */
   wire [7:0]     tx0, tx1, tx2, tx3;
   wire [7:0]     ty0,ty1,ty2,ty3,ty4,ty5,ty6,ty7,ty8,ty9,ty10,ty11,ty12,ty13,ty14,ty15;
   wire [7:0]     tz0,tz1,tz2,tz3,tz4,tz5,tz6,tz7,tz8,tz9,tz10,tz11,tz12,tz13,tz14,tz15;
   wire [127:0]   ty, l2_xor_ty;
   wire [127:0]   diff, diff_even, diff_odd;

   assign {tx0, tx1, tx2, tx3} = flg_rkdf ? l1[31:0] : l1[127:96];

   assign ty0  = tx1 ^ tx2;
   assign ty1  = tx0 ^ tx3;
   assign ty2  = tx0 ^ tx3;
   assign ty3  = tx1 ^ tx2;
   assign ty4  = tx2 ^ tx3;
   assign ty5  = tx2 ^ tx3;
   assign ty6  = tx0 ^ tx1;
   assign ty7  = tx0 ^ tx1;
   assign ty8  = tx1 ^ tx3;
   assign ty9  = tx0 ^ tx2;
   assign ty10 = tx1 ^ tx3;
   assign ty11 = tx0 ^ tx2;
   assign ty12 = tx0;
   assign ty13 = tx1;
   assign ty14 = tx2;
   assign ty15 = tx3;

   assign ty        = {ty0, ty1, ty2, ty3, ty4, ty5, ty6, ty7, ty8, ty9, ty10, ty11, ty12, ty13, ty14, ty15};
   assign l2_xor_ty = ty ^ l2;
   assign {tz0,tz1,tz2,tz3,tz4,tz5,tz6,tz7,tz8,tz9,tz10,tz11,tz12,tz13,tz14,tz15} = l2_xor_ty;
   assign diff_odd  = {tz6,tz7,tz4,tz5,tz2,tz3,tz0,tz1,tz14,tz15,tz12,tz13,tz10,tz11,tz8,tz9};
   assign diff_even = {tz15,tz14,tz13,tz12,tz11,tz10,tz9,tz8,tz7,tz6,tz5,tz4,tz3,tz2,tz1,tz0};
   assign diff      = l2_opt_even ? diff_even : diff_odd;

   /* L1_REGISTER */
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         l2 <= 128'd0;
      end else begin
         if(l2_clr | (r_ready & xfb_clr)) begin
            l2 <= 128'd0;
         end else if(l2_en) begin
            l2 <= diff;
         end else if(r_ready & xfb_en) begin
            l2 <= l1 ^ xfb_din;
         end
      end
   end

endmodule // aria_round_l2

