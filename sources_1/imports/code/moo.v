module moo (/*AUTOARG*/
   // Outputs
   warn_rterm, warn_ksize, moo_rdy, moo_key_rdy, moo_done, moo_do_vld,
   moo_di_rdy, moo_add_rdy, ecb_do, xfb_do, mac_do, ccm_d,
   // Inputs
   wb_d, size_msg, rst_n, msg_done, moo_op, moo_en, moo_do_rdy, moo_di_vld,
   moo_di_lst, moo_clr, moo_add_vld, moo_add_lst, moo_add, key_size, key, iv,
   ghash, gcm_mac_final, clr_core, clk, ccm_b0
   ) ;
   output [127:0] ecb_do;
   output [127:0] xfb_do;
   output [127:0] mac_do;
   output [127:0] ccm_d;
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [7:0]          ccm_b0;                 // To CCD of moo_ccm_d.v
   input                clk;                    // To AR of aria.v, ...
   input                clr_core;               // To CU of moo_cu.v, ...
   input                gcm_mac_final;          // To CU of moo_cu.v
   input [127:0]        ghash;                  // To MDO of moo_mac_do.v
   input [127:0]        iv;                     // To EDI of moo_ecb_di.v, ...
   input [255:0]        key;                    // To AR of aria.v
   input [1:0]          key_size;               // To CU of moo_cu.v
   input                moo_add;                // To CU of moo_cu.v
   input                moo_add_lst;            // To CU of moo_cu.v
   input                moo_add_vld;            // To CU of moo_cu.v
   input                moo_clr;                // To CU of moo_cu.v
   input                moo_di_lst;             // To CU of moo_cu.v
   input                moo_di_vld;             // To CU of moo_cu.v
   input                moo_do_rdy;             // To CU of moo_cu.v
   input                moo_en;                 // To CU of moo_cu.v
   input [3:0]          moo_op;                 // To CU of moo_cu.v
   input                msg_done;               // To CU of moo_cu.v, ...
   input                rst_n;                  // To AR of aria.v, ...
   input [31:0]         size_msg;               // To CCD of moo_ccm_d.v, ...
   input [127:0]        wb_d;                   // To EDI of moo_ecb_di.v, ...
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output               moo_add_rdy;            // From CU of moo_cu.v
   output               moo_di_rdy;             // From CU of moo_cu.v
   output               moo_do_vld;             // From CU of moo_cu.v
   output               moo_done;               // From CU of moo_cu.v
   output               moo_key_rdy;            // From CU of moo_cu.v
   output               moo_rdy;                // From CU of moo_cu.v
   output               warn_ksize;             // From AR of aria.v
   output               warn_rterm;             // From AR of aria.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 aria_clr;               // From CU of moo_cu.v
   wire                 aria_en;                // From CU of moo_cu.v
   wire [2:0]           aria_op;                // From CU of moo_cu.v
   wire                 ccm_d_clr;              // From CU of moo_cu.v
   wire                 ccm_d_en;               // From CU of moo_cu.v
   wire [1:0]           ccm_d_op;               // From CU of moo_cu.v
   wire                 ctr_4b;                 // From CU of moo_cu.v
   wire                 ctr_4w;                 // From CU of moo_cu.v
   wire                 ecb_clr;                // From CU of moo_cu.v
   wire [127:0]         ecb_di;                 // From EDI of moo_ecb_di.v
   wire                 ecb_di_clr;             // From CU of moo_cu.v
   wire                 ecb_di_en;              // From CU of moo_cu.v
   wire                 ecb_en;                 // From CU of moo_cu.v
   wire                 ecb_iv_en;              // From CU of moo_cu.v
   wire                 k_ready;                // From AR of aria.v
   wire                 mac_do_clr;             // From CU of moo_cu.v
   wire                 mac_do_en;              // From CU of moo_cu.v
   wire [1:0]           mac_do_op;              // From CU of moo_cu.v
   wire                 r_ready;                // From AR of aria.v
   wire                 xfb_clr;                // From CU of moo_cu.v
   wire [127:0]         xfb_di;                 // From XDI of moo_xfb_di.v
   wire                 xfb_di_clr;             // From CU of moo_cu.v
   wire                 xfb_di_en;              // From CU of moo_cu.v
   wire [1:0]           xfb_di_op;              // From CU of moo_cu.v
   wire                 xfb_en;                 // From CU of moo_cu.v
   // End of automatics

   aria        AR   (/*AUTOINST*/
                     // Outputs
                     .ecb_do            (ecb_do[127:0]),
                     .xfb_do            (xfb_do[127:0]),
                     .r_ready           (r_ready),
                     .k_ready           (k_ready),
                     .warn_ksize        (warn_ksize),
                     .warn_rterm        (warn_rterm),
                     // Inputs
                     .ecb_di            (ecb_di[127:0]),
                     .xfb_di            (xfb_di[127:0]),
                     .aria_clr          (aria_clr),
                     .aria_en           (aria_en),
                     .aria_op           (aria_op[2:0]),
                     .clk               (clk),
                     .ecb_clr           (ecb_clr),
                     .ecb_en            (ecb_en),
                     .key               (key[255:0]),
                     .rst_n             (rst_n),
                     .xfb_clr           (xfb_clr),
                     .xfb_en            (xfb_en));


   moo_cu      CU   (/*AUTOINST*/
                     // Outputs
                     .aria_op           (aria_op[2:0]),
                     .aria_en           (aria_en),
                     .aria_clr          (aria_clr),
                     .xfb_clr           (xfb_clr),
                     .xfb_en            (xfb_en),
                     .ecb_clr           (ecb_clr),
                     .ecb_en            (ecb_en),
                     .ecb_di_clr        (ecb_di_clr),
                     .ecb_di_en         (ecb_di_en),
                     .ecb_iv_en         (ecb_iv_en),
                     .ctr_4w            (ctr_4w),
                     .ctr_4b            (ctr_4b),
                     .xfb_di_clr        (xfb_di_clr),
                     .xfb_di_en         (xfb_di_en),
                     .xfb_di_op         (xfb_di_op[1:0]),
                     .mac_do_clr        (mac_do_clr),
                     .mac_do_en         (mac_do_en),
                     .mac_do_op         (mac_do_op[1:0]),
                     .ccm_d_clr         (ccm_d_clr),
                     .ccm_d_en          (ccm_d_en),
                     .ccm_d_op          (ccm_d_op[1:0]),
                     .moo_key_rdy       (moo_key_rdy),
                     .moo_di_rdy        (moo_di_rdy),
                     .moo_do_vld        (moo_do_vld),
                     .moo_add_rdy       (moo_add_rdy),
                     .moo_done          (moo_done),
                     .moo_rdy           (moo_rdy),
                     // Inputs
                     .clk               (clk),
                     .rst_n             (rst_n),
                     .clr_core          (clr_core),
                     .key_size          (key_size[1:0]),
                     .moo_op            (moo_op[3:0]),
                     .moo_en            (moo_en),
                     .moo_add           (moo_add),
                     .moo_clr           (moo_clr),
                     .r_ready           (r_ready),
                     .k_ready           (k_ready),
                     .msg_done          (msg_done),
                     .moo_di_vld        (moo_di_vld),
                     .moo_di_lst        (moo_di_lst),
                     .moo_do_rdy        (moo_do_rdy),
                     .moo_add_vld       (moo_add_vld),
                     .moo_add_lst       (moo_add_lst),
                     .gcm_mac_final     (gcm_mac_final));
   moo_ecb_di  EDI  (/*AUTOINST*/
                     // Outputs
                     .ecb_di            (ecb_di[127:0]),
                     // Inputs
                     .clk               (clk),
                     .rst_n             (rst_n),
                     .clr_core          (clr_core),
                     .ecb_di_en         (ecb_di_en),
                     .ecb_iv_en         (ecb_iv_en),
                     .ecb_di_clr        (ecb_di_clr),
                     .ctr_4b            (ctr_4b),
                     .ctr_4w            (ctr_4w),
                     .wb_d              (wb_d[127:0]),
                     .iv                (iv[127:0]));
   moo_xfb_di  XDI  (/*AUTOINST*/
                     // Outputs
                     .xfb_di            (xfb_di[127:0]),
                     // Inputs
                     .clk               (clk),
                     .rst_n             (rst_n),
                     .clr_core          (clr_core),
                     .xfb_di_op         (xfb_di_op[1:0]),
                     .xfb_di_en         (xfb_di_en),
                     .xfb_di_clr        (xfb_di_clr),
                     .wb_d              (wb_d[127:0]),
                     .ecb_di            (ecb_di[127:0]),
                     .ccm_d             (ccm_d[127:0]),
                     .mac_do            (mac_do[127:0]));
   moo_ccm_d   CCD  (/*AUTOINST*/
                     // Outputs
                     .ccm_d             (ccm_d[127:0]),
                     // Inputs
                     .clk               (clk),
                     .rst_n             (rst_n),
                     .clr_core          (clr_core),
                     .ccm_d_op          (ccm_d_op[1:0]),
                     .ccm_d_en          (ccm_d_en),
                     .ccm_d_clr         (ccm_d_clr),
                     .ccm_b0            (ccm_b0[7:0]),
                     .iv                (iv[119:0]),
                     .ecb_do            (ecb_do[127:0]),
                     .xfb_do            (xfb_do[127:0]),
                     .wb_d              (wb_d[127:0]),
                     .size_msg          (size_msg[31:0]),
                     .msg_done          (msg_done));
   moo_mac_do  MDO  (/*AUTOINST*/
                     // Outputs
                     .mac_do            (mac_do[127:0]),
                     // Inputs
                     .clk               (clk),
                     .rst_n             (rst_n),
                     .clr_core          (clr_core),
                     .mac_do_op         (mac_do_op[1:0]),
                     .mac_do_en         (mac_do_en),
                     .mac_do_clr        (mac_do_clr),
                     .ecb_do            (ecb_do[127:0]),
                     .ghash             (ghash[127:0]),
                     .size_msg          (size_msg[3:0]));



endmodule // moo
