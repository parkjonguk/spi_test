//-----------------------------------------------------------------------------
// Title         : ARIA Sbox S2
// Project       : CA ARIA 1.1
//-----------------------------------------------------------------------------
// File          : aria_lt_s2.v
// Author        : Hae-young Kim  <ryoung0327@gmail.com>
// Created       : 01.11.2018
// Last modified : 08.12.2018
//-----------------------------------------------------------------------------
// Description :
//  ARIA Sbox S2 Module
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 01.11.2018 : created by Haeyoung Kim
// 08.12.2018 : code refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module aria_lt_s2 (/*AUTOARG*/
   // Outputs
   s2_dout,
   // Inputs
   s2_din
   ) ;
   input  [7:0] s2_din;
   output [7:0] s2_dout;

   wire [7:0]   s2_dout;

   wire [7:0]   gfi_i, gfi_o;

   assign       gfi_i = s2_din;

	 aria_lt_gfinv	GFINV(
                        .gfinv_din (gfi_i),
                        .gfinv_dout(gfi_o));

   assign	s2_dout[7] = ~gfi_o[6] ^ gfi_o[5] ^ gfi_o[3] ^ gfi_o[2] ^ gfi_o[1] ^ gfi_o[0];
	 assign	s2_dout[6] = ~gfi_o[7] ^ gfi_o[6] ^ gfi_o[2] ^ gfi_o[1];
	 assign	s2_dout[5] = ~gfi_o[6] ^ gfi_o[5] ^ gfi_o[4] ^ gfi_o[1] ^ gfi_o[0];
	 assign	s2_dout[4] =  gfi_o[7] ^ gfi_o[6] ^ gfi_o[1];
	 assign	s2_dout[3] =  gfi_o[7] ^ gfi_o[6] ^ gfi_o[1] ^ gfi_o[0];
	 assign	s2_dout[2] =  gfi_o[7] ^ gfi_o[5] ^ gfi_o[4] ^ gfi_o[2] ^ gfi_o[1] ^ gfi_o[0];
	 assign	s2_dout[1] = ~gfi_o[7] ^ gfi_o[6] ^ gfi_o[5] ^ gfi_o[4] ^ gfi_o[3] ^ gfi_o[2];
	 assign	s2_dout[0] =  gfi_o[7] ^ gfi_o[6] ^ gfi_o[5] ^ gfi_o[3] ^ gfi_o[1];

endmodule // aria_lt_s2
