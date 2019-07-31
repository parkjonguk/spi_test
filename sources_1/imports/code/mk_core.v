module mk_core (/*AUTOARG*/
   // Outputs
   id_err, mk_rd, mk_rd_vld, mk_resp, mk_resp_vld, mk_wd_rdy, k, psk,
   // Inputs
   clk, clr_mk, mk_sel, ecdh_sk, ecdh_sk_update, l3_op, l3_en, l3_extend, l3_id,
   l3_rd_rdy, l3_size, l3_wd, l3_wd_vld, resp_rdy, rst_n
   ) ;
   output id_err;
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                clk;                    // To CU of mk_core_cu.v, ...
   input                clr_mk;                 // To CU of mk_core_cu.v, ...
   input                mk_sel;               // To L3 of l3.v
   input [255:0]        ecdh_sk;                // To KR of kreg.v
   input                ecdh_sk_update;         // To KR of kreg.v
   input [7:0]          l3_op;                 // To L3 of l3.v
   input                l3_en;                  // To L3 of l3.v
   input [15:0]         l3_extend;              // To L3 of l3.v
   input [3:0]          l3_id;                  // To CU of mk_core_cu.v, ...
   input                l3_rd_rdy;              // To L3 of l3.v
   input [15:0]         l3_size;                // To L3 of l3.v
   input [31:0]         l3_wd;                  // To L3 of l3.v
   input                l3_wd_vld;              // To L3 of l3.v
   input                resp_rdy;               // To L3 of l3.v
   input                rst_n;                  // To CU of mk_core_cu.v, ...
   // End of automatics
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [31:0]        mk_rd;                // From L3 of l3.v
   output               mk_rd_vld;            // From L3 of l3.v
   output [7:0]         mk_resp;              // From L3 of l3.v
   output               mk_resp_vld;          // From L3 of l3.v
   output               mk_wd_rdy;            // From L3 of l3.v
   output [255:0]       k;                      // From KR of kreg.v
   output [255:0]       psk;                    // From KR of kreg.v
   // End of automatics
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 cmd_en;                 // From L3 of l3.v
   wire [15:0]          cmd_extend;             // From L3 of l3.v
   wire [7:0]           cmd_op;                 // From L3 of l3.v
   wire                 cmd_rdy;                // From CU of mk_core_cu.v
   wire [13:0]          rd_addr;                // From L3 of l3.v
   wire [31:0]          rd_d;                   // From KR of kreg.v
   wire                 rd_open;                // From CU of mk_core_cu.v
   wire                 resp_done;              // From CU of mk_core_cu.v
   wire [1:0]           resp_err;               // From CU of mk_core_cu.v
   wire                 ss_clr;                 // From CU of mk_core_cu.v
   wire                 ss_set;                 // From CU of mk_core_cu.v
   wire [2:0]           ssid;                   // From SS of ss_mngr.v
   wire                 ssid_vld;               // From SS of ss_mngr.v
   wire [13:0]          wr_addr;                // From L3 of l3.v
   wire [31:0]          wr_d;                   // From L3 of l3.v
   wire                 wr_en;                  // From L3 of l3.v
   wire                 wr_open;                // From CU of mk_core_cu.v
   wire [15:0]          wr_size;                // From L3 of l3.v
   // End of automatics

   wire                 err_id;                 // From SS of ss_mngr.v
   wire                 id_err;
   assign id_err = (!ssid_vld) | err_id;

   mk_core_cu   CU (
                    // Outputs
                    .cmd_rdy            (cmd_rdy),
                    .ss_clr             (ss_clr),
                    .ss_set             (ss_set),
                    .wr_open            (wr_open),
                    .rd_open            (rd_open),
                    .resp_done          (resp_done),
                    .resp_err           (resp_err[1:0]),
                    // Inputs
                    .clk                (clk),
                    .rst_n              (rst_n),
                    .clr_mk             (clr_mk),
                    .cmd_en             (cmd_en),
                    .cmd_op             (cmd_op[7:3]),
                    .cmd_extend         (cmd_extend[15:0]),
                    .l3_id              (l3_id[2:0]),
                    .ssid               (ssid[2:0]),
                    .ssid_vld           (ssid_vld),
                    .wr_size            (wr_size[15:0]),
                    .wr_addr            (wr_addr[13:0]),
                    .wr_en              (wr_en));
   ss_mngr      SS (
                    // Outputs
                    .ssid               (ssid[2:0]),
                    .ssid_vld           (ssid_vld),
                    .err_id             (err_id),
                    // Inputs
                    .clk                (clk),
                    .rst_n              (rst_n),
                    .clr_mk             (clr_mk),
                    .ss_set             (ss_set),
                    .ss_clr             (ss_clr),
                    .l3_id              (l3_id[3:0]));
   kreg         KR (
                    .wrd_id             (cmd_op[2:0]),
                    .wrd_sk             (cmd_op[3]),
                    // Outputs
                    .rd_d               (rd_d[31:0]),
                    .k                  (k[255:0]),
                    .psk                (psk[255:0]),
                    // Inputs
                    .clk                (clk),
                    .rst_n              (rst_n),
                    .wr_en              (wr_en),
                    .wr_d               (wr_d[31:0]),
                    .wr_addr            (wr_addr[2:0]),
                    .rd_addr            (rd_addr[2:0]),
                    .ssid               (ssid[2:0]),
                    .ssid_vld           (ssid_vld),
                    .ecdh_sk_update     (ecdh_sk_update),
                    .ecdh_sk            (ecdh_sk[255:0]));
   l3            L3 (
                     .id_err            (1'b0),
                     .clr_core          (clr_mk),
                     .rd_en             (),
                     .resp_res          (4'd0),
                     // Outputs
                     .wr_size           (wr_size[15:0]),
                     .cmd_extend        (cmd_extend[15:0]),
                     .cmd_en            (cmd_en),
                     .cmd_op            (cmd_op[7:0]),
                     .core_rd           (mk_rd[31:0]),
                     .core_rd_vld       (mk_rd_vld),
                     .core_resp         (mk_resp[7:0]),
                     .core_resp_vld     (mk_resp_vld),
                     .core_wd_rdy       (mk_wd_rdy),
                     .rd_addr           (rd_addr[13:0]),
                     .wr_addr           (wr_addr[13:0]),
                     .wr_d              (wr_d[31:0]),
                     .wr_en             (wr_en),
                     // Inputs
                     .clk               (clk),
                     .cmd_rdy           (cmd_rdy),
                     .core_sel          (mk_sel),
                     .l3_op             (l3_op[7:0]),
                     .l3_en             (l3_en),
                     .l3_extend         (l3_extend[15:0]),
                     .l3_rd_rdy         (l3_rd_rdy),
                     .l3_size           (l3_size[15:0]),
                     .l3_wd             (l3_wd[31:0]),
                     .l3_wd_vld         (l3_wd_vld),
                     .rd_d              (rd_d[31:0]),
                     .rd_open           (rd_open),
                     .resp_done         (resp_done),
                     .resp_err          (resp_err[1:0]),
                     .resp_rdy          (resp_rdy),
                     .rst_n             (rst_n),
                     .wr_open           (wr_open));

endmodule // mk_core
