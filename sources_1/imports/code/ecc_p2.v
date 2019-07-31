//-----------------------------------------------------------------------------
// Title         : ECC Core P2 Register
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : ecc_p2.v
// Author        : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 23.12.2018
// Last modified : 25.12.2018
//-----------------------------------------------------------------------------
// Description :
// ECC Core P2 Register
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 23.12.2018 : created by Haeyoung Kim
// 25.12.2018 : Function Verification Done and Code Refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module ecc_p2 (/*AUTOARG*/
   // Outputs
   ecp2_x, ecp2_y,
   // Inputs
   clk, rst_n, p2_op, p2_en, p2_clr, ecp3_xp, ecp3_yp, x, y
   ) ;
   input         clk, rst_n;
   input  [1:0]  p2_op;
   input         p2_en;
   input         p2_clr;

   input [255:0] ecp3_xp;
   input [255:0] ecp3_yp;

   input  [255:0] x, y;

   output [255:0] ecp2_x;
   output [255:0] ecp2_y;

   localparam P2_SET_N    = 2'b00;
   localparam P2_SET_M    = 2'b01;
   localparam P2_SET_T    = 2'b10;

   localparam P2_MX = 256'h62417dda94dd5719e7edccaddd889441d6ea57f17fb6d805e79cc35062a450f0;
   localparam P2_MY = 256'h15c7fc62962176154ba21a237487cc962d2ae390e867917377c94d5f3a55582a;

   reg [255:0]   ecp2_x, ecp2_x_nxt;
   reg [255:0]   ecp2_y, ecp2_y_nxt;

   always @ (*) begin
      case (p2_op)
        P2_SET_N  : ecp2_x_nxt = ecp3_xp;
        P2_SET_M  : ecp2_x_nxt = P2_MX;
        default : ecp2_x_nxt = x;
      endcase // case (p2_op)
   end

   always @ (*) begin
      case (p2_op)
        P2_SET_N  : ecp2_y_nxt = ecp3_yp;
        P2_SET_M  : ecp2_y_nxt = P2_MY;
        default : ecp2_y_nxt = y;
      endcase // case (p2_op)
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         ecp2_x   <= 256'd0;
         ecp2_y   <= 256'd0;
      end else begin
         if(p2_clr) begin
            ecp2_x   <= 256'd0;
            ecp2_y   <= 256'd0;
         end else if (p2_en) begin
            ecp2_x   <= ecp2_x_nxt;
            ecp2_y   <= ecp2_y_nxt;
         end
      end
   end

endmodule // ecc_p2
