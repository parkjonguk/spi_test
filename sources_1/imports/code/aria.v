//-----------------------------------------------------------------------------
// Title         : ARIA
// Project       : ARIA 1.1
//-----------------------------------------------------------------------------
// File          : aria.v
// Author        : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 15.12.2018
// Last modified : 15.12.2018
//-----------------------------------------------------------------------------
// Description :
// ARIA OP
//  - 3'b000 : K_ZERO
//  - 3'b001 : K_SET128
//  - 3'b010 : K_SET192
//  - 3'b011 : K_SET256
//  - 3'b100 : R_ENC_ECB
//  - 3'b101 : R_ENC_XFB
//  - 3'b110 : R_DEC_ECB
//  - 3'b111 : R_DEC_XFB
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 15.12.2018 : created by Haeyoung Kim
//-----------------------------------------------------------------------------
module aria (/*AUTOARG*/
   // Outputs
   warn_rterm, warn_ksize, k_ready, ecb_do, xfb_do, r_ready,
   // Inputs
   xfb_en, xfb_di, xfb_clr, rst_n, key, ecb_en, ecb_di, ecb_clr, clk, aria_op,
   aria_en, aria_clr
   ) ;
   output [127:0] ecb_do, xfb_do;
   output         r_ready;
   input [127:0]  ecb_di;                // To L1 of aria_round_l1.v
   input [127:0]  xfb_di;                // To L2 of aria_round_l2.v
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                aria_clr;               // To CU of aria_cu.v
   input                aria_en;                // To CU of aria_cu.v
   input [2:0]          aria_op;                // To CU of aria_cu.v
   input                clk;                    // To KEY of aria_key.v, ...
   input                ecb_clr;                // To L1 of aria_round_l1.v
   input                ecb_en;                 // To L1 of aria_round_l1.v
   input [255:0]        key;                    // To KEY of aria_key.v
   input                rst_n;                  // To KEY of aria_key.v, ...
   input                xfb_clr;                // To L2 of aria_round_l2.v
   input                xfb_en;                 // To L2 of aria_round_l2.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output               k_ready;                // From CU of aria_cu.v
   output               warn_ksize;             // From KEY of aria_key.v
   output               warn_rterm;             // From CU of aria_cu.v
   // End of automatics
   /*AUTOREG*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 flg_dec;                // From CU of aria_cu.v
   wire                 flg_klast;              // From NR of aria_round_nr.v
   wire                 flg_ltinv;              // From NR of aria_round_nr.v
   wire                 flg_rkdf;               // From CU of aria_cu.v
   wire                 flg_rlast;              // From NR of aria_round_nr.v
   wire                 key_clr;                // From CU of aria_cu.v
   wire                 key_en;                 // From CU of aria_cu.v
   wire [1:0]           key_op;                 // From CU of aria_cu.v
   wire [127:0]         l1;                     // From L1 of aria_round_l1.v
   wire                 l1_en;                  // From CU of aria_cu.v
   wire [1:0]           l1_op;                  // From CU of aria_cu.v
   wire [127:0]         l2;                     // From L2 of aria_round_l2.v
   wire                 l2_clr;                 // From CU of aria_cu.v
   wire                 l2_en;                  // From CU of aria_cu.v
   wire                 l2_opt_even;            // From CU of aria_cu.v
   wire                 nr_clr;                 // From CU of aria_cu.v
   wire                 nr_en;                  // From CU of aria_cu.v
   wire [5:0]           rk_addr;                // From RKADDR of aria_round_rk.v
   wire                 rk_clr;                 // From CU of aria_cu.v
   wire                 rk_en;                  // From CU of aria_cu.v
   wire [1:0]           rk_op;                  // From CU of aria_cu.v
   wire [1:0]           st_ksize;               // From KEY of aria_key.v
   wire [127:0]         w0;                     // From KEY of aria_key.v
   wire [127:0]         w1;                     // From KEY of aria_key.v
   wire [127:0]         w2;                     // From KEY of aria_key.v
   wire [127:0]         w3;                     // From KEY of aria_key.v
   // End of automatics

   assign ecb_do = l1;
   assign xfb_do = l2;
   aria_key KEY (/*AUTOINST*/
                 // Outputs
                 .st_ksize              (st_ksize[1:0]),
                 .warn_ksize            (warn_ksize),
                 .w0                    (w0[127:0]),
                 .w1                    (w1[127:0]),
                 .w2                    (w2[127:0]),
                 .w3                    (w3[127:0]),
                 // Inputs
                 .clk                   (clk),
                 .rst_n                 (rst_n),
                 .key                   (key[255:0]),
                 .l1                    (l1[127:0]),
                 .key_op                (key_op[1:0]),
                 .key_en                (key_en),
                 .key_clr               (key_clr));
   aria_cu CU (/*AUTOINST*/
               // Outputs
               .k_ready                 (k_ready),
               .r_ready                 (r_ready),
               .flg_rkdf                (flg_rkdf),
               .flg_dec                 (flg_dec),
               .rk_clr                  (rk_clr),
               .rk_en                   (rk_en),
               .rk_op                   (rk_op[1:0]),
               .nr_clr                  (nr_clr),
               .nr_en                   (nr_en),
               .key_op                  (key_op[1:0]),
               .key_en                  (key_en),
               .key_clr                 (key_clr),
               .l1_en                   (l1_en),
               .l1_op                   (l1_op[1:0]),
               .l2_clr                  (l2_clr),
               .l2_en                   (l2_en),
               .l2_opt_even             (l2_opt_even),
               .warn_rterm              (warn_rterm),
               // Inputs
               .clk                     (clk),
               .rst_n                   (rst_n),
               .aria_op                 (aria_op[2:0]),
               .aria_en                 (aria_en),
               .aria_clr                (aria_clr),
               .flg_klast               (flg_klast),
               .flg_rlast               (flg_rlast));

   aria_round_nr NR (/*AUTOINST*/
                     // Outputs
                     .flg_klast         (flg_klast),
                     .flg_rlast         (flg_rlast),
                     .flg_ltinv         (flg_ltinv),
                     // Inputs
                     .clk               (clk),
                     .rst_n             (rst_n),
                     .nr_clr            (nr_clr),
                     .nr_en             (nr_en),
                     .st_ksize          (st_ksize[1:0]));

   aria_round_rk RKADDR (/*AUTOINST*/
                         // Outputs
                         .rk_addr               (rk_addr[5:0]),
                         // Inputs
                         .clk                   (clk),
                         .rst_n                 (rst_n),
                         .rk_op                 (rk_op[1:0]),
                         .rk_en                 (rk_en),
                         .rk_clr                (rk_clr),
                         .st_ksize              (st_ksize[1:0]),
                         .flg_dec               (flg_dec));

   aria_round_l1 L1 (
                     .ecb_din           (ecb_di[127:0]),
                     /*AUTOINST*/
                     // Outputs
                     .l1                (l1[127:0]),
                     // Inputs
                     .clk               (clk),
                     .rst_n             (rst_n),
                     .r_ready           (r_ready),
                     .ecb_en            (ecb_en),
                     .ecb_clr           (ecb_clr),
                     .l1_en             (l1_en),
                     .l1_op             (l1_op[1:0]),
                     .flg_ltinv         (flg_ltinv),
                     .rk_addr           (rk_addr[5:0]),
                     .w0                (w0[127:0]),
                     .w1                (w1[127:0]),
                     .w2                (w2[127:0]),
                     .w3                (w3[127:0]),
                     .l2                (l2[127:0]));
   aria_round_l2 L2 (
                     .xfb_din           (xfb_di[127:0]),
                     /*AUTOINST*/
                     // Outputs
                     .l2                (l2[127:0]),
                     // Inputs
                     .clk               (clk),
                     .rst_n             (rst_n),
                     .r_ready           (r_ready),
                     .flg_rkdf          (flg_rkdf),
                     .xfb_en            (xfb_en),
                     .xfb_clr           (xfb_clr),
                     .l1                (l1[127:0]),
                     .l2_en             (l2_en),
                     .l2_clr            (l2_clr),
                     .l2_opt_even       (l2_opt_even));
endmodule // aria

