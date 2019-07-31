//-----------------------------------------------------------------------------
// Title         : EC Core Control Unit
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : ec_core_cu.v
// Author        : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 21.12.2018
// Last modified : 25.12.2018
//-----------------------------------------------------------------------------
// Description :
// EC Core Control Unit
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 21.12.2018 : created by Haeyoung
// 23.12.2018 : Spyglass Check by Haeyoung Kim
// 25.12.2018 : Function Verification Done and Code Refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module ec_core_cu (/*AUTOARG*/
   // Outputs
   ec_rdy, x_op, x_en, x_clr, y_op, y_en, y_clr, ma_op, ma_en, ma_clear,
   ma_opt_accx, ma_opt_accy, ma_opt_mod,
   // Inputs
   clk, rst_n, ec_op, ec_en, ec_clr, ma_rdy
   ) ;
   input        clk, rst_n;
   input  [2:0] ec_op;
   input        ec_en;
   input        ec_clr;

   output       ec_rdy;

   output [2:0] x_op;
   output       x_en;
   output       x_clr;

   output [2:0] y_op;
   output       y_en;
   output       y_clr;

   input        ma_rdy;

   output [2:0] ma_op;
   output       ma_en;
   output       ma_clear;
   output       ma_opt_accx;
   output       ma_opt_accy;
   output       ma_opt_mod;

   localparam EC_RTB        = 3'b000;
   localparam EC_VERI_U     = 3'b001;
   localparam EC_MONT       = 3'b010;
   localparam EC_MONT_INV   = 3'b011;
   localparam EC_ADD        = 3'b100;
   localparam EC_DBL        = 3'b101;
   localparam EC_FIN_SIGN   = 3'b110;
   localparam EC_FIN_VERI   = 3'b111;

   localparam X_SET_X       = 3'b000;
   localparam X_SET_SM      = 3'b001;
   localparam X_SET_ECP2X   = 3'b010;
   localparam X_SET_ECP2Y   = 3'b011;
   localparam X_SET_ECP1X   = 3'b100;
   localparam X_SET_ECP1Y   = 3'b101;
   localparam X_SET_CZ      = 3'b110;
   localparam X_SET_PZ      = 3'b111;

   localparam Y_SET_Y       = 3'b000;
   localparam Y_SET_S       = 3'b001;
   localparam Y_SET_2       = 3'b010;
   localparam Y_SET_A       = 3'b011;
   localparam Y_SET_T       = 3'b100;
   localparam Y_SET_CZ      = 3'b101;
   localparam Y_SET_ECP1X   = 3'b110;
   localparam Y_SET_ECP1Y   = 3'b111;

   localparam X_MUL_Y       = 3'b000;
   localparam X_DIV_Y       = 3'b001;
   localparam X_MONT        = 3'b010;
   localparam X_MONT_INV    = 3'b011;
   localparam X_ADD_Y       = 3'b100;
   localparam X_SUB_Y       = 3'b101;
   localparam Y_SUB_X       = 3'b110;
   localparam X_RTB         = 3'b111;



   reg          ec_rdy;
   reg [2:0]    x_op;
   reg          x_en;
   reg          x_clr;
   reg [2:0]    y_op;
   reg          y_en;
   reg          y_clr;
   reg [2:0]    ma_op;
   reg          ma_en;
   reg          ma_clear;
   reg          ma_opt_accx;
   reg          ma_opt_accy;
   reg          ma_opt_mod;

   /* FSM State */
   localparam IDLE            = 32'b00000000000000000000000000000001;
   localparam EC_CAST_OPY     = 32'b00000000000000000000000000000010;
   localparam EC_CAST_RTB     = 32'b00000000000000000000000000000100;
   localparam EC_CAST_OPX     = 32'b00000000000000000000000000001000;
   localparam EC_CAST_LAST    = 32'b00000000000000000000000000010000;
   localparam EC_ADD0         = 32'b00000000000000000000000000100000;
   localparam EC_ADD1         = 32'b00000000000000000000000001000000;
   localparam EC_ADD2         = 32'b00000000000000000000000010000000;
   localparam EC_ADD3         = 32'b00000000000000000000000100000000;
   localparam EC_DBL0         = 32'b00000000000000000000001000000000;
   localparam EC_DBL1         = 32'b00000000000000000000010000000000;
   localparam EC_DBL2         = 32'b00000000000000000000100000000000;
   localparam EC_DBL3         = 32'b00000000000000000001000000000000;
   localparam EC_DBL4         = 32'b00000000000000000010000000000000;
   localparam EC_DBL5         = 32'b00000000000000000100000000000000;
   localparam EC_ADDBL0       = 32'b00000000000000001000000000000000;
   localparam EC_ADDBL1       = 32'b00000000000000010000000000000000;
   localparam EC_ADDBL2       = 32'b00000000000000100000000000000000;
   localparam EC_ADDBL3       = 32'b00000000000001000000000000000000;
   localparam EC_ADDBL4       = 32'b00000000000010000000000000000000;
   localparam EC_ADDBL5       = 32'b00000000000100000000000000000000;
   localparam EC_ADDBL6       = 32'b00000000001000000000000000000000;
   localparam EC_FIN_SIGNT    = 32'b00000000010000000000000000000000;
   localparam EC_FIN_SIGN0    = 32'b00000000100000000000000000000000;
   localparam EC_FIN_SIGN1    = 32'b00000001000000000000000000000000;
   localparam EC_FIN_SIGN2    = 32'b00000010000000000000000000000000;
   localparam EC_FIN_SIGN3    = 32'b00000100000000000000000000000000;
   localparam EC_FIN_SIGN4    = 32'b00001000000000000000000000000000;
   localparam EC_FIN_SIGN5    = 32'b00010000000000000000000000000000;
   localparam EC_FIN_VERI0    = 32'b00100000000000000000000000000000;
   localparam EC_FIN_VERI1    = 32'b01000000000000000000000000000000;
   localparam EC_ALL_CLR      = 32'b10000000000000000000000000000000;



   /* OP FLAG */
   reg          flg_clr;
   reg [2:0]    flg_op;
   reg          flg_op_up;
   reg          flg_op_rtb;


   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_op  <= 3'd0;
      end else begin
         if(flg_clr) begin
            flg_op  <= 3'd0;
         end else if (flg_op_rtb) begin
            flg_op  <= X_RTB;
         end else if (flg_op_up) begin
            flg_op  <= ec_op;
         end
      end
   end

   /* MOD FLAG */
   reg          flg_mod;
   reg          flg_mod_up;
   reg          flg_mod_down;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_mod <= 1'b0;
      end else begin
         if(flg_mod_down | flg_clr) begin
            flg_mod <= 1'b0;
         end else if (flg_mod_up) begin
            flg_mod <= 1'b1;
         end
      end
   end

   /* RTB FLAG */
   reg          flg_rtb;
   reg          flg_rtb_up;
   reg          flg_rtb_down;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_rtb <= 1'b0;
      end else begin
         if(flg_rtb_down | flg_clr) begin
            flg_rtb <= 1'b0;
         end else if (flg_rtb_up) begin
            flg_rtb <= 1'b1;
         end
      end
   end


   /* LAST FLAG */
   reg          flg_last;
   reg          flg_last_up;
   reg          flg_last_down;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_last <= 1'b0;
      end else begin
         if(flg_last_down | flg_clr) begin
            flg_last <= 1'b0;
         end else if (flg_last_up) begin
            flg_last <= 1'b1;
         end
      end
   end

   /* FSM */

   reg [31:0]   state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(ec_clr) begin
            state <= EC_ALL_CLR;
         end else begin
            state <= state_nxt;
         end
      end
   end

   always @ (*) begin
      state_nxt      = state;
      ec_rdy         = 0;

      ma_op          = 3'b000;
      ma_opt_accx    = 0;
      ma_opt_accy    = 0;
      ma_en          = 0;
      ma_clear       = 0;
      ma_opt_mod     = 0;

      x_op           = 3'b000;
      x_en           = 0;
      x_clr          = 0;

      y_op           = 3'b000;
      y_en           = 0;
      y_clr          = 0;

      flg_clr        = 0;
      flg_op_up      = 0;
      flg_op_rtb     = 0;

      flg_last_up    = 0;
      flg_last_down  = 0;

      flg_mod_up     = 0;
      flg_mod_down   = 0;

      flg_rtb_up     = 0;
      flg_rtb_down   = 0;

      case (state)
        IDLE : begin
           ec_rdy     = 1;
           if(ec_en) begin
              /* EC INSTRUCTION STATE TRANSITION */
              if (ec_op == EC_ADD) begin
                 state_nxt = EC_ADD0;
              end else if (ec_op == EC_DBL) begin
                 state_nxt = EC_DBL0;
              end else if (ec_op == EC_FIN_SIGN) begin
                 state_nxt = EC_FIN_SIGNT;
              end else if (ec_op == EC_FIN_VERI) begin
                 state_nxt = EC_FIN_VERI0;
              end else begin
                 state_nxt = EC_CAST_OPY;
              end

              /* EC INSTRUCTION X INIT */
              if(ec_op == EC_ADD) begin
                 x_op        = X_SET_ECP2Y;
                 x_en        = 1;
              end else if (ec_op == EC_DBL) begin
                 x_op        = X_SET_ECP1X;
                 x_en        = 1;
              end else if (ec_op == EC_FIN_SIGN) begin
                 x_en        = 0;
              end else if (ec_op == EC_FIN_VERI) begin
                 x_en        = 0;
              end else begin
                 x_op        = X_SET_ECP1Y;
                 x_en        = 1;
              end

              /* EC INSTRUCTION Y INIT */
              if(ec_op == EC_ADD) begin
                 y_op        = Y_SET_ECP1Y;
                 y_en        = 1;
              end else if (ec_op == EC_DBL) begin
                 y_op        = Y_SET_ECP1X;
                 y_en        = 1;
              end else if (ec_op == EC_VERI_U) begin
                 y_op        = Y_SET_S;
                 y_en        = 1;
              end else if (ec_op == EC_FIN_VERI) begin
                 y_clr       = 1;
              end else if (ec_op == EC_FIN_SIGN) begin
                 y_clr       = 1;
              end

              /* EC LAST FLAG */
              flg_last_down   = 1;             // Make Sure ECP Down

              /* EC MOD FLAG */
              if(ec_op == EC_VERI_U) begin
                 flg_mod_up      = 1;          // EC_VERI_U In MOD 1 Range
              end else begin
                 flg_mod_down    = 1;          // Make Sure MOD Down
              end

              /* EC RSD To BIN FLAG */
              if(ec_op == EC_VERI_U) begin
                 flg_rtb_up      = 1;          // EC_VERI_U In Need RSD TO BIN OP
              end else begin
                 flg_rtb_down    = 1;          // Make Sure MOD Down
              end

              /* EC OP FLAG */
              if(ec_op == EC_RTB) begin
                 flg_op_rtb      = 1;          // RTB Operation Flag
              end else begin
                 flg_op_up       = 1;
              end
           end
        end


        /* EC CAST OPERATION */
        /* MONTGOMERY, MONTGOMERY INVERSION, RST TO BINARY, VERIFICATION U */
        EC_CAST_OPY : begin
           ma_op       = flg_op;
           ma_opt_mod  = flg_mod;
           x_op        = X_SET_ECP1X;
           if(ma_rdy) begin
              ma_en      = 1;
              x_en       = 1;
              if(flg_rtb) begin
                 state_nxt  = EC_CAST_RTB;
              end else begin
                 state_nxt  = EC_CAST_OPX;
              end
           end
        end
        EC_CAST_RTB : begin
           ma_op        = X_RTB;
           ma_opt_mod   = flg_mod;
           ma_opt_accx  = 1;
           if(ma_rdy) begin
              ma_en     = 1;
              if(flg_last) begin
                 state_nxt = EC_CAST_LAST;
              end else begin
                 state_nxt = EC_CAST_OPX;
              end
           end
        end
        EC_CAST_OPX : begin
           y_op         = Y_SET_CZ;
           ma_op        = flg_op;
           ma_opt_mod   = flg_mod;
           if(ma_rdy) begin
              ma_en          = 1;
              y_en           = 1;
              flg_last_up    = 1;
              if(flg_rtb) begin
                 state_nxt   = EC_CAST_RTB;
              end else begin
                 state_nxt   = EC_CAST_LAST;
              end
           end
        end
        EC_CAST_LAST : begin
           x_op       = X_SET_CZ;
           if(ma_rdy) begin
              state_nxt    = IDLE;
              ma_clear       = 1;
              x_en         = 1;
              flg_clr      = 1;
           end
        end

        /* P ADDITION */
        EC_ADD0 : begin
           ma_op       = X_SUB_Y;       // P2Y - P1Y
           x_op        = X_SET_ECP2X;
           y_op        = Y_SET_ECP1X;
           if(ma_rdy) begin
              state_nxt   = EC_ADD1;
              ma_en       = 1;
              x_en        = 1;
              y_en        = 1;
           end
        end
        EC_ADD1 : begin
           ma_op       = X_ADD_Y;       // P2X + P1X
           if(ma_rdy) begin
              state_nxt   = EC_ADD2;
              ma_en       = 1;
           end
        end
        EC_ADD2 : begin
           ma_op       = X_SUB_Y;       // P2X - P1X
           x_op        = X_SET_PZ;
           y_op        = Y_SET_CZ;
           if(ma_rdy) begin
              state_nxt   = EC_ADD3;
              ma_en       = 1;
              x_en        = 1;
              y_en        = 1;
           end
        end
        EC_ADD3 : begin                 // MONT_INV(P2X - P1X)
           ma_op       = X_MONT_INV;
           ma_opt_accx = 1;
           if(ma_rdy) begin
              state_nxt   = EC_ADDBL0;
              ma_en       = 1;
           end
        end

        /* P DOUBLING */
        EC_DBL0 : begin
           ma_op       = X_MUL_Y;
           if(ma_rdy) begin
              state_nxt   = EC_DBL1;
              ma_en       = 1;
           end
        end
        EC_DBL1 : begin
           ma_op       = X_ADD_Y;
           ma_opt_accx = 1;
           ma_opt_accy = 1;
           x_op        = X_SET_CZ;
           y_op        = Y_SET_A;
           if(ma_rdy) begin
              state_nxt   = EC_DBL2;
              ma_en       = 1;
              x_en        = 1;
              y_en        = 1;
           end
        end
        EC_DBL2 : begin
           ma_op       = X_ADD_Y;
           ma_opt_accy = 1;
           if(ma_rdy) begin
              state_nxt   = EC_DBL3;
              ma_en       = 1;
           end
        end
        EC_DBL3 : begin
           ma_op       = X_ADD_Y;
           ma_opt_accx = 1;
           x_op        = X_SET_ECP1X;
           y_op        = Y_SET_ECP1X;
           if(ma_rdy) begin
              state_nxt   = EC_DBL4;
              ma_en       = 1;
              x_en        = 1;
              y_en        = 1;
           end
        end
        EC_DBL4 : begin
           ma_op       = X_ADD_Y;
           x_op        = X_SET_ECP1Y;
           y_op        = Y_SET_2;
           if(ma_rdy) begin
              state_nxt   = EC_DBL5;
              ma_en       = 1;
              x_en        = 1;
              y_en        = 1;
           end
        end
        EC_DBL5 : begin
           ma_op       = X_MUL_Y;
           x_op        = X_SET_PZ;
           y_op        = Y_SET_CZ;
           if(ma_rdy) begin
              state_nxt   = EC_ADDBL0;
              ma_en       = 1;
              x_en        = 1;
              y_en        = 1;
           end
        end

        /* P ADDITION AND DOUBLING */
        EC_ADDBL0 : begin
           ma_op       = X_DIV_Y;
           ma_opt_accy = 1;
           if(ma_rdy) begin
              state_nxt   = EC_ADDBL1;
              ma_en       = 1;
           end
        end
        EC_ADDBL1 : begin
           ma_op       = X_MUL_Y;
           ma_opt_accx = 1;
           ma_opt_accy = 1;
           x_op        = X_SET_CZ;
           if(ma_rdy) begin
              state_nxt   = EC_ADDBL2;
              ma_en       = 1;
              x_en        = 1;
           end
        end
        EC_ADDBL2 : begin
           ma_op       = X_SUB_Y;
           ma_opt_accx = 1;
           y_op        = Y_SET_ECP1X;
           if(ma_rdy) begin
              state_nxt   = EC_ADDBL3;
              ma_en       = 1;
              y_en        = 1;
           end
        end
        EC_ADDBL3 : begin
           ma_op       = Y_SUB_X;
           ma_opt_accx = 1;
           y_op        = Y_SET_ECP1Y;
           if(ma_rdy) begin
              state_nxt   = EC_ADDBL4;
              ma_en       = 1;
              y_en        = 1;
           end
        end
        EC_ADDBL4 : begin
           ma_op       = X_MUL_Y;
           ma_opt_accy = 1;
           x_op        = X_SET_PZ;
           y_op        = Y_SET_ECP1Y;
           if(ma_rdy) begin
              state_nxt   = EC_ADDBL5;
              ma_en       = 1;
              x_en        = 1;
              y_en        = 1;
           end
        end
        EC_ADDBL5 : begin
           ma_op       = X_SUB_Y;
           ma_opt_accx = 1;
           if(ma_rdy) begin
              state_nxt   = EC_ADDBL6;
              ma_en       = 1;
           end
        end
        EC_ADDBL6 : begin
           y_op        = Y_SET_CZ;
           if(ma_rdy) begin
              state_nxt   = IDLE;
              y_en        = 1;
              ma_clear    = 1;
           end
        end

        ///
        /* EC SIGN FINAL */
        EC_FIN_SIGNT : begin
           if(ma_rdy) begin
              ma_en      = 1;
              if(flg_rtb) begin
                 state_nxt    = EC_FIN_SIGN0;
                 ma_op        = X_RTB;
                 ma_opt_accx  = 1;
                 flg_rtb_down = 1;
              end else begin
                 ma_op      = X_MONT_INV;
                 flg_rtb_up = 1;
              end
           end
        end
        EC_FIN_SIGN0 : begin
           ma_op         = X_ADD_Y;
           ma_opt_mod    = 1;
           ma_opt_accx   = 1;
           x_op          = X_SET_SM;
           if(ma_rdy) begin
              state_nxt  = EC_FIN_SIGN1;
              ma_en      = 1;
              x_en       = 1;
           end
        end
        EC_FIN_SIGN1 : begin
           ma_op         = X_MUL_Y;
           ma_opt_mod    = 1;
           ma_opt_accy   = 1;
           x_op          = X_SET_CZ;
           y_op          = Y_SET_ECP1X;
           if(ma_rdy) begin
              state_nxt    = EC_FIN_SIGN2;
              ma_en        = 1;
              x_en         = 1;
              y_en         = 1;
           end
        end
        EC_FIN_SIGN2 : begin
           ma_op         = X_MUL_Y;
           ma_opt_mod    = 1;
           ma_opt_accx   = 1;
           y_op          = Y_SET_ECP1Y;
           if(ma_rdy) begin
              state_nxt  = EC_FIN_SIGN3;
              ma_en      = 1;
              y_en       = 1;
           end
        end
        EC_FIN_SIGN3 : begin
           ma_op         = X_ADD_Y;
           ma_opt_mod    = 1;
           ma_opt_accx   = 1;
           y_op          = Y_SET_S;
           if(ma_rdy) begin
              state_nxt  = EC_FIN_SIGN4;
              ma_en      = 1;
              y_en       = 1;
           end
        end
        EC_FIN_SIGN4 : begin
           ma_op         = X_DIV_Y;
           ma_opt_mod    = 1;
           ma_opt_accx   = 1;
           if(ma_rdy) begin
              state_nxt  = EC_FIN_SIGN5;
              ma_en      = 1;
           end
        end
        EC_FIN_SIGN5 : begin
           ma_op         = X_RTB;
           ma_opt_accx   = 1;
           ma_opt_mod    = 1;
           if(ma_rdy) begin
              state_nxt      = EC_CAST_OPX;
              ma_en          = 1;
              flg_op_rtb     = 1;
              flg_rtb_down   = 1;
              flg_mod_up     = 1;
           end
        end

        /* EC VERIFICATION FINAL */
        EC_FIN_VERI0 : begin
           if(ma_rdy) begin
              if(flg_rtb) begin
                 state_nxt     = EC_FIN_VERI1;
                 ma_op         = X_RTB;
                 ma_en         = 1;
                 ma_opt_accx   = 1;
                 flg_rtb_down  = 1;
              end else begin
                 ma_op         = X_MONT_INV;
                 ma_en         = 1;
                 flg_rtb_up    = 1;
              end
           end
        end
        EC_FIN_VERI1 : begin
           ma_opt_accx   = 1;
           if(ma_rdy) begin
              ma_en      = 1;
              if(flg_rtb) begin
                 state_nxt     = EC_CAST_LAST;
                 ma_op         = X_RTB;
                 ma_opt_mod    = 1;
                 flg_rtb_down  = 1;
              end else begin
                 ma_op         = X_ADD_Y;
                 ma_opt_mod    = 1;
                 flg_rtb_up    = 1;
              end
           end
        end

        /* EC CLEAR */
        EC_ALL_CLR : begin
           state_nxt   = IDLE;
           ma_clear    = 1;
           x_clr       = 1;
           y_clr       = 1;
           flg_clr     = 1;
        end
        default : begin
           state_nxt = EC_ALL_CLR;
        end
      endcase // case (state)
   end

endmodule // ec_core_cu


