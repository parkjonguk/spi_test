//-----------------------------------------------------------------------------
// Title         : V Register For Modular Arithmetic
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : mod_arith_v.v
// Author        : Haeyoung Kim  <ryoung0327@gmail.com>
// Created       : 14.11.2018
// Last modified : 15.12.2018
//-----------------------------------------------------------------------------
// Description :
//  - V Register Module for ECC Modular Arithmetic Function
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 14.11.2018 : created by Haeyoung Kim
// 17.11.2018 : Spyglass Check Done by Haeyoung Kim
// 15.12.2018 : Code refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module mod_arith_v (/*AUTOARG*/
   // Outputs
   v_busy, vp, vn,
   // Inputs
   clk, rst_n, v_op, v_en, v_clr, opt_accv, flg_mod, xp, xn, up, un, bp, bn
   ) ;
   /* I/O */
   input          clk, rst_n;

   input [1:0]    v_op;
   input          v_en;
   input          v_clr;           // Using Sync Reset(Clear)

   input          opt_accv;
   input          flg_mod;

   input  [255:0] xp, xn;
   input  [255:0] up, un;
   input  [255:0] bp, bn;

   output         v_busy;
   output [255:0] vp;
   output [255:0] vn;

   /* Local Parameter */
   localparam OP_V_SETX   = 2'b00;
   localparam OP_V_TCAST  = 2'b01;
   localparam OP_V_SETU   = 2'b10;
   localparam OP_V_SWAP   = 2'b11;

   localparam MP0         = 256'hFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF;
   localparam MP1         = 256'hFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551;

   /* Output Type */
   reg [255:0]    vp;
   reg [255:0]    vn;
   wire           v_busy;

   /* Control Unit I/O */
   wire           rtb_add, rtb_busy, rtb_last;
   wire           rtb_carry, rtb_carry_nxt;
   wire           rtb_start;

   assign         v_busy = rtb_busy;

   /* Function : Accumulation Mode Selector */
   wire [255:0]   sel_xp, sel_xn;

   assign sel_xp    = (opt_accv == 1'b1) ? bp : xp;
   assign sel_xn    = (opt_accv == 1'b1) ? bn : xn;

   /* Function : v_op input selector */
   reg [255:0]    vp_op;
   reg [255:0]    vn_op;

   always @ (*) begin
      case (v_op)
        OP_V_SETX  : vp_op = sel_xp;
        OP_V_TCAST : vp_op = sel_xp;
        OP_V_SETU  : vp_op = up;
        OP_V_SWAP  : vp_op = vn;
      endcase // case (v_op)
   end

   always @ (*) begin
      case (v_op)
        OP_V_SETX  : vn_op = sel_xn;
        OP_V_TCAST : vn_op = sel_xn;
        OP_V_SETU  : vn_op = un;
        OP_V_SWAP  : vn_op = vp;
      endcase // case (v_op)
   end

   /* Function : RSD TO BIN 32 */
   wire [32:0]   pn_add;
   wire [32:0]   pn_sub;
   wire [31:0]   bin_nxt;

   assign pn_sub        = {1'b0, vp[31:0]} - vn[31:0] - rtb_carry;
   assign pn_add        = {1'b0, vp[31:0]} + vn[31:0] + rtb_carry;
   assign bin_nxt       = (rtb_add == 1'b1) ? pn_add[31:0] : pn_sub[31:0];
   assign rtb_carry_nxt = (rtb_add == 1'b1) ? pn_add[32]   : pn_sub[32];

   /* Function : Modular Range Selector */
   wire [255:0]  modular;
   assign modular   = (flg_mod == 1'b1) ? MP1 : MP0;

   /* Function : RTB Result */
   wire          modset;
   wire [255:0]  vp_rtb;
   wire [255:0]  vn_rtb;

   assign modset   = rtb_last & rtb_carry_nxt & !rtb_add;
   assign vp_rtb   = {bin_nxt, vp[255:32]};
   assign vn_rtb   = modset ? modular : {32'd0, vn[255:32]};

   /* Function : SELECT NEXT */
   wire [255:0]  vp_nxt, vn_nxt;
   assign vp_nxt = rtb_busy ? vp_rtb : vp_op;
   assign vn_nxt = rtb_busy ? vn_rtb : vn_op;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         vp <= 256'd0;
         vn <= 256'd0;
      end else begin
         if(v_clr) begin
            vp <= 256'd0;
            vn <= 256'd0;
         end else if(v_en | rtb_busy) begin
            vp <= vp_nxt;
            vn <= vn_nxt;
         end
      end
   end

   /* Contol Unit for RSD to Binary */
   assign rtb_start = v_en & (v_op == OP_V_TCAST);

   rsd_tbin_cu CU (
                     .rtb_clear         (v_clr),
                     /*AUTOINST*/
                     // Outputs
                     .rtb_carry         (rtb_carry),
                     .rtb_add           (rtb_add),
                     .rtb_busy          (rtb_busy),
                     .rtb_last          (rtb_last),
                     // Inputs
                     .clk               (clk),
                     .rst_n             (rst_n),
                     .rtb_start         (rtb_start),
                     .rtb_carry_nxt     (rtb_carry_nxt));

endmodule // mod_arith_v

module rsd_tbin_cu (/*AUTOARG*/
   // Outputs
   rtb_carry, rtb_add, rtb_busy, rtb_last,
   // Inputs
   clk, rst_n, rtb_start, rtb_clear, rtb_carry_nxt
   ) ;
   input       clk, rst_n;

   input       rtb_start;
   input       rtb_clear;
   input       rtb_carry_nxt;

   output      rtb_carry;
   output      rtb_add;
   output      rtb_busy;
   output      rtb_last;

   /* FSM STATE */
   localparam IDLE        = 3'b001;
   localparam RTB         = 3'b010;
   localparam UFLOW       = 3'b100;

   /* OUTPUT TYPE */
   reg         rtb_carry;
   reg         rtb_add;
   reg         rtb_busy;
   wire        rtb_last;

   /* Internal Counter Module */
   reg  [2:0]   cnt;
   wire [2:0]   cnt_nxt;

   assign cnt_nxt      = cnt + 1;
   assign rtb_last     = (cnt == 3'b111) ? 1 : 0;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         cnt <= 3'd0;
      end else begin
         if(rtb_start | rtb_clear) begin
            cnt <= 3'd0;
         end else if(rtb_busy) begin
            cnt <= cnt_nxt;
         end
      end
   end

   /* Carry Register */
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         rtb_carry <= 1'b0;
      end else begin
         if(rtb_last | rtb_clear | rtb_start) begin
            rtb_carry <= 1'b0;
         end else if (rtb_busy) begin
            rtb_carry <= rtb_carry_nxt;
         end
      end
   end

   /* FSM Register */
   reg   [2:0] state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state  <= IDLE;
      end else begin
         state  <= state_nxt;
      end
   end

   /* FSM STATE Transition */
   always @ (*) begin
      state_nxt = state;
      rtb_add   = 0;
      rtb_busy  = 0;
      case (state)
        IDLE : begin
           if(rtb_start & !rtb_clear)
              state_nxt = RTB;
        end
        RTB : begin
           rtb_busy   = 1;
           if(rtb_clear) begin
              state_nxt = IDLE;
           end else if(rtb_last) begin
              if(rtb_carry_nxt) begin
                 state_nxt = UFLOW;
              end else begin
                 state_nxt = IDLE;
              end
           end
        end
        UFLOW : begin
           rtb_busy   = 1;
           rtb_add    = 1;
           if(rtb_clear | rtb_last)
              state_nxt = IDLE;
        end
      endcase // case (state)
   end

endmodule // rsd_tbin_cu



