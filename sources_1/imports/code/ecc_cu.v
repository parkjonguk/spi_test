//-----------------------------------------------------------------------------
// Title         : ECC Core Control Unit
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : ecc_cu.v
// Author        : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 23.12.2018
// Last modified : 17.01.2019
//-----------------------------------------------------------------------------
// Description :
// ECC Core Control Unit
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 23.12.2018 : created by Haeyoung Kim
// 25.12.2018 : Function Verification Done and Code Refactoring by Haeyoung Kim
// 17.01.2019 : Bugfix Clear Signal
//-----------------------------------------------------------------------------
module ecc_cu (/*AUTOARG*/
   // Outputs
   ecc_rdy, k_op, k_en, k_clr, p1_op, p1_en, p1_clr, p2_op, p2_en, p2_clr, t_op,
   t_en, t_clr, ec_clr, ec_en, ec_op,
   // Inputs
   clk, rst_n, ecc_op, ecc_en, ecc_clr, k_rdy, flg_ec_add, flg_ec_last, ec_rdy
   ) ;
   input          clk, rst_n;

   input [1:0]    ecc_op;
   input          ecc_en;
   input          ecc_clr;
   output         ecc_rdy;

   input          k_rdy;
   input          flg_ec_add;
   input          flg_ec_last;
   output [1:0]   k_op;
   output         k_en;
   output         k_clr;

   output [1:0]   p1_op;
   output         p1_en;
   output         p1_clr;

   output [1:0]   p2_op;
   output         p2_en;
   output         p2_clr;

   output [2:0]   t_op;
   output         t_en;
   output         t_clr;

   input          ec_rdy;
   output         ec_clr;
   output         ec_en;
   output [2:0]   ec_op;

   localparam ECDH_SK     = 2'b00;
   localparam ECDSA_SIGN  = 2'b01;
   localparam ECDSA_VERI  = 2'b10;
   localparam ECDH_PK     = 2'b11;

   localparam K_SET_K     = 2'b00;
   localparam K_SET_U1    = 2'b01;
   localparam K_SET_U2    = 2'b10;
   localparam K_NEXT      = 2'b11;

   localparam P1_SET_Q    = 2'b00;
   localparam P1_SET_T    = 2'b01;
   localparam P1_SET_N    = 2'b10;
   localparam P1_SET_M    = 2'b11;

   localparam P2_SET_N    = 2'b00;
   localparam P2_SET_M    = 2'b01;
   localparam P2_SET_T    = 2'b10;

   localparam T_ECDH_RES  = 3'b000;
   localparam T_VERI_INIT = 3'b001;
   localparam T_VERI_SWAP = 3'b010;
   localparam T_VERI_SETU = 3'b011;
   localparam T_VERI_U2P = 3'b100;
   localparam T_VERI_RES  = 3'b101;
   localparam T_SIGN_INIT = 3'b110;
   localparam T_SIGN_RES  = 3'b111;

   localparam EC_RTB      = 3'b000;
   localparam EC_VERI_U   = 3'b001;
   localparam EC_MONT     = 3'b010;
   localparam EC_MONT_INV = 3'b011;
   localparam EC_ADD      = 3'b100;
   localparam EC_DBL      = 3'b101;
   localparam EC_FIN_SIGN = 3'b110;
   localparam EC_FIN_VERI = 3'b111;

   localparam IDLE             = 16'b0000000000000001;
   localparam MONTGOMERY       = 16'b0000000000000010;
   localparam COMPRESS_P1      = 16'b0000000000000100;
   localparam CHK_K_READY      = 16'b0000000000001000;
   localparam SCALAR_MUL       = 16'b0000000000010000;
   localparam MONT_INVERSION   = 16'b0000000000100000;
   localparam RSD_TO_BIN       = 16'b0000000001000000;
   localparam SIGN_FIN         = 16'b0000000010000000;
   localparam VERI_INIT        = 16'b0000000100000000;
   localparam VERI_MAKE_UK     = 16'b0000001000000000;
   localparam VERI_SET_U2K     = 16'b0000010000000000;
   localparam VERI_CHK_2ND     = 16'b0000100000000000;
   localparam VERI_SET_U1K     = 16'b0001000000000000;
   localparam VERI_P_ADD       = 16'b0010000000000000;
   localparam VERI_FINAL       = 16'b0100000000000000;
   localparam ALL_CLR          = 16'b1000000000000000;

   reg [15:0]     state, state_nxt;
   reg            ecc_rdy;
   reg [1:0]      k_op;
   reg            k_en;
   reg            k_clr;
   reg [1:0]      p1_op;
   reg            p1_en;
   reg            p1_clr;
   reg [1:0]      p2_op;
   reg            p2_en;
   reg            p2_clr;
   reg [2:0]      t_op;
   reg            t_en;
   reg            t_clr;
   reg            ec_clr;
   reg            ec_en;
   reg [2:0]      ec_op;


   reg            flg_clr;
   /* OP FLAG */
   reg [1:0]      flg_op;
   reg            flg_op_up;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_op <= 2'b00;
      end else begin
         if(flg_clr) begin
            flg_op <= 2'b00;
         end else if (flg_op_up) begin
            flg_op <= ecc_op;
         end
      end
   end

   /* SET FLAG */
   reg            flg_set;
   reg            flg_set_up;
   reg            flg_set_down;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_set <= 1'b0;
      end else begin
         if(flg_clr | flg_set_down) begin
            flg_set <= 1'b0;
         end else if (flg_set_up) begin
            flg_set <= 1'b1;
         end
      end
   end

   /* 2ND FLAG */
   reg            flg_2nd;
   reg            flg_2nd_up;
   reg            flg_2nd_down;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_2nd <= 1'b0;
      end else begin
         if(flg_clr | flg_2nd_down) begin
            flg_2nd <= 1'b0;
         end else if (flg_2nd_up) begin
            flg_2nd <= 1'b1;
         end
      end
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(ecc_clr) begin
            state <= ALL_CLR;
         end else begin
            state <= state_nxt;
         end
      end
   end

   always @ (*) begin
      state_nxt   = state;

      ecc_rdy     = 0;

      k_op        = 2'b00;
      k_en        = 0;
      k_clr       = 0;

      p1_op        = 2'b00;
      p1_en        = 0;
      p1_clr       = 0;

      p2_op        = 2'b00;
      p2_en        = 0;
      p2_clr       = 0;

      t_op         = 3'b000;
      t_en         = 0;
      t_clr        = 0;

      ec_op        = 3'b000;
      ec_en        = 0;
      ec_clr       = 0;

      flg_clr      = 0;

      flg_2nd_up   = 0;
      flg_2nd_down = 0;

      flg_op_up    = 0;

      flg_set_up   = 0;
      flg_set_down = 0;


      case (state)
        IDLE : begin
           ecc_rdy      = 1;
           k_op         = K_SET_K;
           if(ecc_en) begin
              /* ECC INSTRUCTION STATE TRANSITION */
              if(ecc_op == ECDH_SK) begin
                 state_nxt    = MONTGOMERY;
              end else if(ecc_op == ECDSA_VERI) begin
                 state_nxt    = VERI_INIT;
              end else begin
                 state_nxt    = CHK_K_READY;
              end

              /* ECC INSTRUCTION K INIT */
              if(ecc_op == ECDSA_VERI) begin
                 k_clr        = 1;
              end else begin
                 k_en         = 1;
              end

              /* ECC INSTRUCTION P1 INIT */
              p1_en        = 1;
              if(ecc_op == ECDH_PK | ecc_op == ECDSA_SIGN) begin
                 p1_op        = P1_SET_M;
              end else begin
                 p1_op        = P1_SET_Q;
              end

              /* ECC INSTRUCTION P2 INIT */
              p2_op        = P2_SET_M;
              if(ecc_op == ECDH_PK | ecc_op == ECDSA_SIGN) begin
                 p2_en        = 1;
              end else begin
                 p2_clr       = 1;
              end

              /* ECC INSTRUCTION T INIT */
              if(ecc_op == ECDSA_SIGN) begin
                 t_op         = T_SIGN_INIT;
                 t_en         = 1;
              end else if(ecc_op == ECDSA_VERI) begin
                 t_op         = T_VERI_INIT;
                 t_en         = 1;
              end else begin
                 t_clr        = 1;
              end

              /* ECC FLAG INIT */
              flg_op_up    = 1;
              flg_set_down = 1;
              flg_2nd_down = 1;
           end
        end

        /* ECC Convert RX_Q to Montgomery Domain */
        /* Compress MONT(RX_Q) for Reducing Register Size*/
        MONTGOMERY : begin
           ec_op        = EC_MONT;
           p1_op        = P1_SET_N;
           if(ec_rdy) begin
              if(flg_set) begin
                 state_nxt    = COMPRESS_P1;
                 flg_set_down = 1;
                 p1_en        = 1;
              end else begin
                 ec_en        = 1;
                 flg_set_up   = 1;
              end
           end
        end
        COMPRESS_P1  : begin
           ec_op        = EC_RTB;
           p2_op        = P2_SET_N;
           if(ec_rdy) begin
              if(flg_set) begin
                 state_nxt    = CHK_K_READY;
                 flg_set_down = 1;
                 p2_en        = 1;
              end else begin
                 ec_en        = 1;
                 flg_set_up   = 1;
              end
           end
        end

        /* CHK K READY AND START Scalar Multiplication */
        CHK_K_READY : begin
           if(k_rdy) begin
              state_nxt = SCALAR_MUL;
           end
        end
        SCALAR_MUL : begin
           p1_op        = P1_SET_N;
           k_op         = K_NEXT;
           if(ec_rdy) begin
              if(flg_set) begin
                 p1_en        = 1;
                 flg_set_down = 1;
              end else begin
                 if(flg_ec_add) begin
                    ec_op        = EC_ADD;
                    ec_en        = 1;
                    k_en         = 1;
                    flg_set_up   = 1;
                 end else begin
                    if (flg_ec_last) begin
                       if(flg_op == ECDSA_SIGN) begin
                          state_nxt    = VERI_INIT;
                       end else if (flg_op == ECDSA_VERI) begin
                          state_nxt    = VERI_CHK_2ND;
                       end else begin
                          state_nxt    = MONT_INVERSION;
                       end
                    end else begin
                       ec_op        = EC_DBL;
                       ec_en        = 1;
                       k_en         = 1;
                       flg_set_up   = 1;
                    end
                 end
              end
           end
        end
        MONT_INVERSION : begin
           ec_op      = EC_MONT_INV;
           p1_op      = P1_SET_N;
           if(ec_rdy) begin
              if(flg_set) begin
                 state_nxt   = RSD_TO_BIN;
                 p1_en       = 1;
                 flg_set_down = 1;
              end else begin
                 ec_en       = 1;
                 flg_set_up  = 1;
              end
           end
        end
        RSD_TO_BIN : begin
           ec_op      = EC_RTB;
           if(ec_rdy) begin
              if(flg_set) begin
                 state_nxt   = IDLE;
                 t_op        = T_ECDH_RES;
                 k_clr       = 1;
                 flg_clr     = 1;
                 ec_clr      = 1;
                 t_en        = 1;
                 p1_clr      = 1;
                 p2_clr      = 1;
                 flg_set_down = 1;
              end else begin
                 ec_en       = 1;
                 flg_set_up  = 1;
              end
           end
        end
        SIGN_FIN : begin
           ec_op      = EC_FIN_SIGN;
           t_op       = T_SIGN_RES;
           if(ec_rdy) begin
              if(flg_set) begin
                 state_nxt  = IDLE;
                 t_en       = 1;
                 p1_clr     = 1;
                 p2_clr     = 1;
                 k_clr      = 1;
                 ec_clr     = 1;
                 flg_clr    = 1;
              end else begin
                 ec_en      = 1;
                 flg_set_up = 1;
              end
           end
        end
        VERI_INIT    : begin
           p1_op        = P1_SET_T;
           t_op         = T_VERI_SWAP;
           if(flg_op == ECDSA_SIGN) begin
              state_nxt    = SIGN_FIN;
              p1_en        = 1;
           end else begin
              state_nxt    = VERI_MAKE_UK;
              p1_en        = 1;
              t_en         = 1;
           end
        end
        VERI_MAKE_UK     : begin
           p1_op        = P1_SET_T;
           t_op         = T_VERI_SETU;
           ec_op        = EC_VERI_U;
           if(ec_rdy) begin
              if(flg_set) begin
                 state_nxt    = VERI_SET_U2K;
                 p1_en        = 1;
                 t_en         = 1;
                 flg_set_down = 1;
              end else begin
                 ec_en        = 1;
                 flg_set_up   = 1;
              end
           end
        end
        VERI_SET_U2K : begin
           state_nxt    = MONTGOMERY;
           k_op         = K_SET_U2;
           k_en         = 1;
           flg_2nd_down = 1;
        end
        VERI_CHK_2ND : begin
           p2_op        = P2_SET_T;
           ec_op        = EC_RTB;
           if(flg_2nd) begin
              state_nxt = VERI_P_ADD;
              p2_en     = 1;
           end else begin
              if(ec_rdy) begin
                 state_nxt = VERI_SET_U1K;
                 ec_en     = 1;
              end
           end
        end
        VERI_SET_U1K : begin
           p1_op        = P1_SET_M;
           p2_op        = P2_SET_M;
           t_op         = T_VERI_U2P;
           k_op         = K_SET_U1;
           if(ec_rdy) begin
              state_nxt    = CHK_K_READY;
              p1_en        = 1;
              p2_en        = 1;
              t_en         = 1;
              k_en         = 1;
              flg_2nd_up   = 1;
           end
        end
        VERI_P_ADD : begin
           ec_op        = EC_ADD;
           if(ec_rdy) begin
              state_nxt    = VERI_FINAL;
              ec_en        = 1;
              flg_2nd_down = 1;
           end
        end
        VERI_FINAL : begin
           t_op        = T_VERI_RES;
           ec_op       = EC_FIN_VERI;
           if(ec_rdy) begin
              if(flg_set) begin
                 state_nxt = IDLE;
                 t_en      = 1;
                 p1_clr    = 1;
                 p2_clr    = 1;
                 k_clr     = 1;
                 ec_clr    = 1;
                 flg_clr   = 1;
              end else begin
                 ec_en      = 1;
                 flg_set_up = 1;
              end
           end
        end
        ALL_CLR : begin
           state_nxt = IDLE;
           ec_clr       = 1;
           p1_clr       = 1;
           p2_clr       = 1;
           t_clr        = 1;
           k_clr        = 1;
           flg_clr      = 1;
        end
      endcase // case (state)
   end
endmodule // ecc_cu
