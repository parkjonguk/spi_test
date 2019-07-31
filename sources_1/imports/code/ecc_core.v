module ecc_core (/*AUTOARG*/
   // Outputs
   ecdh_sk, ecc_rd, ecc_rd_vld, ecc_resp, ecc_resp_vld, ecc_wd_rdy,
   ecdh_sk_update,
   // Inputs
   cert_msg, clk, clr_ecc, ecc_sel, id_err, k, l3_en, l3_extend, l3_op,
   l3_rd_rdy, l3_size, l3_wd, l3_wd_vld, resp_rdy, rst_n, ss_expire
   ) ;
   output [255:0]       ecdh_sk;
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [255:0]        cert_msg;               // To MEM of ecc_mem.v
   input                clk;                    // To HD of l3.v, ...
   input                clr_ecc;                // To CU of ecc_core_cu.v
   input                ecc_sel;               // To HD of l3.v
   input                id_err;                 // To HD of l3.v
   input [255:0]        k;                      // To MEM of ecc_mem.v
   input                l3_en;                  // To HD of l3.v
   input [15:0]         l3_extend;              // To HD of l3.v
   input [7:0]          l3_op;                  // To HD of l3.v
   input                l3_rd_rdy;              // To HD of l3.v
   input [15:0]         l3_size;                // To HD of l3.v
   input [31:0]         l3_wd;                  // To HD of l3.v
   input                l3_wd_vld;              // To HD of l3.v
   input                resp_rdy;               // To HD of l3.v
   input                rst_n;                  // To HD of l3.v, ...
   input                ss_expire;              // To CU of ecc_core_cu.v
   // End of automatics
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [31:0]        ecc_rd;                // From HD of l3.v
   output               ecc_rd_vld;            // From HD of l3.v
   output [7:0]         ecc_resp;              // From HD of l3.v
   output               ecc_resp_vld;          // From HD of l3.v
   output               ecc_wd_rdy;            // From HD of l3.v
   output               ecdh_sk_update;         // From CU of ecc_core_cu.v
   // End of automatics
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [255:0]         Qx;                     // From MEM of ecc_mem.v
   wire [255:0]         Qy;                     // From MEM of ecc_mem.v
   wire                 flg_k_zero;
   wire                 flg_d_zero;
   wire                 cmd_en;                 // From HD of l3.v
   wire [15:0]          cmd_extend;             // From HD of l3.v
   wire [7:0]           cmd_op;                 // From HD of l3.v
   wire                 cmd_rdy;                // From CU of ecc_core_cu.v
   wire                 ecc_clr;                // From CU of ecc_core_cu.v
   wire                 ecc_en;                 // From CU of ecc_core_cu.v
   wire                 ecc_rdy;                // From EC of ecc.v
   wire [255:0]         hash_msg;               // From MEM of ecc_mem.v
   wire [255:0]         in_ds;                  // From MEM of ecc_mem.v
   wire [255:0]         in_kr;                  // From MEM of ecc_mem.v
   wire                 load_d;                 // From CU of ecc_core_cu.v
   wire                 load_hash;              // From CU of ecc_core_cu.v
   wire                 load_key;               // From CU of ecc_core_cu.v
   wire                 load_rcv;               // From CU of ecc_core_cu.v
   wire                 load_res;               // From CU of ecc_core_cu.v
   wire                 rcv_done;               // From RCV of ecc_core_rcv.v
   wire [13:0]          rd_addr;                // From HD of l3.v
   wire [31:0]          rd_d;                   // From MEM of ecc_mem.v
   wire                 rd_open;                // From CU of ecc_core_cu.v
   wire                 resp_done;              // From CU of ecc_core_cu.v
   wire [1:0]           resp_err;               // From CU of ecc_core_cu.v
   wire                 set_clr;                // From CU of ecc_core_cu.v
   wire [13:0]          wr_addr;                // From HD of l3.v
   wire [31:0]          wr_d;                   // From HD of l3.v
   wire                 wr_en;                  // From HD of l3.v
   wire                 wr_open;                // From CU of ecc_core_cu.v
   wire [15:0]          wr_size;                // From HD of l3.v
   wire [255:0]         x;                      // From EC of ecc.v
   wire [255:0]         y;                      // From EC of ecc.v
   // End of automatics
   wire [255:0]         ecdh_sk;
   wire                 verify;
   assign ecdh_sk = x;
   assign verify  = y[0];

   l3           HD (
                    .resp_res           ({3'd0, resp_veri}),
                    .rd_en              (),
                    .clr_core           (clr_ecc),
                    .core_rd            (ecc_rd[31:0]),
                    .core_rd_vld        (ecc_rd_vld),
                    .core_resp          (ecc_resp[7:0]),
                    .core_resp_vld      (ecc_resp_vld),
                    .core_wd_rdy        (ecc_wd_rdy),
                    .core_sel           (ecc_sel),
                    /*AUTOINST*/
                    // Outputs
                    .wr_size            (wr_size[15:0]),
                    .cmd_extend         (cmd_extend[15:0]),
                    .cmd_en             (cmd_en),
                    .cmd_op             (cmd_op[7:0]),
                    .rd_addr            (rd_addr[13:0]),
                    .wr_addr            (wr_addr[13:0]),
                    .wr_d               (wr_d[31:0]),
                    .wr_en              (wr_en),
                    // Inputs
                    .clk                (clk),
                    .cmd_rdy            (cmd_rdy),
                    .id_err             (id_err),
                    .l3_en              (l3_en),
                    .l3_extend          (l3_extend[15:0]),
                    .l3_op              (l3_op[7:0]),
                    .l3_rd_rdy          (l3_rd_rdy),
                    .l3_size            (l3_size[15:0]),
                    .l3_wd              (l3_wd[31:0]),
                    .l3_wd_vld          (l3_wd_vld),
                    .rd_d               (rd_d[31:0]),
                    .rd_open            (rd_open),
                    .resp_done          (resp_done),
                    .resp_err           (resp_err[1:0]),
                    .resp_rdy           (resp_rdy),
                    .rst_n              (rst_n),
                    .wr_open            (wr_open));


   ecc          EC  (
                     .ecc_op            (cmd_op[1:0]),
                     /*AUTOINST*/
                     // Outputs
                     .x                 (x[255:0]),
                     .y                 (y[255:0]),
                     .ecc_rdy           (ecc_rdy),
                     // Inputs
                     .Qx                (Qx[255:0]),
                     .Qy                (Qy[255:0]),
                     .clk               (clk),
                     .ecc_clr           (ecc_clr),
                     .ecc_en            (ecc_en),
                     .hash_msg          (hash_msg[255:0]),
                     .in_ds             (in_ds[255:0]),
                     .in_kr             (in_kr[255:0]),
                     .rst_n             (rst_n));
   ecc_core_cu  CU  (
                     .resp_veri         (resp_veri),
                     .verify            (verify),
                     .flg_k_zero        (flg_k_zero),
                     .flg_d_zero        (flg_d_zero),
                     /*AUTOINST*/
                     // Outputs
                     .cmd_rdy           (cmd_rdy),
                     .resp_done         (resp_done),
                     .resp_err          (resp_err[1:0]),
                     .rd_open           (rd_open),
                     .wr_open           (wr_open),
                     .load_hash         (load_hash),
                     .load_key          (load_key),
                     .load_res          (load_res),
                     .load_d            (load_d),
                     .set_clr           (set_clr),
                     .ecdh_sk_update    (ecdh_sk_update),
                     .load_rcv          (load_rcv),
                     .ecc_clr           (ecc_clr),
                     .ecc_en            (ecc_en),
                     // Inputs
                     .clk               (clk),
                     .rst_n             (rst_n),
                     .clr_ecc           (clr_ecc),
                     .ss_expire         (ss_expire),
                     .cmd_en            (cmd_en),
                     .cmd_op            (cmd_op[7:0]),
                     .wr_size           (wr_size[15:0]),
                     .cmd_extend        (cmd_extend[15:0]),
                     .rcv_done          (rcv_done),
                     .ecc_rdy           (ecc_rdy));
   ecc_core_rcv RCV (/*AUTOINST*/
                     // Outputs
                     .rcv_done          (rcv_done),
                     // Inputs
                     .clk               (clk),
                     .rst_n             (rst_n),
                     .wr_en             (wr_en),
                     .wr_size           (wr_size[15:0]),
                     .load_rcv          (load_rcv));
   ecc_mem      MEM (/*AUTOINST*/
                     // Outputs
                     .rd_d              (rd_d[31:0]),
                     .Qx                (Qx[255:0]),
                     .Qy                (Qy[255:0]),
                     .in_ds             (in_ds[255:0]),
                     .in_kr             (in_kr[255:0]),
                     .hash_msg          (hash_msg[255:0]),
                     .flg_k_zero        (flg_k_zero),
                     .flg_d_zero        (flg_d_zero),
                     // Inputs
                     .clk               (clk),
                     .rst_n             (rst_n),
                     .load_hash         (load_hash),
                     .load_key          (load_key),
                     .load_res          (load_res),
                     .load_d            (load_d),
                     .set_clr           (set_clr),
                     .cmd_op            (cmd_op[1:0]),
                     .wr_addr           (wr_addr[5:0]),
                     .wr_d              (wr_d[31:0]),
                     .wr_en             (wr_en),
                     .cert_msg          (cert_msg[255:0]),
                     .k                 (k[255:0]),
                     .x                 (x[255:0]),
                     .y                 (y[255:0]),
                     .rd_addr           (rd_addr[3:0]));



endmodule // ecc_core
