//-----------------------------------------------------------------------------
// Title         : ARIA Control Unit
// Project       : ARIA 1.1
//-----------------------------------------------------------------------------
// File          : aria_cu.v
// Author        : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 14.12.2018
// Last modified : 15.12.2018
//-----------------------------------------------------------------------------
// Description :
// ARIA Control Unit
// ARIA OP
//  - 3'b000 : K_ZERO
//  - 3'b001 : K_SET128
//  - 3'b010 : K_SET192
//  - 3'b011 : K_SET256
//  - 3'b100 : R_ENC_ECB
//  - 3'b101 : R_ENC_XFB
//  - 3'b110 : R_DEC_ECB
//  - 3'b111 : R_DEC_XFB
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 14.12.2018 : created by Haeyoung Kim
// 15.12.2018 : Standard Test Vector Test Done
//-----------------------------------------------------------------------------
module aria_cu (/*AUTOARG*/
   // Outputs
   k_ready, r_ready, flg_rkdf, flg_dec, rk_clr, rk_en, rk_op, nr_clr, nr_en,
   key_op, key_en, key_clr, l1_en, l1_op, l2_clr, l2_en, l2_opt_even,
   warn_rterm,
   // Inputs
   clk, rst_n, aria_op, aria_en, aria_clr, flg_klast, flg_rlast
   ) ;
   input        clk, rst_n;

   input [2:0]  aria_op;
   input        aria_en;
   input        aria_clr;

   output       k_ready;
   output       r_ready;

   input        flg_klast;
   input        flg_rlast;

   output       flg_rkdf;
   output       flg_dec;

   output       rk_clr;
   output       rk_en;
   output [1:0] rk_op;

   output       nr_clr;
   output       nr_en;

   output [1:0] key_op;
   output       key_en;
   output       key_clr;

   output       l1_en;
   output [1:0] l1_op;

   output       l2_clr;
   output       l2_en;
   output       l2_opt_even;
   output       warn_rterm;


   localparam IDLE       = 14'b00000000000001;
   localparam K_INIT     = 14'b00000000000010;
   localparam R_CLR      = 14'b00000000000100;
   localparam R_READY    = 14'b00000000001000; // KDF SET 0
   localparam R_INIT     = 14'b00000000010000;
   localparam RK0_NOP    = 14'b00000000100000;
   localparam RK1_NOP    = 14'b00000001000000; // IF(DEC && KDF) THEN GOTO LT2_DF0 ,, EXIT
   localparam LT1_CLR    = 14'b00000010000000;
   localparam LT2_DF0    = 14'b00000100000000;
   localparam LT3_DF1    = 14'b00001000000000;
   localparam LT4_DF0    = 14'b00010000000000; // IF LASTBLK THEN GOTO RK0_NOP, FNL SET 1
   localparam CLR_DF1    = 14'b00100000000000; // IF(DEC && !KDF) THEN GOTO RK0_NOP, KDF SET 1, CNT_EN
   localparam SL2_CLR    = 14'b01000000000000; // IF(DEC && KDF) THEN GOTO LT1_CLR, KDF_SET 0
   localparam CLR_ALL    = 14'b10000000000000;

   reg          flg_kexp;
   reg          flg_rkfin;
   reg          flg_dec;
   reg          flg_rkdf;
   reg          flg_xfb;

   reg          k_ready;
   reg          r_ready;

   reg          rk_clr;
   reg          rk_en;
   reg [1:0]    rk_op;

   reg          nr_clr;
   reg          nr_en;

   reg          l1_en;
   reg [1:0]    l1_op;

   reg          l2_en;
   reg          l2_clr;
   reg          l2_opt_even;

   reg [1:0]    key_op;
   reg          key_en;
   reg          key_clr;

   reg [13:0]   state, state_nxt;

   reg          warn_rterm;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(aria_clr) begin
            state <= CLR_ALL;
         end else begin
            state <= state_nxt;
         end
      end
   end
   /* WARN RTERM */
   reg         rterm_on, rterm_off;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         warn_rterm <= 1'b0;
      end else begin
         if(rterm_off) begin
            warn_rterm <= 1'b0;
         end else if(rterm_on) begin
            warn_rterm <= 1'b1;
         end
      end
   end

   reg         flg_clr;

   /* KEXP FLAG */
   reg         flg_kexp_on;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_kexp <= 1'b0;
      end else begin
         if(flg_clr) begin
            flg_kexp <= 1'b0;
         end else if(flg_kexp_on) begin
            flg_kexp <= 1'b1;
         end
      end
   end

   /* RKFIN FLAG */
   reg         flg_rkfin_on;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_rkfin <= 1'b0;
      end else begin
         if(flg_clr) begin
            flg_rkfin <= 1'b0;
         end else if(flg_rkfin_on) begin
            flg_rkfin <= 1'b1;
         end
      end
   end

   /* DEC FLAG */
   reg         flg_dec_on;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_dec <= 1'b0;
      end else begin
         if(flg_clr) begin
            flg_dec <= 1'b0;
         end else if(flg_dec_on) begin
            flg_dec <= 1'b1;
         end
      end
   end

   /* RKDF FLAG */
   reg         flg_rkdf_on;
   reg         flg_rkdf_off;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_rkdf <= 1'b0;
      end else begin
         if(flg_clr | flg_rkdf_off) begin
            flg_rkdf <= 1'b0;
         end else if(flg_rkdf_on) begin
            flg_rkdf <= 1'b1;
         end
      end
   end

   /* RKDF FLAG */
   reg         flg_xfb_on;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_xfb <= 1'b0;
      end else begin
         if(flg_clr) begin
            flg_xfb <= 1'b0;
         end else if(flg_xfb_on) begin
            flg_xfb <= 1'b1;
         end
      end
   end

   always @ (*) begin
      state_nxt      = state;
      rterm_on       = 0;
      rterm_off      = 0;
      k_ready        = 0;
      r_ready        = 0;
      flg_clr        = 0;
      flg_kexp_on    = 0;
      flg_rkfin_on   = 0;
      flg_dec_on     = 0;
      flg_rkdf_on    = 0;
      flg_rkdf_off   = 0;
      flg_xfb_on     = 0;
      rk_clr         = 0;
      rk_en          = 0;
      rk_op          = 2'b00;
      nr_clr         = 0;
      nr_en          = 0;
      l1_en          = 0;
      l1_op          = 2'b00;
      l2_en          = 0;
      l2_clr         = 0;
      l2_opt_even    = 0;
      key_op         = 2'b00;
      key_en         = 0;
      key_clr        = 0;
      case (state)
        IDLE       : begin
           k_ready        = 1;
           if(aria_en & !aria_op[2]) begin
              if(aria_op[1:0]  == 2'b00) begin
                 state_nxt      = CLR_ALL;
              end else begin
                 state_nxt      = K_INIT;
                 key_en         = 1;
                 key_op         = aria_op[1:0];
                 flg_kexp_on    = 1;
                 rterm_off      = 1;
              end
           end
        end
        K_INIT     : begin
           state_nxt      = RK0_NOP;
           rk_en          = 1;
           rk_op          = 2'b00;
           nr_clr         = 1;
           l1_en          = 1;
           l1_op          = 2'b11;
           l2_clr         = 1;
        end
        R_CLR      : begin
           state_nxt      = R_READY;
           rk_clr         = 1;
           l1_en          = 1;
           l1_op          = 2'b11; //L1_CLR
           l2_clr         = 1;
           flg_clr        = 1;
        end
        R_READY    : begin
           r_ready        = 1;
           k_ready        = 1;
           if(aria_en & !aria_op[2]) begin
              if(aria_op[1:0]  == 2'b00) begin
                 state_nxt      = CLR_ALL;
              end else begin
                 state_nxt      = K_INIT;
                 key_en         = 1;
                 key_op         = aria_op[1:0];
                 flg_kexp_on    = 1;
                 rterm_on       = 1;
              end
           end else if (aria_en & aria_op[2]) begin
              state_nxt   = R_INIT;
              flg_dec_on  = aria_op[1];
              flg_xfb_on  = aria_op[0];
           end
        end
        R_INIT     : begin
           state_nxt      = RK0_NOP;
           rk_en          = 1;
           rk_op          = 2'b10;
           nr_clr         = 1;
           l2_clr         = 1;
           if(flg_xfb) begin
              l1_en       = 1;
              l1_op       = 2'b00;
           end
        end
        RK0_NOP    : begin
           state_nxt      = RK1_NOP;
           l1_en          = 1;
           l1_op          = 2'b01; // L1_ARK
           rk_en          = 1;
           if(flg_kexp) begin
              rk_op       = 2'b01;
           end else begin
              rk_op       = 2'b11;
           end
        end
        RK1_NOP    : begin
           l1_en          = 1;
           l1_op          = 2'b01; // L1_ARK
           if(flg_rkfin) begin
              state_nxt      = R_READY;
              rk_clr         = 1;
              nr_clr         = 1;
              flg_clr        = 1;
              l2_clr         = 1;
           end else begin
              rk_en          = 1;
              state_nxt      = LT1_CLR;
              if(flg_kexp) begin
                 rk_op       = 2'b01;
                 key_en      = 1;
                 if(flg_klast) begin
                    state_nxt = R_CLR;
                 end
              end else begin
                 rk_op       = 2'b11;
                 if(flg_dec & flg_rkdf) begin
                    state_nxt      = LT2_DF0;
                 end
              end
           end
        end
        LT1_CLR    : begin
           state_nxt      = LT2_DF0;
           l1_en          = 1;
           l1_op          = 2'b10; // L1_LT
           l2_clr         = 1;
        end
        LT2_DF0    : begin
           state_nxt      = LT3_DF1;
           l1_en          = 1;
           l1_op          = 2'b10; // L1_LT
           l2_en          = 1;
        end
        LT3_DF1    : begin
           state_nxt      = LT4_DF0;
           l1_en          = 1;
           l1_op          = 2'b10; // L1_LT
           l2_en          = 1;
           l2_opt_even    = 1;
        end
        LT4_DF0    : begin
           l1_en          = 1;
           l1_op          = 2'b10; // L1_LT
           l2_en          = 1;
           if(flg_rlast & !flg_rkdf) begin
              flg_rkfin_on   = 1;
              state_nxt      = RK0_NOP;
           end else begin
              state_nxt      = CLR_DF1;
           end
        end
        CLR_DF1    : begin
           l1_en          = 1;
           l1_op          = 2'b11; // L1_CLR
           l2_en          = 1;
           l2_opt_even    = 1;

           if(flg_dec & !flg_rkdf) begin
              state_nxt      = RK0_NOP;
              flg_rkdf_on    = 1;
           end else begin
              state_nxt      = SL2_CLR;
           end

           if(flg_dec & flg_rkdf) begin
              nr_en          = 0;
           end else begin
              nr_en          = 1;
           end
        end
        SL2_CLR    : begin
           l1_en          = 1;
           l1_op          = 2'b00; // L1_INIT
           l2_clr         = 1;
           if(flg_dec & flg_rkdf) begin
              state_nxt      = LT1_CLR;
              flg_rkdf_off   = 1;
           end else begin
              state_nxt      = RK0_NOP;
           end
        end
        CLR_ALL    : begin
           state_nxt      = IDLE;
           key_clr        = 1;
           l1_en          = 1;
           l1_op          = 2'b11; // L1_CLR
           rk_clr         = 1;
           nr_clr         = 1;
           l2_clr         = 1;
           rterm_off      = 1;
        end
      endcase // case (state)
   end

endmodule // aria_cu

