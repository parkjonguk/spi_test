module mod_arith (/*AUTOARG*/
   // Outputs
   ready, zp, zn, prev_zp, prev_zn,
   // Inputs
   yp, yn, xp, xn, rst_n, opt_mod, opt_accy, opt_accx, op, en, clk, clear
   ) ;
   output [255:0]       zp;
   output [255:0]       zn;

   output [255:0]       prev_zp;
   output [255:0]       prev_zn;
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                clear;                  // To CU of mod_arith_cu.v
   input                clk;                    // To A of mod_arith_a.v, ...
   input                en;                     // To CU of mod_arith_cu.v
   input [2:0]          op;                     // To CU of mod_arith_cu.v
   input                opt_accx;               // To CU of mod_arith_cu.v
   input                opt_accy;               // To CU of mod_arith_cu.v
   input                opt_mod;                // To CU of mod_arith_cu.v
   input                rst_n;                  // To A of mod_arith_a.v, ...
   input [255:0]        xn;                     // To A of mod_arith_a.v, ...
   input [255:0]        xp;                     // To A of mod_arith_a.v, ...
   input [255:0]        yn;                     // To B of mod_arith_b.v
   input [255:0]        yp;                     // To B of mod_arith_b.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output               ready;                  // From CU of mod_arith_cu.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 a_clr;                  // From CU of mod_arith_cu.v
   wire                 a_en;                   // From CU of mod_arith_cu.v
   wire [1:0]           a_op;                   // From CU of mod_arith_cu.v
   wire [255:0]         an;                     // From A of mod_arith_a.v
   wire [1:0]           an_nxt;                 // From A of mod_arith_a.v
   wire [255:0]         ap;                     // From A of mod_arith_a.v
   wire [1:0]           ap_nxt;                 // From A of mod_arith_a.v
   wire                 b_en;                   // From CU of mod_arith_cu.v
   wire [2:0]           b_op;                   // From CU of mod_arith_cu.v
   wire [255:0]         bn;                     // From B of mod_arith_b.v
   wire [255:0]         bp;                     // From B of mod_arith_b.v
   wire                 flg_mod;                // From CU of mod_arith_cu.v
   wire                 flg_mul;                // From INST of mod_arith_inst.v
   wire                 flg_novf;               // From A of mod_arith_a.v
   wire                 flg_povf;               // From A of mod_arith_a.v
   wire                 flg_s;                  // From INST of mod_arith_inst.v
   wire                 inst_en;                // From CU of mod_arith_cu.v
   wire                 inst_last;              // From INST of mod_arith_inst.v
   wire [1:0]           inst_nxt;               // From INST of mod_arith_inst.v
   wire [1:0]           inst_op;                // From CU of mod_arith_cu.v
   wire                 opt_acca;               // From CU of mod_arith_cu.v
   wire                 opt_accv;               // From CU of mod_arith_cu.v
   wire [1:0]           opt_adsb;               // From CU of mod_arith_cu.v
   wire                 u_en;                   // From CU of mod_arith_cu.v
   wire [1:0]           u_op;                   // From CU of mod_arith_cu.v
   wire [255:0]         un;                     // From U of mod_arith_u.v
   wire [255:0]         up;                     // From U of mod_arith_u.v
   wire                 v_busy;                 // From V of mod_arith_v.v
   wire                 v_clr;                  // From CU of mod_arith_cu.v
   wire                 v_en;                   // From CU of mod_arith_cu.v
   wire [1:0]           v_op;                   // From CU of mod_arith_cu.v
   wire [255:0]         vn;                     // From V of mod_arith_v.v
   wire [255:0]         vp;                     // From V of mod_arith_v.v
   // End of automatics
   /*AUTOREG*/

   wire   [255:0]       zp;
   wire   [255:0]       zn;

   wire [255:0]         prev_zp;
   wire [255:0]         prev_zn;

   assign zp = bp;
   assign zn = bn;

   assign prev_zp = vp;
   assign prev_zn = vn;

   mod_arith_a    A    (/*AUTOINST*/
                        // Outputs
                        .ap             (ap[255:0]),
                        .an             (an[255:0]),
                        .ap_nxt         (ap_nxt[1:0]),
                        .an_nxt         (an_nxt[1:0]),
                        .flg_povf       (flg_povf),
                        .flg_novf       (flg_novf),
                        // Inputs
                        .clk            (clk),
                        .rst_n          (rst_n),
                        .a_op           (a_op[1:0]),
                        .opt_adsb       (opt_adsb[1:0]),
                        .a_en           (a_en),
                        .a_clr          (a_clr),
                        .flg_mul        (flg_mul),
                        .opt_acca       (opt_acca),
                        .bp             (bp[255:0]),
                        .bn             (bn[255:0]),
                        .xp             (xp[255:0]),
                        .xn             (xn[255:0]));

   mod_arith_b    B    (/*AUTOINST*/
                        // Outputs
                        .bp             (bp[255:0]),
                        .bn             (bn[255:0]),
                        // Inputs
                        .clk            (clk),
                        .rst_n          (rst_n),
                        .b_op           (b_op[2:0]),
                        .b_en           (b_en),
                        .flg_mod        (flg_mod),
                        .ap             (ap[255:0]),
                        .an             (an[255:0]),
                        .yp             (yp[255:0]),
                        .yn             (yn[255:0]),
                        .up             (up[255:0]),
                        .un             (un[255:0]),
                        .vp             (vp[255:0]),
                        .vn             (vn[255:0]));

   mod_arith_u    U    (/*AUTOINST*/
                        // Outputs
                        .up             (up[255:0]),
                        .un             (un[255:0]),
                        // Inputs
                        .clk            (clk),
                        .rst_n          (rst_n),
                        .u_op           (u_op[1:0]),
                        .u_en           (u_en),
                        .ap             (ap[1:0]),
                        .an             (an[1:0]),
                        .bp             (bp[1:0]),
                        .bn             (bn[1:0]),
                        .flg_mod        (flg_mod),
                        .flg_mul        (flg_mul),
                        .vp             (vp[255:0]),
                        .vn             (vn[255:0]));

   mod_arith_v    V    (/*AUTOINST*/
                        // Outputs
                        .v_busy         (v_busy),
                        .vp             (vp[255:0]),
                        .vn             (vn[255:0]),
                        // Inputs
                        .clk            (clk),
                        .rst_n          (rst_n),
                        .v_op           (v_op[1:0]),
                        .v_en           (v_en),
                        .v_clr          (v_clr),
                        .opt_accv       (opt_accv),
                        .flg_mod        (flg_mod),
                        .xp             (xp[255:0]),
                        .xn             (xn[255:0]),
                        .up             (up[255:0]),
                        .un             (un[255:0]),
                        .bp             (bp[255:0]),
                        .bn             (bn[255:0]));

   mod_arith_cu   CU   (/*AUTOINST*/
                        // Outputs
                        .ready          (ready),
                        .inst_op        (inst_op[1:0]),
                        .inst_en        (inst_en),
                        .a_op           (a_op[1:0]),
                        .a_en           (a_en),
                        .b_op           (b_op[2:0]),
                        .b_en           (b_en),
                        .v_op           (v_op[1:0]),
                        .v_en           (v_en),
                        .u_op           (u_op[1:0]),
                        .u_en           (u_en),
                        .opt_acca       (opt_acca),
                        .opt_accv       (opt_accv),
                        .v_clr          (v_clr),
                        .a_clr          (a_clr),
                        .opt_adsb       (opt_adsb[1:0]),
                        .flg_mod        (flg_mod),
                        // Inputs
                        .clk            (clk),
                        .rst_n          (rst_n),
                        .op             (op[2:0]),
                        .en             (en),
                        .clear          (clear),
                        .opt_mod        (opt_mod),
                        .opt_accx       (opt_accx),
                        .opt_accy       (opt_accy),
                        .bp             (bp[1:0]),
                        .bn             (bn[1:0]),
                        .flg_povf       (flg_povf),
                        .flg_novf       (flg_novf),
                        .flg_mul        (flg_mul),
                        .flg_s          (flg_s),
                        .v_busy         (v_busy),
                        .inst_nxt       (inst_nxt[1:0]),
                        .inst_last      (inst_last));

   mod_arith_inst INST (/*AUTOINST*/
                        // Outputs
                        .inst_nxt       (inst_nxt[1:0]),
                        .inst_last      (inst_last),
                        .flg_mul        (flg_mul),
                        .flg_s          (flg_s),
                        // Inputs
                        .clk            (clk),
                        .rst_n          (rst_n),
                        .inst_op        (inst_op[1:0]),
                        .inst_en        (inst_en),
                        .ap_nxt         (ap_nxt[1:0]),
                        .an_nxt         (an_nxt[1:0]));

endmodule // mod_arith
