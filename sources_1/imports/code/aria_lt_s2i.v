//-----------------------------------------------------------------------------
// Title         : ARIA Sbox S2 Inversion
// Project       : CA ARIA 1.1
//-----------------------------------------------------------------------------
// File          : aria_lt_s2i.v
// Author        : Hae-young Kim  <ryoung0327@gmail.com>
// Created       : 01.11.2018
// Last modified : 08.12.2018
//-----------------------------------------------------------------------------
// Description :
//  ARIA Sbox S2 Inversion Module
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 01.11.2018 : created by Haeyoung Kim
// 08.12.2018 : code refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module aria_lt_s2i (/*AUTOARG*/
   // Outputs
   s2i_dout,
   // Inputs
   s2i_din
   ) ;
   input  [7:0] s2i_din;
   output [7:0] s2i_dout;

   wire [7:0]   gfi_i, gfi_o;

   assign	gfi_i[7] =  s2i_din[7] ^ s2i_din[6] ^ s2i_din[3] ^ s2i_din[0];
	 assign	gfi_i[6] =  s2i_din[7] ^ s2i_din[5] ^ s2i_din[4] ^ s2i_din[3] ^ s2i_din[2] ^ s2i_din[0];
	 assign	gfi_i[5] = ~s2i_din[7] ^ s2i_din[6] ^ s2i_din[4] ^ s2i_din[2] ^ s2i_din[1];
	 assign	gfi_i[4] =  s2i_din[5] ^ s2i_din[4] ^ s2i_din[2] ^ s2i_din[1] ^ s2i_din[0];
	 assign	gfi_i[3] = ~s2i_din[7] ^ s2i_din[6] ^ s2i_din[2] ^ s2i_din[1] ^ s2i_din[0];
	 assign	gfi_i[2] = ~s2i_din[6] ^ s2i_din[4];
	 assign	gfi_i[1] =  s2i_din[6] ^ s2i_din[5] ^ s2i_din[2];
	 assign	gfi_i[0] =  s2i_din[3] ^ s2i_din[4];

	 aria_lt_gfinv	GFINV(
                        .gfinv_din(gfi_i),
                        .gfinv_dout(gfi_o));

   assign s2i_dout = gfi_o;

endmodule // aria_lt_s2i

