//-----------------------------------------------------------------------------
// Title         : ECC Core Top Module
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : ecc.v
// Author        : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 23.12.2018
// Last modified : 25.12.2018
//-----------------------------------------------------------------------------
// Description :
// ECC Core
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 23.12.2018 : created by Haeyoung Kim
// 25.12.2018 : Function Verification Done and Code Refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module ecc (/*AUTOARG*/
   // Outputs
   ecc_rdy, x, y,
   // Inputs
   rst_n, in_kr, in_ds, hash_msg, ecc_op, ecc_en, ecc_clr, clk, Qy, Qx
   ) ;
   output [255:0] x, y;
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [255:0]        Qx;                     // To P1 of ecc_p1.v
   input [255:0]        Qy;                     // To P1 of ecc_p1.v
   input                clk;                    // To CU of ecc_cu.v, ...
   input                ecc_clr;                // To CU of ecc_cu.v
   input                ecc_en;                 // To CU of ecc_cu.v
   input [1:0]          ecc_op;                 // To CU of ecc_cu.v
   input [255:0]        hash_msg;               // To T of ecc_t.v
   input [255:0]        in_ds;                  // To T of ecc_t.v
   input [255:0]        in_kr;                  // To K of ecc_k.v, ...
   input                rst_n;                  // To CU of ecc_cu.v, ...
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output               ecc_rdy;                // From CU of ecc_cu.v
   // End of automatics
   /*AUTOREG*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 ec_clr;                 // From CU of ecc_cu.v
   wire                 ec_en;                  // From CU of ecc_cu.v
   wire [2:0]           ec_op;                  // From CU of ecc_cu.v
   wire                 ec_rdy;                 // From EC of ec_core.v
   wire [255:0]         ecp1_xn;                // From P1 of ecc_p1.v
   wire [255:0]         ecp1_xp;                // From P1 of ecc_p1.v
   wire [255:0]         ecp1_yn;                // From P1 of ecc_p1.v
   wire [255:0]         ecp1_yp;                // From P1 of ecc_p1.v
   wire [255:0]         ecp2_x;                 // From P2 of ecc_p2.v
   wire [255:0]         ecp2_y;                 // From P2 of ecc_p2.v
   wire [255:0]         ecp3_xn;                // From EC of ec_core.v
   wire [255:0]         ecp3_xp;                // From EC of ec_core.v
   wire [255:0]         ecp3_yn;                // From EC of ec_core.v
   wire [255:0]         ecp3_yp;                // From EC of ec_core.v
   wire                 flg_ec_add;             // From K of ecc_k.v
   wire                 flg_ec_last;            // From K of ecc_k.v
   wire                 k_clr;                  // From CU of ecc_cu.v
   wire                 k_en;                   // From CU of ecc_cu.v
   wire [1:0]           k_op;                   // From CU of ecc_cu.v
   wire                 k_rdy;                  // From K of ecc_k.v
   wire                 p1_clr;                 // From CU of ecc_cu.v
   wire                 p1_en;                  // From CU of ecc_cu.v
   wire [1:0]           p1_op;                  // From CU of ecc_cu.v
   wire                 p2_clr;                 // From CU of ecc_cu.v
   wire                 p2_en;                  // From CU of ecc_cu.v
   wire [1:0]           p2_op;                  // From CU of ecc_cu.v
   wire [255:0]         s;                      // From T of ecc_t.v
   wire                 t_clr;                  // From CU of ecc_cu.v
   wire                 t_en;                   // From CU of ecc_cu.v
   wire [2:0]           t_op;                   // From CU of ecc_cu.v
   // End of automatics

   ecc_cu  CU (/*AUTOINST*/
               // Outputs
               .ecc_rdy                 (ecc_rdy),
               .k_op                    (k_op[1:0]),
               .k_en                    (k_en),
               .k_clr                   (k_clr),
               .p1_op                   (p1_op[1:0]),
               .p1_en                   (p1_en),
               .p1_clr                  (p1_clr),
               .p2_op                   (p2_op[1:0]),
               .p2_en                   (p2_en),
               .p2_clr                  (p2_clr),
               .t_op                    (t_op[2:0]),
               .t_en                    (t_en),
               .t_clr                   (t_clr),
               .ec_clr                  (ec_clr),
               .ec_en                   (ec_en),
               .ec_op                   (ec_op[2:0]),
               // Inputs
               .clk                     (clk),
               .rst_n                   (rst_n),
               .ecc_op                  (ecc_op[1:0]),
               .ecc_en                  (ecc_en),
               .ecc_clr                 (ecc_clr),
               .k_rdy                   (k_rdy),
               .flg_ec_add              (flg_ec_add),
               .flg_ec_last             (flg_ec_last),
               .ec_rdy                  (ec_rdy));

   ecc_p1  P1 (/*AUTOINST*/
               // Outputs
               .ecp1_xp                 (ecp1_xp[255:0]),
               .ecp1_xn                 (ecp1_xn[255:0]),
               .ecp1_yp                 (ecp1_yp[255:0]),
               .ecp1_yn                 (ecp1_yn[255:0]),
               // Inputs
               .clk                     (clk),
               .rst_n                   (rst_n),
               .p1_op                   (p1_op[1:0]),
               .p1_en                   (p1_en),
               .p1_clr                  (p1_clr),
               .Qx                      (Qx[255:0]),
               .Qy                      (Qy[255:0]),
               .x                       (x[255:0]),
               .y                       (y[255:0]),
               .ecp3_xp                 (ecp3_xp[255:0]),
               .ecp3_xn                 (ecp3_xn[255:0]),
               .ecp3_yp                 (ecp3_yp[255:0]),
               .ecp3_yn                 (ecp3_yn[255:0]));

   ecc_p2  P2 (/*AUTOINST*/
               // Outputs
               .ecp2_x                  (ecp2_x[255:0]),
               .ecp2_y                  (ecp2_y[255:0]),
               // Inputs
               .clk                     (clk),
               .rst_n                   (rst_n),
               .p2_op                   (p2_op[1:0]),
               .p2_en                   (p2_en),
               .p2_clr                  (p2_clr),
               .ecp3_xp                 (ecp3_xp[255:0]),
               .ecp3_yp                 (ecp3_yp[255:0]),
               .x                       (x[255:0]),
               .y                       (y[255:0]));

   ecc_k   K  (/*AUTOINST*/
               // Outputs
               .k_rdy                   (k_rdy),
               .flg_ec_add              (flg_ec_add),
               .flg_ec_last             (flg_ec_last),
               // Inputs
               .clk                     (clk),
               .rst_n                   (rst_n),
               .in_kr                   (in_kr[255:0]),
               .x                       (x[255:0]),
               .y                       (y[255:0]),
               .k_op                    (k_op[1:0]),
               .k_en                    (k_en),
               .k_clr                   (k_clr));

   ecc_t   T  (/*AUTOINST*/
               // Outputs
               .x                       (x[255:0]),
               .y                       (y[255:0]),
               .s                       (s[255:0]),
               // Inputs
               .clk                     (clk),
               .rst_n                   (rst_n),
               .t_op                    (t_op[2:0]),
               .t_en                    (t_en),
               .t_clr                   (t_clr),
               .ecp1_xp                 (ecp1_xp[255:0]),
               .ecp1_yp                 (ecp1_yp[255:0]),
               .ecp3_xp                 (ecp3_xp[255:0]),
               .ecp3_yp                 (ecp3_yp[255:0]),
               .in_kr                   (in_kr[255:0]),
               .in_ds                   (in_ds[255:0]),
               .hash_msg                (hash_msg[255:0]));

   ec_core EC (/*AUTOINST*/
               // Outputs
               .ecp3_xp                 (ecp3_xp[255:0]),
               .ecp3_xn                 (ecp3_xn[255:0]),
               .ecp3_yp                 (ecp3_yp[255:0]),
               .ecp3_yn                 (ecp3_yn[255:0]),
               .ec_rdy                  (ec_rdy),
               // Inputs
               .clk                     (clk),
               .ec_clr                  (ec_clr),
               .ec_en                   (ec_en),
               .ec_op                   (ec_op[2:0]),
               .ecp1_xn                 (ecp1_xn[255:0]),
               .ecp1_xp                 (ecp1_xp[255:0]),
               .ecp1_yn                 (ecp1_yn[255:0]),
               .ecp1_yp                 (ecp1_yp[255:0]),
               .ecp2_x                  (ecp2_x[255:0]),
               .ecp2_y                  (ecp2_y[255:0]),
               .rst_n                   (rst_n),
               .s                       (s[255:0]),
               .x                       (x[255:0]),
               .y                       (y[255:0]));

endmodule // ecc
