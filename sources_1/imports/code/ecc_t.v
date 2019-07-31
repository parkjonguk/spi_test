//-----------------------------------------------------------------------------
// Title         : ECC Core T Register
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : ecc_t.v
// Author        : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 23.12.2018
// Last modified : 25.12.2018
//-----------------------------------------------------------------------------
// Description :
// ECC Core T Register
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 23.12.2018 : created by Haeyoung Kim
// 25.12.2018 : Function Verification Done and Code Refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module ecc_t (/*AUTOARG*/
   // Outputs
   x, y, s,
   // Inputs
   clk, rst_n, t_op, t_en, t_clr, ecp1_xp, ecp1_yp, ecp3_xp, ecp3_yp, in_kr,
   in_ds, hash_msg
   ) ;
   input          clk, rst_n;
   input [2:0]    t_op;
   input          t_en;
   input          t_clr;

   input [255:0]  ecp1_xp;
   input [255:0]  ecp1_yp;

   input [255:0]  ecp3_xp;
   input [255:0]  ecp3_yp;

   input [255:0]  in_kr;
   input [255:0]  in_ds;
   input [255:0]  hash_msg;

   output [255:0] x, y, s;

   localparam T_ECDH_RES    = 3'b000;
   localparam T_VERI_INIT   = 3'b001;
   localparam T_VERI_SWAP   = 3'b010;
   localparam T_VERI_SETU   = 3'b011;
   localparam T_VERI_U2P    = 3'b100;
   localparam T_VERI_RES    = 3'b101;
   localparam T_SIGN_INIT   = 3'b110;
   localparam T_SIGN_RES    = 3'b111;

   reg [255:0]    x, x_nxt;
   reg [255:0]    y, y_nxt;
   reg [255:0]    s, s_nxt;

   wire           ecdsa_veri;
   assign         ecdsa_veri = (s == ecp3_xp) ? 1'b1 : 1'b0;

   always @ (*) begin
      case (t_op)
        T_ECDH_RES  : begin
           x_nxt = ecp3_xp;
           y_nxt = ecp3_yp;
           s_nxt = 256'd0;
        end
        T_VERI_INIT : begin
           x_nxt = hash_msg;
           y_nxt = in_kr;
           s_nxt = in_ds;
        end
        T_VERI_SWAP : begin
           x_nxt = ecp1_xp;
           y_nxt = ecp1_yp;
           s_nxt = s;
        end
        T_VERI_SETU : begin
           x_nxt = ecp3_xp;
           y_nxt = ecp3_yp;
           s_nxt = ecp1_yp;
        end
        T_VERI_U2P : begin
           x_nxt = ecp3_xp;
           y_nxt = ecp3_yp;
           s_nxt = s;
        end
        T_VERI_RES  : begin
           x_nxt = ecp3_xp;
           y_nxt = {255'd0, ecdsa_veri};
           s_nxt = 256'd0;
        end
        T_SIGN_INIT : begin
           x_nxt = in_ds;
           y_nxt = hash_msg;
           s_nxt = in_kr;
        end
        T_SIGN_RES : begin
           x_nxt = ecp3_xp;
           y_nxt = ecp3_yp;
           s_nxt = 256'd0;
        end
      endcase // case (t_op)
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         x <= 256'd0;
         y <= 256'd0;
         s <= 256'd0;
      end else begin
         if(t_clr) begin
            x <= 256'd0;
            y <= 256'd0;
            s <= 256'd0;
         end else if (t_en) begin
            x <= x_nxt;
            y <= y_nxt;
            s <= s_nxt;
         end
      end
   end



endmodule // ecc_t
