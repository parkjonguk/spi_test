//-----------------------------------------------------------------------------
// Title         : ARIA Block Round Layer 1 Module
// Project       : ARIA 1.1
//-----------------------------------------------------------------------------
// File          : aria_round_l1.v
// Author        : Haeyoung Kim  <ryoung0327@gmail.com>
// Created       : 08.12.2018
// Last modified : 14.12.2018
//-----------------------------------------------------------------------------
// Description :
// ARIA Round Function Layer 1
// Perform RK xor BLK, LT 1/4
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by aria_round This model is the confidential and
// proprietary property of aria_round and the possession or use of this
// file requires a written license from aria_round.
//------------------------------------------------------------------------------
// Modification history :
// 08.12.2018 : created by Haeyoung Kim
// 14.12.2018 : code refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module aria_round_l1 (/*AUTOARG*/
   // Outputs
   l1,
   // Inputs
   clk, rst_n, r_ready, ecb_en, ecb_clr, ecb_din, l1_en, l1_op,
   flg_ltinv, rk_addr, w0, w1, w2, w3, l2
   ) ;
   input          clk, rst_n;

   input          r_ready;

   input          ecb_en;
   input          ecb_clr;
   input [127:0]  ecb_din;

   input          l1_en;
   input  [1:0]   l1_op;
   output [127:0] l1;

   input          flg_ltinv;

   input [5:0]    rk_addr;
   input [127:0]  w0, w1, w2, w3;
   input [127:0]  l2;

   /* L1 Operation Code */
   localparam L1_INIT = 2'b00;
   localparam L1_ARK  = 2'b01;
   localparam L1_LT   = 2'b10;
   localparam L1_CLR  = 2'b11;

   localparam C1       = 128'h517cc1b727220a94fe13abe8fa9a6ee0;
   localparam C2       = 128'h6db14acc9e21c820ff28b1d5ef5de2b0;
   localparam C3       = 128'hdb92371d2126e9700324977504e8c90e;

   /* Output Type */
   reg   [127:0] l1, l1_nxt;


   /* Round Key Selector */
   wire [1:0]    w_sel;
   wire [2:0]    rkt_sel;
   wire [127:0]   rk;
   reg  [127:0]   w, rkt;

   assign w_sel = rk_addr[2:1];

   always @ (*) begin : MX_W
      case (w_sel)
        2'b00 : w = w0;
        2'b01 : w = w1;
        2'b10 : w = w2;
        2'b11 : w = w3;
      endcase // case (w_sel)
   end

   assign rkt_sel = rk_addr[5:3];

   always @ (*) begin : MX_RKT
      case (rkt_sel)
        3'b000 : rkt = {w[ 18:0], w[127: 19]};
        3'b001 : rkt = {w[ 30:0], w[127: 31]};
        3'b010 : rkt = {w[ 66:0], w[127: 67]};
        3'b011 : rkt = {w[ 96:0], w[127: 97]};
        3'b100 : rkt = {w1[108:0], w1[127:109]};
        3'b101 : rkt = C1;
        3'b110 : rkt = C2;
        3'b111 : rkt = C3;
      endcase // case (rkt_sel)
   end

   assign rk = (rk_addr[0] == 1'b1) ? w : rkt;

   /* LT */
   wire   [31:0] lt_i, lt_o;

   assign lt_i = l1[31:0];

   aria_lt LT (
               .lt_conf_inv(flg_ltinv),
               .lt_din(lt_i),
               .lt_dout(lt_o)
               );

   /* Next L1 Selector */
   always @ (*) begin : MX_L1_NXT
      case (l1_op)
        L1_INIT  : l1_nxt = l2;
        L1_ARK   : l1_nxt = l1 ^ rk;
        L1_LT    : l1_nxt = {lt_o, l1[127:32]};
        L1_CLR   : l1_nxt = 128'd0;
      endcase // case (l1_op)
   end

   /* L1_REGISTER */
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         l1 <= 128'd0;
      end else begin
         if(r_ready & ecb_clr) begin
            l1 <= 128'd0;
         end else if(l1_en) begin
            l1 <= l1_nxt;
         end else if (r_ready & ecb_en) begin
            l1 <= ecb_din;
         end
      end
   end

endmodule // aria_round_l1
