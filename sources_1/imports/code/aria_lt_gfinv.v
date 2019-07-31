//-----------------------------------------------------------------------------
// Title         : ARIA GF Inversion
// Project       : CA ARIA 1.1
//-----------------------------------------------------------------------------
// File          : aria_lt_gfinv.v
// Author        : Hae-young Kim  <ryoung0327@gmail.com>
// Created       : 01.11.2018
// Last modified : 08.12.2018
//-----------------------------------------------------------------------------
// Description :
//  ARIA GF Inversion Module
//  This Module will be used at sbox
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 01.11.2018 : created by Haeyoung Kim
// 08.12.2018 : code refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module aria_lt_gfinv (/*AUTOARG*/
   // Outputs
   gfinv_dout,
   // Inputs
   gfinv_din
   ) ;
   input  [7:0] gfinv_din;
   output [7:0] gfinv_dout;

   wire [7:0]   gfinv_dout;

   wire [3:0]   ah, al, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, ahp, alp;
   wire         tmp8a;

   // Step1. Convert din to ah, al
   //        this step called map operation
   assign ah[3] = gfinv_din[5] ^ gfinv_din[7];
   assign ah[2] = gfinv_din[2] ^ gfinv_din[3] ^ gfinv_din[5] ^ gfinv_din[7];
   assign ah[1] = gfinv_din[1] ^ gfinv_din[7] ^ gfinv_din[4] ^ gfinv_din[6];
   assign ah[0] = gfinv_din[4] ^ gfinv_din[6] ^ gfinv_din[5];

   assign al[3] = gfinv_din[2] ^ gfinv_din[4];
   assign al[2] = gfinv_din[1] ^ gfinv_din[7];
   assign al[1] = gfinv_din[1] ^ gfinv_din[2];
   assign al[0] = gfinv_din[0] ^ gfinv_din[5] ^ gfinv_din[4] ^ gfinv_din[6];

   // Step 2-1. Square ah
   // input: ah, output: tmp1
   assign tmp1[3] = ah[3];
   assign tmp1[2] = ah[1] ^ ah[3];
   assign tmp1[1] = ah[2];
   assign tmp1[0] = ah[0] ^ ah[2];

   // Step 2-1'. multiply with {e}
   // input: tmp1, output: tmp2
   assign tmp2[3] = tmp1[0] ^ tmp1[1] ^ tmp1[2] ^ tmp1[3];
   assign tmp2[2] = tmp1[0] ^ tmp1[1] ^ tmp1[2];
   assign tmp2[1] = tmp1[0] ^ tmp1[1];
   assign tmp2[0] = tmp1[1] ^ tmp1[2] ^ tmp1[3];

   // Step 2-2. Square al
   // input: al, output: tmp3
   assign tmp3[3] = al[3];
   assign tmp3[2] = al[1] ^ al[3];
   assign tmp3[1] = al[2];
   assign tmp3[0] = al[0] ^ al[2];

   // Step 2-3. Multiply ah & al
   // input: ah & al, output: tmp4
   assign tmp4[3] = (ah[3] & al[0]) ^ (ah[2] & al[1]) ^ (ah[1] & al[2]) ^ ((ah[0] ^ ah[3]) & al[3]);
   assign tmp4[2] = (ah[2] & al[0]) ^ (ah[1] & al[1]) ^ ((ah[0] ^ ah[3]) & al[2]) ^ ((ah[2] ^ ah[3]) & al[3]);
   assign tmp4[1] = (ah[1] & al[0]) ^ ((ah[0] ^ ah[3]) & al[1]) ^ ((ah[2] ^ ah[3]) & al[2]) ^ ((ah[1] ^ ah[2]) & al[3]);
   assign tmp4[0] = (ah[0] & al[0]) ^ (ah[3] & al[1]) ^ (ah[2] & al[2]) ^ (ah[1] & al[3]);


   // Step 2-4. ^ ah & al
   // input: ah & al, output: tmp5
   assign tmp5[3] = ah[3] ^ al[3];
   assign tmp5[2] = ah[2] ^ al[2];
   assign tmp5[1] = ah[1] ^ al[1];
   assign tmp5[0] = ah[0] ^ al[0];

   // Step 3. ^ tmp2 & tmp3
   // input: tmp2 & tmp3, output: tmp6
   assign tmp6[3] = tmp2[3] ^ tmp3[3];
   assign tmp6[2] = tmp2[2] ^ tmp3[2];
   assign tmp6[1] = tmp2[1] ^ tmp3[1];
   assign tmp6[0] = tmp2[0] ^ tmp3[0];


   // Step 4. ^ tmp4 & tmp6
   // input: tmp4 & tmp6, output: tmp7
   assign tmp7[3] = tmp4[3] ^ tmp6[3];
   assign tmp7[2] = tmp4[2] ^ tmp6[2];
   assign tmp7[1] = tmp4[1] ^ tmp6[1];
   assign tmp7[0] = tmp4[0] ^ tmp6[0];

   // Step 5. Inverse tmp7
   // input: tmp7, output: tmp8
   assign tmp8a   = tmp7[1] ^ tmp7[2] ^ tmp7[3] ^ (tmp7[1] & tmp7[2] & tmp7[3]);
   assign tmp8[3] = tmp8a ^ (tmp7[0] & tmp7[3]) ^ (tmp7[1] & tmp7[3]) ^ (tmp7[2] & tmp7[3]);
   assign tmp8[2] = (tmp7[0] & tmp7[1]) ^ tmp7[2] ^ (tmp7[0] & tmp7[2]) ^ tmp7[3] ^ (tmp7[0] & tmp7[3]) ^ (tmp7[0] & tmp7[2] & tmp7[3]);
   assign tmp8[1] = (tmp7[0] & tmp7[1]) ^ (tmp7[0] & tmp7[2]) ^ (tmp7[1] & tmp7[2]) ^ tmp7[3] ^ (tmp7[1] & tmp7[3]) ^ (tmp7[0] & tmp7[1] & tmp7[3]);
   assign tmp8[0] = tmp8a ^ tmp7[0] ^ (tmp7[0] & tmp7[2]) ^ (tmp7[1] & tmp7[2]) ^ (tmp7[0] & tmp7[1] & tmp7[2]);

   // Step 6-1. Multiply ah & tmp8
   // input: ah & tmp8, output: ahp
   assign ahp[3] = (ah[3] & tmp8[0]) ^ (ah[2] & tmp8[1]) ^ (ah[1] & tmp8[2]) ^ ((ah[0] ^ ah[3]) & tmp8[3]);
   assign ahp[2] = (ah[2] & tmp8[0]) ^ (ah[1] & tmp8[1]) ^ ((ah[0] ^ ah[3]) & tmp8[2]) ^ ((ah[2] ^ ah[3]) & tmp8[3]);
   assign ahp[1] = (ah[1] & tmp8[0]) ^ ((ah[0] ^ ah[3]) & tmp8[1]) ^ ((ah[2] ^ ah[3]) & tmp8[2]) ^ ((ah[1] ^ ah[2]) & tmp8[3]);
   assign ahp[0] = (ah[0] & tmp8[0]) ^ (ah[3] & tmp8[1]) ^ (ah[2] & tmp8[2]) ^ (ah[1] & tmp8[3]);
   // Step 6-2. Multiply tmp5 & tmp8
   // input: tmp5 & tmp8, output: ahp
   assign alp[3] = (tmp5[3] & tmp8[0]) ^ (tmp5[2] & tmp8[1]) ^ (tmp5[1] & tmp8[2]) ^ ((tmp5[0] ^ tmp5[3]) & tmp8[3]);
   assign alp[2] = (tmp5[2] & tmp8[0]) ^ (tmp5[1] & tmp8[1]) ^ ((tmp5[0] ^ tmp5[3]) & tmp8[2]) ^ ((tmp5[2] ^ tmp5[3]) & tmp8[3]);
   assign alp[1] = (tmp5[1] & tmp8[0]) ^ ((tmp5[0] ^ tmp5[3]) & tmp8[1]) ^ ((tmp5[2] ^ tmp5[3]) & tmp8[2]) ^ ((tmp5[1] ^ tmp5[2]) & tmp8[3]);
   assign alp[0] = (tmp5[0] & tmp8[0]) ^ (tmp5[3] & tmp8[1]) ^ (tmp5[2] & tmp8[2]) ^ (tmp5[1] & tmp8[3]);

   // Step 7. Convert ahp & alp to dout
   // input: ahp & alp, output: dout
   // This process referred to map^(-1]
   assign gfinv_dout[7] = (ahp[0] ^ ahp[1]) ^ alp[2] ^ ahp[3];
   assign gfinv_dout[6] = (alp[1] ^ ahp[3]) ^ alp[2] ^ alp[3] ^ ahp[0];
   assign gfinv_dout[5] = (ahp[0] ^ ahp[1]) ^ alp[2];
   assign gfinv_dout[4] = (alp[1] ^ ahp[3]) ^ (ahp[0] ^ ahp[1])^ alp[3];
   assign gfinv_dout[3] = (ahp[0] ^ ahp[1]) ^ alp[1] ^ ahp[2];
   assign gfinv_dout[2] = (alp[1] ^ ahp[3]) ^ (ahp[0] ^ ahp[1]);
   assign gfinv_dout[1] = (ahp[0] ^ ahp[1]) ^ ahp[3];
   assign gfinv_dout[0] = alp[0] ^ ahp[0];
endmodule // aria_lt_gfinv
