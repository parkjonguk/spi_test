//-----------------------------------------------------------------------------
// Title         : Control Unit For Modular Arithmetic
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : mod_arith_cu.v
// Author        : Haeyoung Kim  <ryoung0327@hy-lab>
// Created       : 17.11.2018
// Last modified : 15.12.2018
//-----------------------------------------------------------------------------
// Description :
//  - Control Unit for Modular Arithmetic
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 17.11.2018 : created by Haeyoung Kim
// 15.12.2018 : Code refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module mod_arith_cu (/*AUTOARG*/
   // Outputs
   ready, inst_op, inst_en, a_op, a_en, b_op, b_en, v_op, v_en, u_op, u_en,
   opt_acca, opt_accv, v_clr, a_clr, opt_adsb, flg_mod,
   // Inputs
   clk, rst_n, op, en, clear, opt_mod, opt_accx, opt_accy, bp, bn, flg_povf,
   flg_novf, flg_mul, flg_s, v_busy, inst_nxt, inst_last
   ) ;
   input        clk;
   input        rst_n;

   input [2:0]  op;
   input        en;
   input        clear;

   input        opt_mod;
   input        opt_accx;
   input        opt_accy;

   output       ready;

   output [1:0] inst_op;
   output       inst_en;
   output [1:0] a_op;
   output       a_en;
   output [2:0] b_op;
   output       b_en;
   output [1:0] v_op;
   output       v_en;
   output [1:0] u_op;
   output       u_en;
   output       opt_acca;
   output       opt_accv;
   output       v_clr;
   output       a_clr;
   output [1:0] opt_adsb;

   input [1:0]  bp;
   input [1:0]  bn;
   input        flg_povf;
   input        flg_novf;
   input        flg_mul;
   input        flg_s;
   input        v_busy;

   input [1:0]  inst_nxt;
   input        inst_last;

   output       flg_mod;

   localparam X_MUL_Y       = 3'b000;
   localparam X_DIV_Y       = 3'b001;
   localparam X_MONT        = 3'b010;
   localparam X_MONT_INV    = 3'b011;
   localparam X_ADD_Y       = 3'b100;
   localparam X_SUB_Y       = 3'b101;
   localparam Y_SUB_X       = 3'b110;
   localparam X_RTB         = 3'b111;

   localparam INST_MUL_INIT = 2'b00;
   localparam INST_DIV_INIT = 2'b01;
   localparam INST_NEXT     = 2'b10;
   localparam INST_CLEAR    = 2'b11;

   localparam OP_A_SETX     = 2'b00;
   localparam OP_A_MHLV     = 2'b01;
   localparam OP_A_MQRTR    = 2'b10;
   localparam OP_A_ADSB     = 2'b11;

   localparam OP_B_SETY     = 3'b000;
   localparam OP_B_SETA     = 3'b001;
   localparam OP_B_SETU     = 3'b010;
   localparam OP_B_SETV     = 3'b011;
   localparam OP_B_DIVINIT  = 3'b100;
   localparam OP_B_MONT     = 3'b101;
   localparam OP_B_MONTINV  = 3'b110;
   localparam OP_B_CLEAR    = 3'b111;

   localparam OP_V_SETX     = 2'b00;
   localparam OP_V_TCAST    = 2'b01;
   localparam OP_V_SETU     = 2'b10;
   localparam OP_V_SWAP     = 2'b11;

   localparam OP_U_SETV     = 2'b00;
   localparam OP_U_MHLV     = 2'b01;
   localparam OP_U_MQRTR    = 2'b10;
   localparam OP_U_CLEAR    = 2'b11;

   localparam MQRTR         = 2'b00;
   localparam MHLV          = 2'b01;
   localparam MADD          = 2'b10;
   localparam MADD_SWP      = 2'b11;

   localparam IDLE          = 15'b000000000000001;
   localparam RTB           = 15'b000000000000010;
   localparam ADD_SUB       = 15'b000000000000100;
   localparam ADD_M1        = 15'b000000000001000;
   localparam SUB_M1        = 15'b000000000010000;
   localparam ADD_M2        = 15'b000000000100000;
   localparam SUB_M2        = 15'b000000001000000;
   localparam MUL_INIT      = 15'b000000010000000;
   localparam DIV_INIT      = 15'b000000100000000;
   localparam ST_MQRTR      = 15'b000001000000000;
   localparam ST_MHLV       = 15'b000010000000000;
   localparam ST_ADD_SWP    = 15'b000100000000000;
   localparam ST_FINAL      = 15'b001000000000000;
   localparam ST_FINISH     = 15'b010000000000000;
   localparam ST_CLEAR      = 15'b100000000000000;

   /* I/O Type */
   reg [1:0]    inst_op;
   reg          inst_en;
   reg [1:0]    a_op;
   reg          a_en;
   reg [2:0]    b_op;
   reg          b_en;
   reg [1:0]    v_op;
   reg          v_en;
   reg [1:0]    u_op;
   reg          u_en;
   reg          v_clr;
   reg          a_clr;
   reg          ready;
   reg          opt_acca;
   reg          opt_accv;
   reg          flg_mod;
   reg [1:0]    opt_adsb;

   /* Function : OP Latch */
   reg [2:0]    r_op;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         r_op          <= 3'd0;
         flg_mod     <= 0;
      end else begin
         if(clear) begin
            r_op          <= 3'd0;
            flg_mod     <= 0;
         end else if(ready) begin
            r_op          <= op;
            flg_mod     <= opt_mod;
         end
      end
   end

   wire [1:0] bin_b;
   assign     bin_b = bp - bn;

   /* FSM */
   reg [14:0] state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(clear) begin
            state <= ST_CLEAR;
         end else begin
            state <= state_nxt;
         end
      end
   end

   /* FSM State Transition */
   always @ (*) begin
      state_nxt    = state;
      inst_op    = 2'b00;
      inst_en    = 0;
      a_op       = 2'b00;
      a_en       = 0;
      b_op       = 3'b000;
      b_en       = 0;
      v_op       = 2'b00;
      v_en       = 0;
      u_op       = 2'b00;
      u_en       = 0;
      ready      = 0;
      opt_acca   = 0;
      opt_accv   = 0;
      opt_adsb   = 2'b00;
      a_clr      = 0;
      v_clr      = 0;
      case (state)
        IDLE: begin
           ready      = 1;
           if(en) begin
              if(op == X_DIV_Y) begin
                 state_nxt    = DIV_INIT;
              end else if(op == X_RTB) begin
                 state_nxt    = RTB;
              end else if(op[2]) begin
                 state_nxt    = ADD_SUB;
              end else begin
                 state_nxt    = MUL_INIT;
              end

              /* B Setup Control (Y) */
              if(op == X_MONT) begin
                 b_op      = OP_B_MONT;
                 b_en      = 1;
              end else if(op == X_MONT_INV) begin
                 b_op      = OP_B_MONTINV;
                 b_en      = 1;
              end else begin
                 b_op      = OP_B_SETY;
                 b_en      = !opt_accy;
              end

              a_en         = 1;
              a_op         = OP_A_SETX;
              opt_acca     = opt_accx;

              v_en         = 1;
              if(op == X_RTB) begin
                 v_op         = OP_V_TCAST;
              end else begin
                 v_op         = OP_V_SETX;
              end
              if((op != X_RTB) && (op[2] == 1'b1))
                opt_accv   = 1'b1;
              else
                opt_accv   = opt_accx;
           end
        end

        RTB: begin
           if(!v_busy) begin
              b_op     = OP_B_SETV;
              b_en     = 1;
              v_clr  = 1;
              a_clr  = 1;
              state_nxt  = IDLE;
           end
        end

        ADD_SUB: begin
           a_op     = OP_A_ADSB;
           a_en     = 1;
           opt_adsb = r_op[1:0];

           b_op     = OP_B_DIVINIT;
           b_en     = 1;

           if(flg_povf) begin
              state_nxt = SUB_M1;
           end else if(flg_novf) begin
              state_nxt = ADD_M1;
           end else begin
              state_nxt = ST_FINISH;
           end
        end
        ADD_M1: begin
           a_op     = OP_A_ADSB;
           a_en     = 1;
           opt_adsb = 2'b00;
           if(flg_povf) begin
              state_nxt = SUB_M2;
           end else if(flg_novf) begin
              state_nxt = ADD_M2;
           end else begin
              state_nxt = ST_FINISH;
           end
        end
        SUB_M1: begin
           a_op     = OP_A_ADSB;
           a_en     = 1;
           opt_adsb = 2'b01;
           if(flg_povf) begin
              state_nxt = SUB_M2;
           end else if(flg_novf) begin
              state_nxt = ADD_M2;
           end else begin
              state_nxt = ST_FINISH;
           end
        end
        ADD_M2: begin
           a_op     = OP_A_ADSB;
           a_en     = 1;
           opt_adsb = 2'b00;
           state_nxt = ST_FINISH;
        end
        SUB_M2: begin
           a_op     = OP_A_ADSB;
           a_en     = 1;
           opt_adsb = 2'b01;
           state_nxt = ST_FINISH;
        end
        MUL_INIT: begin
           a_op       = OP_A_SETX;
           a_en       = 1;
           opt_acca   = 1;

           u_op       = OP_U_CLEAR;
           u_en       = 1;
           inst_op    = INST_MUL_INIT;
           inst_en    = 1;
           if(inst_nxt == MADD_SWP)
             state_nxt = ST_ADD_SWP;
           else if(inst_nxt == MHLV)
             state_nxt = ST_MHLV;
           else
             state_nxt = ST_MQRTR;
        end

        DIV_INIT: begin
           a_op       = OP_A_SETX;
           a_en       = 1;
           opt_acca   = 1;

           b_op       = OP_B_DIVINIT;
           b_en       = 1;

           u_op       = OP_U_SETV;
           u_en       = 1;

           v_clr    = 1;

           inst_op    = INST_DIV_INIT;
           inst_en    = 1;

           if(inst_nxt == MADD_SWP)
             state_nxt = ST_ADD_SWP;
           else if(inst_nxt == MHLV)
             state_nxt = ST_MHLV;
           else
             state_nxt = ST_MQRTR;
        end

        ST_MQRTR: begin
           inst_op    = INST_NEXT;
           inst_en    = 1;
           a_op       = OP_A_MQRTR;
           a_en       = 1;
           u_op       = OP_U_MQRTR;
           u_en       = 1;
           if(inst_last) begin
              state_nxt = ST_FINAL;
           end else begin
              if(inst_nxt == MADD_SWP)
                state_nxt = ST_ADD_SWP;
              else if(inst_nxt == MHLV)
                state_nxt = ST_MHLV;
              else
                state_nxt = ST_MQRTR;
           end
        end
        ST_MHLV: begin
           inst_op    = INST_NEXT;
           inst_en    = 1;
           a_op       = OP_A_MHLV;
           a_en       = 1;
           u_op       = OP_U_MHLV;
           u_en       = 1;
           if(inst_last) begin
              state_nxt = ST_FINAL;
           end else begin
              if(inst_nxt == MADD_SWP)
                state_nxt = ST_ADD_SWP;
              else if(inst_nxt == MHLV)
                state_nxt = ST_MHLV;
              else
                state_nxt = ST_MQRTR;
           end
        end
        ST_ADD_SWP: begin
           inst_op    = INST_NEXT;
           inst_en    = 1;
           a_op       = OP_A_MQRTR;
           a_en       = 1;
           b_op       = OP_B_SETA;
           b_en       = 1;
           v_op       = OP_V_SETU;
           v_en       = 1;
           u_op       = OP_U_MQRTR;
           u_en       = 1;
           if(inst_last) begin
              state_nxt = ST_FINAL;
           end else begin
              if(inst_nxt == MADD_SWP)
                state_nxt = ST_ADD_SWP;
              else if(inst_nxt == MHLV)
                state_nxt = ST_MHLV;
              else
                state_nxt = ST_MQRTR;
           end
        end
        ST_FINAL: begin
           state_nxt = ST_FINISH;
           if(flg_mul) begin
              if(flg_s == 1'b1) begin
                 u_op       = OP_U_MHLV;
                 u_en       = 1;
              end
           end else begin
              if(bin_b == 2'b11) begin
                 v_op       = OP_V_SWAP;
                 v_en       = 1;
              end
           end
        end
        ST_FINISH: begin
           state_nxt = IDLE;
           inst_op    = INST_CLEAR;
           inst_en    = 1;
           a_clr    = 1;
           u_op       = OP_U_CLEAR;
           u_en       = 1;
           b_en       = 1;
           if(r_op[2]) begin
              b_op    = OP_B_SETA;
           end else if(r_op == X_DIV_Y) begin
              b_op    = OP_B_SETV;
           end else begin
              b_op    = OP_B_SETU;
           end
        end
        ST_CLEAR: begin
           state_nxt = IDLE;
           a_clr    = 1;
           v_clr    = 1;
           b_en     = 1;
           inst_en  = 1;
           b_op     = OP_B_CLEAR;
           inst_op  = INST_CLEAR;
        end
      endcase // case (state)
   end
endmodule // mod_arith_cu
