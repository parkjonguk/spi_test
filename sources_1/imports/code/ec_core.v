//-----------------------------------------------------------------------------
// Title         : EC Core
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : ec_core.v
// Author        : Haeyoung Kim <ryoung0327@gmail.com>
// Created       : 22.12.2018
// Last modified : 25.12.2018
//-----------------------------------------------------------------------------
// Description :
// EC Core Top Module
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 22.12.2018 : created by Haeyoung Kim
// 23.12.2018 : Spyglass Check by Haeyoung Kim
// 25.12.2018 : Function Verification Done and Code Refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module ec_core (/*AUTOARG*/
   // Outputs
   ecp3_xp, ecp3_xn, ecp3_yp, ecp3_yn, ec_rdy,
   // Inputs
   y, x, s, rst_n, ecp2_y, ecp2_x, ecp1_yp, ecp1_yn, ecp1_xp, ecp1_xn, ec_op,
   ec_en, ec_clr, clk
   ) ;
   output [255:0]       ecp3_xp;
   output [255:0]       ecp3_xn;
   output [255:0]       ecp3_yp;
   output [255:0]       ecp3_yn;
   output               ec_rdy;                 // From CU of ec_core_cu.v

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                clk;                    // To X of ec_core_y.v, ...
   input                ec_clr;                 // To CU of ec_core_cu.v
   input                ec_en;                  // To CU of ec_core_cu.v
   input [2:0]          ec_op;                  // To CU of ec_core_cu.v
   input [255:0]        ecp1_xn;                // To X of ec_core_y.v, ...
   input [255:0]        ecp1_xp;                // To X of ec_core_y.v, ...
   input [255:0]        ecp1_yn;                // To X of ec_core_y.v, ...
   input [255:0]        ecp1_yp;                // To X of ec_core_y.v, ...
   input [255:0]        ecp2_x;                 // To Y of ec_core_x.v
   input [255:0]        ecp2_y;                 // To Y of ec_core_x.v
   input                rst_n;                  // To X of ec_core_y.v, ...
   input [255:0]        s;                      // To X of ec_core_y.v
   input [255:0]        x;                      // To X of ec_core_y.v, ...
   input [255:0]        y;                      // To X of ec_core_y.v
   // End of automatics
   /*AUTOOUTPUT*/
   /*AUTOREG*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 ma_clear;               // From CU of ec_core_cu.v
   wire                 ma_en;                  // From CU of ec_core_cu.v
   wire [2:0]           ma_op;                  // From CU of ec_core_cu.v
   wire                 ma_opt_accx;            // From CU of ec_core_cu.v
   wire                 ma_opt_accy;            // From CU of ec_core_cu.v
   wire                 ma_opt_mod;             // From CU of ec_core_cu.v
   wire [255:0]         ma_prev_zn;             // From MA of mod_arith.v
   wire [255:0]         ma_prev_zp;             // From MA of mod_arith.v
   wire                 ma_rdy;                 // From MA of mod_arith.v
   wire [255:0]         ma_xn;                  // From Y of ec_core_x.v
   wire [255:0]         ma_xp;                  // From Y of ec_core_x.v
   wire [255:0]         ma_yn;                  // From X of ec_core_y.v
   wire [255:0]         ma_yp;                  // From X of ec_core_y.v
   wire [255:0]         ma_zn;                  // From MA of mod_arith.v
   wire [255:0]         ma_zp;                  // From MA of mod_arith.v
   wire                 x_clr;                  // From CU of ec_core_cu.v
   wire                 x_en;                   // From CU of ec_core_cu.v
   wire [2:0]           x_op;                   // From CU of ec_core_cu.v
   wire                 y_clr;                  // From CU of ec_core_cu.v
   wire                 y_en;                   // From CU of ec_core_cu.v
   wire [2:0]           y_op;                   // From CU of ec_core_cu.v
   // End of automatics

   wire [255:0]         ecp3_xp;
   wire [255:0]         ecp3_xn;
   wire [255:0]         ecp3_yp;
   wire [255:0]         ecp3_yn;

   assign ecp3_xp = ma_xp;
   assign ecp3_xn = ma_xn;
   assign ecp3_yp = ma_yp;
   assign ecp3_yn = ma_yn;


   ec_core_y  X  (/*AUTOINST*/
                  // Outputs
                  .ma_yp                (ma_yp[255:0]),
                  .ma_yn                (ma_yn[255:0]),
                  // Inputs
                  .clk                  (clk),
                  .rst_n                (rst_n),
                  .y_op                 (y_op[2:0]),
                  .y_en                 (y_en),
                  .y_clr                (y_clr),
                  .x                    (x[255:0]),
                  .y                    (y[255:0]),
                  .s                    (s[255:0]),
                  .ecp1_xp              (ecp1_xp[255:0]),
                  .ecp1_xn              (ecp1_xn[255:0]),
                  .ecp1_yp              (ecp1_yp[255:0]),
                  .ecp1_yn              (ecp1_yn[255:0]),
                  .ma_zp                (ma_zp[255:0]),
                  .ma_zn                (ma_zn[255:0]));
   ec_core_x  Y  (/*AUTOINST*/
                  // Outputs
                  .ma_xp                (ma_xp[255:0]),
                  .ma_xn                (ma_xn[255:0]),
                  // Inputs
                  .clk                  (clk),
                  .rst_n                (rst_n),
                  .x_op                 (x_op[2:0]),
                  .x_en                 (x_en),
                  .x_clr                (x_clr),
                  .x                    (x[255:0]),
                  .ecp1_xp              (ecp1_xp[255:0]),
                  .ecp1_xn              (ecp1_xn[255:0]),
                  .ecp2_x               (ecp2_x[255:0]),
                  .ecp1_yp              (ecp1_yp[255:0]),
                  .ecp1_yn              (ecp1_yn[255:0]),
                  .ecp2_y               (ecp2_y[255:0]),
                  .ma_zp                (ma_zp[255:0]),
                  .ma_zn                (ma_zn[255:0]),
                  .ma_prev_zp           (ma_prev_zp[255:0]),
                  .ma_prev_zn           (ma_prev_zn[255:0]));
   ec_core_cu CU (/*AUTOINST*/
                  // Outputs
                  .ec_rdy               (ec_rdy),
                  .x_op                 (x_op[2:0]),
                  .x_en                 (x_en),
                  .x_clr                (x_clr),
                  .y_op                 (y_op[2:0]),
                  .y_en                 (y_en),
                  .y_clr                (y_clr),
                  .ma_op                (ma_op[2:0]),
                  .ma_en                (ma_en),
                  .ma_clear             (ma_clear),
                  .ma_opt_accx          (ma_opt_accx),
                  .ma_opt_accy          (ma_opt_accy),
                  .ma_opt_mod           (ma_opt_mod),
                  // Inputs
                  .clk                  (clk),
                  .rst_n                (rst_n),
                  .ec_op                (ec_op[2:0]),
                  .ec_en                (ec_en),
                  .ec_clr               (ec_clr),
                  .ma_rdy               (ma_rdy));

   mod_arith  MA (
                  // Outputs
                  .zp                   (ma_zp[255:0]),
                  .zn                   (ma_zn[255:0]),
                  .prev_zp              (ma_prev_zp[255:0]),
                  .prev_zn              (ma_prev_zn[255:0]),
                  .ready                (ma_rdy),
                  // Inputs
                  .clear                (ma_clear),
                  .en                   (ma_en),
                  .op                   (ma_op[2:0]),
                  .opt_accx             (ma_opt_accx),
                  .opt_accy             (ma_opt_accy),
                  .opt_mod              (ma_opt_mod),
                  .xn                   (ma_xn[255:0]),
                  .xp                   (ma_xp[255:0]),
                  .yn                   (ma_yn[255:0]),
                  .yp                   (ma_yp[255:0]),
                  /*AUTOINST*/
                  // Inputs
                  .clk                  (clk),
                  .rst_n                (rst_n));

endmodule // ec_core
