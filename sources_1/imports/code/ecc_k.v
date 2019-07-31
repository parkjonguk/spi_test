//-----------------------------------------------------------------------------
// Title         : ECC Core K Register
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : ecc_k.v
// Author        : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 23.12.2018
// Last modified : 25.12.2018
//-----------------------------------------------------------------------------
// Description :
// ECC Core K Register
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 23.12.2018 : created by Haeyoung Kim
// 25.12.2018 : Function Verification Done and Code Refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module ecc_k (/*AUTOARG*/
   // Outputs
   k_rdy, flg_ec_add, flg_ec_last,
   // Inputs
   clk, rst_n, in_kr, x, y, k_op, k_en, k_clr
   ) ;
   input          clk, rst_n;
   input [255:0]  in_kr;
   input [255:0]  x, y;

   input [1:0]    k_op;
   input          k_en;
   input          k_clr;

   output         k_rdy;
   output         flg_ec_add;
   output         flg_ec_last;

   localparam K_SET_K  = 2'b00;
   localparam K_SET_U1 = 2'b01;
   localparam K_SET_U2 = 2'b10;
   localparam K_NEXT   = 2'b11;

   localparam IDLE     = 2'b01;
   localparam INIT     = 2'b10;

   reg            k_rdy;
   wire           flg_ec_add;
   wire           flg_ec_last;

   reg [255:0]    k;
   reg [255:0]    k_nxt;
   reg [8:0]      cnt;


   assign flg_ec_add  = k[255];
   assign flg_ec_last = cnt[8];

   reg [1:0]      state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(k_clr) begin
            state <= IDLE;
         end else begin
            state <= state_nxt;
         end
      end
   end

   reg [1:0]      op;
   reg            op_en;
   reg            cnt_init;

   always @ (*) begin
      state_nxt  = state;
      op         = 2'b00;
      op_en      = 0;
      cnt_init   = 0;
      k_rdy      = 0;
      case (state)
        IDLE : begin
           k_rdy    = 1;
           if(k_en) begin
              op    = k_op;
              op_en = 1;
              if(k_op != K_NEXT) begin
                 state_nxt = INIT;
                 cnt_init  = 1;
              end
           end
        end
        INIT : begin
           op        = K_NEXT;
           op_en     = 1;
           if(k[255]) begin
              state_nxt = IDLE;
           end
        end
      endcase
   end

   wire [255:0]   k_n;
   wire [8:0]     cnt_add;
   wire [8:0]     cnt_op;

   assign k_n     = k[255] ? {1'b0, k[254:0]} : {k[254:0], 1'b0};
   assign cnt_add = cnt + 9'd1;
   assign cnt_op  = k[255] ? cnt : cnt_add;

   always @ (*) begin
      case (op)
        K_SET_K  : k_nxt = in_kr;
        K_SET_U1 : k_nxt = x;
        K_SET_U2 : k_nxt = y;
        K_NEXT   : k_nxt = k_n;
      endcase // case (k_op)
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         k  <= 256'd0;
      end else begin
         if(k_clr) begin
            k  <= 256'd0;
         end else if(op_en) begin
            k  <= k_nxt;
         end
      end
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         cnt  <= 9'd0;
      end else begin
         if(k_clr) begin
            cnt  <= 9'd0;
         end else if(cnt_init) begin
            cnt  <= 9'd1;
         end else if(op_en) begin
            cnt  <= cnt_op;
         end
      end
   end

endmodule // ecc_k






