//-----------------------------------------------------------------------------
// Title         : ARIA Key Register
// Project       : ARIA 1.1
//-----------------------------------------------------------------------------
// File          : aria_key.v
// Author        : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 10.12.2018
// Last modified : 15.12.2018
//-----------------------------------------------------------------------------
// Description :
// ARIA Key Register
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 10.12.2018 : created by Haeyoung Kim
// 14.12.2018 : code refactoring by Haeyoung Kim
// 15.12.2018 : Minor Error Fixed, Add Key Size Warning signal
//-----------------------------------------------------------------------------
module aria_key (/*AUTOARG*/
   // Outputs
   st_ksize, warn_ksize, w0, w1, w2, w3,
   // Inputs
   clk, rst_n, key, l1, key_op, key_en, key_clr
   ) ;
   input          clk, rst_n;
   input [255:0]  key;
   input [127:0]  l1;

   input [1:0]    key_op;
   input          key_en;
   input          key_clr;

   output [1:0]   st_ksize;
   output         warn_ksize;
   output [127:0] w0, w1, w2, w3;

   /* L1 Operation Code */
   localparam KEY_EXPAND  = 2'b00;
   localparam KEY_SET_128 = 2'b01;
   localparam KEY_SET_192 = 2'b10;
   localparam KEY_SET_256 = 2'b11;

   /* Output Type */
   wire   [127:0] w0, w1, w2, w3;

   /* Internal Register */
   reg [511:0]    tk, tk_nxt;

   reg [1:0]      st_ksize;
   reg            warn_ksize;

   assign {w0, w1, w2, w3} = tk;

   always @ (*) begin : MX_KEY
      case (key_op)
        2'b00 : tk_nxt = {tk[383:0], l1};
        2'b01 : tk_nxt = {256'd0, key[255:128], 128'd0};
        2'b10 : tk_nxt = {256'd0, key[255:64], 64'd0};
        2'b11 : tk_nxt = {256'd0, key};
      endcase // case (key_op)
   end

   wire   st_en;
   assign st_en = key_en & (key_op != 2'b00);

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         st_ksize <= 2'd0;
      end else begin
         if(key_clr) begin
            st_ksize <= 2'd0;
         end else if(st_en) begin
            st_ksize <= key_op;
         end
      end
   end

   wire   warn_en, flag_warn, warn_128, warn_192, warn_clr;

   assign warn_en    = key_en & (key_op[0] ^ key_op[1]);
   assign warn_clr   = key_en & (key_op == 2'b11);
   assign warn_128   = (key[127:0] == 128'd0) ? 0 : 1;
   assign warn_192   = (key[63:0]  == 64'd0)  ? 0 : 1;
   assign flag_warn  = key_op[1] ? warn_192 : warn_128;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         warn_ksize <= 1'b0;
      end else begin
         if(key_clr | warn_clr) begin
            warn_ksize <= 1'b0;
         end else if (warn_en) begin
            warn_ksize <= flag_warn;
         end
      end
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         tk <= 512'd0;
      end else begin
         if(key_clr) begin
            tk <= 512'd0;
         end else if(key_en) begin
            tk <= tk_nxt;
         end
      end
   end

endmodule // aria_key
