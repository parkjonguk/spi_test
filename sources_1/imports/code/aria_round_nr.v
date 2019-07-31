//-----------------------------------------------------------------------------
// Title         : ARIA Number of Round Module
// Project       : ARIA 1.1
//-----------------------------------------------------------------------------
// File          : aria_round_nr.v
// Author        : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 12.12.2018
// Last modified : 14.12.2018
//-----------------------------------------------------------------------------
// Description :
// ARIA Round Nr Module
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 12.12.2018 : created by Haeyoung Kim
// 14.12.2018 : Code Refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module aria_round_nr (/*AUTOARG*/
   // Outputs
   flg_klast, flg_rlast, flg_ltinv,
   // Inputs
   clk, rst_n, nr_clr, nr_en, st_ksize
   ) ;
   input        clk, rst_n;

   input        nr_clr;
   input        nr_en;

   input  [1:0] st_ksize;

   output       flg_klast;
   output       flg_rlast;
   output       flg_ltinv;

   /* Output Type */
   wire         flg_klast;
   wire         flg_ltinv;
   reg          flg_rlast;

   reg [3:0]    nr;

   wire [3:0]   nr_nxt;
   assign       nr_nxt = nr + 4'd1;

   wire         blk_128_last;
   wire         blk_192_last;
   wire         blk_256_last;


   assign       blk_128_last = (nr == 4'd11) ? 1 : 0;
   assign       blk_192_last = (nr == 4'd13) ? 1 : 0;
   assign       blk_256_last = (nr == 4'd15) ? 1 : 0;
   assign       flg_klast    = (nr == 4'd3)  ? 1 : 0;
   assign       flg_ltinv    = nr[0];

   always @ (*) begin
      case (st_ksize)
        2'b00 : flg_rlast = 1'b1;
        2'b01 : flg_rlast = blk_128_last;
        2'b10 : flg_rlast = blk_192_last;
        2'b11 : flg_rlast = blk_256_last;
      endcase // case (st_ksize)
   end


   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         nr <= 4'd0;
      end else begin
         if(nr_clr) begin
            nr <= 4'd0;
         end else if(nr_en) begin
            nr <= nr_nxt;
         end
      end
   end

endmodule // aria_round_nr
