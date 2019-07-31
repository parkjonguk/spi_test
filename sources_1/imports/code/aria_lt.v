//-----------------------------------------------------------------------------
// Title         : aria_lt
// Project       : ARIA 1.1
//-----------------------------------------------------------------------------
// File          : aria_lt.v
// Author        : Bonyul Gu <bonyul13@gmail.com>
//               : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 02.11.2018
// Last modified : 08.12.2018
//-----------------------------------------------------------------------------
// Description :
// ARIA LT Module Using Sbox S1, S2, S1_INV, S2_INV
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 02.11.2018 : created by Bonyul Gu
// 06.11.2018 : modify ver1 by Bonyul Gu
// 08.12.2018 : code refactoring by Haeyoung Kim
//------------------------------------------------------------------------------
module aria_lt (/*AUTOARG*/
   // Outputs
   lt_dout,
   // Inputs
   lt_din, lt_conf_inv
   ) ;
   /* I/O */
   input [31:0]   lt_din;
   input          lt_conf_inv;
   output [31:0]  lt_dout;

   wire [31:0]    lt_dout;
   wire [31:0]    s_nm_i, s_inv_i;
   wire [31:0]    s_nm_o, s_inv_o;

   wire [7:0]     s1_i, s2_i, s1i_i, s2i_i;
   wire [7:0]     s1_o, s2_o, s1i_o, s2i_o;

   /* Select sbox input */
   assign s_nm_i  = lt_din;
   assign s_inv_i = {lt_din[15:0], lt_din[31:16]};

   assign {s1_i, s2_i, s1i_i, s2i_i} = lt_conf_inv ? s_inv_i : s_nm_i;


   /* Sbox Operation */
   aria_lt_s1  S1  (
                    .s1_dout  (s1_o),
                    .s1_din   (s1_i));

   aria_lt_s2  S2  (
                    .s2_dout  (s2_o),
                    .s2_din   (s2_i));

   aria_lt_s1i S1I (
                    .s1i_dout (s1i_o),
                    .s1i_din  (s1i_i));

   aria_lt_s2i S2I (
                    .s2i_dout (s2i_o),
                    .s2i_din  (s2i_i));

   /* Output Selector */
   assign s_nm_o    = {s1_o, s2_o, s1i_o, s2i_o};
   assign s_inv_o   = {s1i_o, s2i_o, s1_o, s2_o};

   assign lt_dout   = lt_conf_inv ? s_inv_o : s_nm_o;

endmodule // aria_lt
