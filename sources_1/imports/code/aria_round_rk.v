//-----------------------------------------------------------------------------
// Title         : ARIA Add Round Key Address
// Project       : ARIA 1.1
//-----------------------------------------------------------------------------
// File          : aria_round_rk.v
// Author        : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 10.12.2018
// Last modified : 14.12.2018
//-----------------------------------------------------------------------------
// Description :
// ARIA Round rk_address Module
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 10.12.2018 : created by Haeyoung Kim
// 14.12.2018 : code refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module aria_round_rk (/*AUTOARG*/
   // Outputs
   rk_addr,
   // Inputs
   clk, rst_n, rk_op, rk_en, rk_clr, st_ksize, flg_dec
   ) ;
   input        clk, rst_n;
   input  [1:0] rk_op;
   input        rk_en;
   input        rk_clr;

   output [5:0] rk_addr;

   input  [1:0] st_ksize;
   input        flg_dec;


   /* rk_addr Operation Code */
   localparam RK_K_INIT = 2'b00;
   localparam RK_K_NEXT = 2'b01;
   localparam RK_R_INIT = 2'b10;
   localparam RK_R_NEXT = 2'b11;

   /* Output Type */
   reg [5:0]    rk_addr;
   reg [5:0]    rk_addr_nxt;

   /* K INIT */
   reg  [5:0]   k_init;

   always @ (*) begin : MX_K_INIT
      case (st_ksize)
        2'b00 : k_init = 6'b000000;
        2'b01 : k_init = 6'b100101;
        2'b10 : k_init = 6'b101101;
        2'b11 : k_init = 6'b110101;
      endcase // case (sel_k)
   end

   /* K NEXT */
   wire [3:0]   k_t;
   wire [3:0]   k_add;
   wire [3:0]   k_sel;
   wire [5:0]   k_next;

   assign k_t     = {rk_addr[5:3], rk_addr[0]};
   assign k_add   = k_t + 4'd1;
   assign k_sel   = (k_t == 4'b1110) ? 4'b1001 : k_add;
   assign k_next  = {k_sel[3:1], 2'b10, k_sel[0]};

   /* R INIT */
   reg  [5:0]   r_init;
   wire [1:0]   r_sel;

   assign r_sel = flg_dec ? st_ksize : 2'b00;

   always @ (*) begin : MX_R_INIT
      case(r_sel)
        2'b00 : r_init = 6'b000001;
        2'b01 : r_init = 6'b011010;
        2'b10 : r_init = 6'b011110;
        2'b11 : r_init = 6'b100010;
      endcase // case (r_sel)
   end

   /* R NEXT */
   wire [2:0]   r_w_add, r_w_sub;

   assign r_w_add = rk_addr[2:0] + 3'd1;
   assign r_w_sub = rk_addr[2:0] - 3'd1;

   wire [2:0]   r_rol_add, r_rol_sub;
   assign r_rol_add = rk_addr[5:3] + 3'd1;
   assign r_rol_sub = rk_addr[5:3] - 3'd1;

   wire [5:0]   r_add;
   wire [5:0]   r_sub;
   wire [5:0]   r_next;

   assign r_add  = (rk_addr[2:0] == 3'b000) ? {r_rol_add, r_w_add} : {rk_addr[5:3], r_w_add};
   assign r_sub  = (rk_addr[2:0] == 3'b001) ? {r_rol_sub, r_w_sub} : {rk_addr[5:3], r_w_sub};
   assign r_next = flg_dec ? r_sub : r_add;

   /* rk_addr NEXT */

   always @ (*) begin : MX_CNT_NXT
      case (rk_op)
        RK_K_INIT : rk_addr_nxt = k_init;
        RK_K_NEXT : rk_addr_nxt = k_next;
        RK_R_INIT : rk_addr_nxt = r_init;
        RK_R_NEXT : rk_addr_nxt = r_next;
      endcase // case (cnt_op)
   end


   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         rk_addr <= 6'd0;
      end else begin
         if(rk_clr) begin
            rk_addr <= 6'd0;
         end else if(rk_en) begin
            rk_addr <= rk_addr_nxt;
         end
      end
   end

endmodule // aria_round_rk
