module hash_core (/*AUTOARG*/
   // Outputs
   mac, hash_rd, hash_rd_vld, hash_resp, hash_resp_vld, hash_wd_rdy,
   ssk_addr, ssk_wr,
   // Inputs
   bc_d, bc_en, clk, clr_hash, hash_sel, cw_mac_k, id_err, l3_en, l3_extend,
   l3_op, l3_rd_rdy, l3_size, l3_wd, l3_wd_vld, psk, resp_rdy, rst_n,
   ss_expire, sw_mac_k
   ) ;
   output [383:0]       mac;
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [31:0]         bc_d;                   // To MB of msg_buf.v
   input                bc_en;                  // To MB of msg_buf.v
   input                clk;                    // To HD of l3.v, ...
   input                clr_hash;               // To CU of hash_core_cu.v, ...
   input                hash_sel;               // To HD of l3.v
   input [383:0]        cw_mac_k;               // To KB of key_buf.v
   input                id_err;                 // To HD of l3.v
   input                l3_en;                  // To HD of l3.v
   input [15:0]         l3_extend;              // To HD of l3.v
   input [7:0]          l3_op;                  // To HD of l3.v
   input                l3_rd_rdy;              // To HD of l3.v
   input [15:0]         l3_size;                // To HD of l3.v
   input [31:0]         l3_wd;                  // To HD of l3.v
   input                l3_wd_vld;              // To HD of l3.v
   input [255:0]        psk;                    // To KB of key_buf.v
   input                resp_rdy;               // To HD of l3.v
   input                rst_n;                  // To HD of l3.v, ...
   input                ss_expire;              // To CU of hash_core_cu.v
   input [383:0]        sw_mac_k;               // To KB of key_buf.v
   // End of automatics
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [31:0]        hash_rd;                // From HD of l3.v
   output               hash_rd_vld;            // From HD of l3.v
   output [7:0]         hash_resp;              // From HD of l3.v
   output               hash_resp_vld;          // From HD of l3.v
   output               hash_wd_rdy;            // From HD of l3.v
   output [3:0]         ssk_addr;               // From CU of hash_core_cu.v
   output               ssk_wr;                 // From CU of hash_core_cu.v
   // End of automatics
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 m_prf_i;
   wire                 m_prf_u;
   wire                 cmd_en;                 // From HD of l3.v
   wire [15:0]          cmd_extend;             // From HD of l3.v
   wire [7:0]           cmd_op;                 // From HD of l3.v
   wire                 cmd_rdy;                // From CU of hash_core_cu.v
   wire                 h_buf_clr;              // From CU of hash_core_cu.v
   wire                 h_buf_en;               // From CU of hash_core_cu.v
   wire                 h_buf_rdy;              // From HB of hash_buf.v
   wire                 h_buf_wrm;              // From CU of hash_core_cu.v
   wire                 hash_clr;               // From CU of hash_core_cu.v
   wire                 hash_done;              // From SHA of hash.v
   wire                 hash_en;                // From CU of hash_core_cu.v
   wire [511:0]         hash_f;                 // From SHA of hash.v
   wire                 hash_finish;            // From CU of hash_core_cu.v
   wire [511:0]         hash_m;                 // From HB of hash_buf.v
   wire [1023:0]        hash_nxt;               // From HB of hash_buf.v
   wire [511:0]         hash_o;                 // From SHA of hash.v
   wire [4:0]           hash_op;                // From CU of hash_core_cu.v
   wire                 hash_rdy;               // From SHA of hash.v
   wire                 hash_update;            // From HB of hash_buf.v
   wire                 k_buf_clr;              // From CU of hash_core_cu.v
   wire                 k_buf_en;               // From CU of hash_core_cu.v
   wire [1:0]           k_buf_op;               // From CU of hash_core_cu.v
   wire                 k_buf_wr;               // From CU of hash_core_cu.v
   wire [511:0]         key;                    // From KB of key_buf.v
   wire                 m_buf_clr;              // From CU of hash_core_cu.v
   wire                 m_buf_en;               // From CU of hash_core_cu.v
   wire [1:0]           m_buf_op;               // From CU of hash_core_cu.v
   wire                 m_buf_rdy;              // From MB of msg_buf.v
   wire [1023:0]        msg;                    // From MB of msg_buf.v
   wire [1:0]           msg_sel;                // From CU of hash_core_cu.v
   wire [31:0]          msg_size;               // From CU of hash_core_cu.v
   wire                 msg_update;             // From MB of msg_buf.v
   wire [383:0]         msk;                    // From SK of msk_buf.v
   wire                 msk_clr;                // From CU of hash_core_cu.v
   wire                 msk_en0;                // From CU of hash_core_cu.v
   wire                 msk_en1;                // From CU of hash_core_cu.v
   wire                 rcv_bc_d;               // From CU of hash_core_cu.v
   wire                 rcv_clr;                // From CU of hash_core_cu.v
   wire                 rcv_done;               // From RC of rcv_ctrl.v
   wire                 rcv_last;               // From RC of rcv_ctrl.v
   wire                 rcv_nxt0;               // From HB of hash_buf.v
   wire                 rcv_nxt1;               // From MB of msg_buf.v
   wire                 rcv_nxtk;               // From KB of key_buf.v
   wire [15:0]          rcv_size;               // From RC of rcv_ctrl.v
   wire                 rcv_wr_d;               // From CU of hash_core_cu.v
   wire [13:0]          rd_addr;                // From HD of l3.v
   wire [31:0]          rd_d;                   // From RDC of rd_ctrl.v
   wire                 rd_open;                // From CU of hash_core_cu.v
   wire                 resp_done;              // From CU of hash_core_cu.v
   wire [1:0]           resp_err;               // From CU of hash_core_cu.v
   wire                 s0_flg_384;             // From PC of prm_ctrl.v
   wire                 s0_prm_clr;             // From CU of hash_core_cu.v
   wire                 s0_prm_set;             // From CU of hash_core_cu.v
   wire                 s0_prm_vld;             // From PC of prm_ctrl.v
   wire                 s1_flg_384;             // From PC of prm_ctrl.v
   wire                 s1_prm_clr;             // From CU of hash_core_cu.v
   wire                 s1_prm_set;             // From CU of hash_core_cu.v
   wire                 s1_prm_vld;             // From PC of prm_ctrl.v
   wire [31:0]          size0;                  // From SC of size_ctrl.v
   wire                 size0_add;              // From CU of hash_core_cu.v
   wire                 size0_clr;              // From CU of hash_core_cu.v
   wire [31:0]          size1;                  // From SC of size_ctrl.v
   wire                 size1_clr;              // From CU of hash_core_cu.v
   wire                 size1_en;               // From CU of hash_core_cu.v
   wire [1:0]           size1_op;               // From CU of hash_core_cu.v
   wire [31:0]          wr_d;                   // From HD of l3.v
   wire                 wr_en;                  // From HD of l3.v
   wire                 wr_open;                // From CU of hash_core_cu.v
   wire [15:0]          wr_size;                // From HD of l3.v
   // End of automatics
   wire [383:0]         mac;

   assign mac = hash_f[511:128];
   l3           HD    (
                       .clr_core        (clr_hash),
                       .core_rd         (hash_rd[31:0]),
                       .core_rd_vld     (hash_rd_vld),
                       .core_resp       (hash_resp[7:0]),
                       .core_resp_vld   (hash_resp_vld),
                       .core_wd_rdy     (hash_wd_rdy),
                       .core_sel        (hash_sel),
                       .resp_res        (4'd0),
                       .rd_en           (),
                       .wr_addr         (),
                       /*AUTOINST*/
                       // Outputs
                       .wr_size         (wr_size[15:0]),
                       .cmd_extend      (cmd_extend[15:0]),
                       .cmd_en          (cmd_en),
                       .cmd_op          (cmd_op[7:0]),
                       .rd_addr         (rd_addr[13:0]),
                       .wr_d            (wr_d[31:0]),
                       .wr_en           (wr_en),
                       // Inputs
                       .clk             (clk),
                       .cmd_rdy         (cmd_rdy),
                       .id_err          (id_err),
                       .l3_en           (l3_en),
                       .l3_extend       (l3_extend[15:0]),
                       .l3_op           (l3_op[7:0]),
                       .l3_rd_rdy       (l3_rd_rdy),
                       .l3_size         (l3_size[15:0]),
                       .l3_wd           (l3_wd[31:0]),
                       .l3_wd_vld       (l3_wd_vld),
                       .rd_d            (rd_d[31:0]),
                       .rd_open         (rd_open),
                       .resp_done       (resp_done),
                       .resp_err        (resp_err[1:0]),
                       .resp_rdy        (resp_rdy),
                       .rst_n           (rst_n),
                       .wr_open         (wr_open));

   hash         SHA   (/*AUTOINST*/
                       // Outputs
                       .hash_f          (hash_f[511:0]),
                       .hash_o          (hash_o[511:0]),
                       .hash_done       (hash_done),
                       .hash_rdy        (hash_rdy),
                       // Inputs
                       .hash_m          (hash_m[511:0]),
                       .clk             (clk),
                       .hash_clr        (hash_clr),
                       .hash_en         (hash_en),
                       .hash_op         (hash_op[4:0]),
                       .key             (key[511:0]),
                       .msg             (msg[1023:0]),
                       .msg_size        (msg_size[31:0]),
                       .rst_n           (rst_n));


   hash_buf     HB    (/*AUTOINST*/
                       // Outputs
                       .h_buf_rdy       (h_buf_rdy),
                       .rcv_nxt0        (rcv_nxt0),
                       .hash_m          (hash_m[511:0]),
                       .hash_nxt        (hash_nxt[1023:0]),
                       .hash_update     (hash_update),
                       // Inputs
                       .clk             (clk),
                       .rst_n           (rst_n),
                       .s0_flg_384      (s0_flg_384),
                       .h_buf_en        (h_buf_en),
                       .h_buf_clr       (h_buf_clr),
                       .h_buf_wrm       (h_buf_wrm),
                       .wr_d            (wr_d[31:0]),
                       .wr_en           (wr_en),
                       .rcv_size        (rcv_size[1:0]),
                       .rcv_last        (rcv_last),
                       .hash_o          (hash_o[511:0]));
   hash_core_cu CU    (/*AUTOINST*/
                       // Outputs
                       .m_prf_i         (m_prf_i),
                       .m_prf_u         (m_prf_u),
                       .cmd_rdy         (cmd_rdy),
                       .wr_open         (wr_open),
                       .rd_open         (rd_open),
                       .resp_done       (resp_done),
                       .resp_err        (resp_err[1:0]),
                       .hash_finish     (hash_finish),
                       .msg_sel         (msg_sel),
                       .h_buf_clr       (h_buf_clr),
                       .h_buf_en        (h_buf_en),
                       .h_buf_wrm       (h_buf_wrm),
                       .m_buf_op        (m_buf_op[1:0]),
                       .m_buf_en        (m_buf_en),
                       .m_buf_clr       (m_buf_clr),
                       .k_buf_clr       (k_buf_clr),
                       .k_buf_en        (k_buf_en),
                       .k_buf_op        (k_buf_op[1:0]),
                       .k_buf_wr        (k_buf_wr),
                       .msk_clr         (msk_clr),
                       .msk_en0         (msk_en0),
                       .msk_en1         (msk_en1),
                       .s0_prm_set      (s0_prm_set),
                       .s0_prm_clr      (s0_prm_clr),
                       .s1_prm_set      (s1_prm_set),
                       .s1_prm_clr      (s1_prm_clr),
                       .rcv_wr_d        (rcv_wr_d),
                       .rcv_bc_d        (rcv_bc_d),
                       .rcv_clr         (rcv_clr),
                       .size0_clr       (size0_clr),
                       .size0_add       (size0_add),
                       .size1_en        (size1_en),
                       .size1_clr       (size1_clr),
                       .size1_op        (size1_op[1:0]),
                       .ssk_wr          (ssk_wr),
                       .ssk_addr        (ssk_addr[3:0]),
                       .hash_op         (hash_op[4:0]),
                       .hash_en         (hash_en),
                       .hash_clr        (hash_clr),
                       .msg_size        (msg_size[31:0]),
                       // Inputs
                       .clk             (clk),
                       .rst_n           (rst_n),
                       .clr_hash        (clr_hash),
                       .ss_expire       (ss_expire),
                       .cmd_en          (cmd_en),
                       .cmd_op          (cmd_op[7:0]),
                       .cmd_extend      (cmd_extend[15:0]),
                       .wr_size         (wr_size[15:0]),
                       .hash_update     (hash_update),
                       .msg_update      (msg_update),
                       .h_buf_rdy       (h_buf_rdy),
                       .m_buf_rdy       (m_buf_rdy),
                       .s0_prm_vld      (s0_prm_vld),
                       .s0_flg_384      (s0_flg_384),
                       .s1_prm_vld      (s1_prm_vld),
                       .s1_flg_384      (s1_flg_384),
                       .rcv_done        (rcv_done),
                       .size0           (size0[31:0]),
                       .size1           (size1[31:0]),
                       .hash_rdy        (hash_rdy),
                       .hash_done       (hash_done));
   key_buf      KB    (/*AUTOINST*/
                       // Outputs
                       .rcv_nxtk        (rcv_nxtk),
                       .key             (key[511:0]),
                       // Inputs
                       .clk             (clk),
                       .rst_n           (rst_n),
                       .k_buf_clr       (k_buf_clr),
                       .k_buf_en        (k_buf_en),
                       .k_buf_op        (k_buf_op[1:0]),
                       .wr_d            (wr_d[31:0]),
                       .wr_en           (wr_en),
                       .k_buf_wr        (k_buf_wr),
                       .psk             (psk[255:0]),
                       .msk             (msk[383:0]),
                       .sw_mac_k        (sw_mac_k[383:0]),
                       .cw_mac_k        (cw_mac_k[383:0]));
   msg_buf      MB    (/*AUTOINST*/
                       // Outputs
                       .m_buf_rdy       (m_buf_rdy),
                       .msg_update      (msg_update),
                       .rcv_nxt1        (rcv_nxt1),
                       .msg             (msg[1023:0]),
                       // Inputs
                       .clk             (clk),
                       .rst_n           (rst_n),
                       .s1_flg_384      (s1_flg_384),
                       .m_prf_i         (m_prf_i),
                       .m_prf_u         (m_prf_u),
                       .m_buf_op        (m_buf_op[1:0]),
                       .m_buf_en        (m_buf_en),
                       .m_buf_clr       (m_buf_clr),
                       .wr_d            (wr_d[31:0]),
                       .wr_en           (wr_en),
                       .bc_d            (bc_d[31:0]),
                       .bc_en           (bc_en),
                       .rcv_size        (rcv_size[1:0]),
                       .rcv_last        (rcv_last),
                       .hash_update     (hash_update),
                       .hash_finish     (hash_finish),
                       .hash_nxt        (hash_nxt[1023:0]),
                       .hash_f          (hash_f[511:0]),
                       .msg_sel         (msg_sel));
   msk_buf      SK    (/*AUTOINST*/
                       // Outputs
                       .msk             (msk[383:0]),
                       // Inputs
                       .clk             (clk),
                       .rst_n           (rst_n),
                       .msk_clr         (msk_clr),
                       .msk_en0         (msk_en0),
                       .msk_en1         (msk_en1),
                       .hash_f          (hash_f[511:128]));
   prm_ctrl     PC    (
                       .hflg            (cmd_op[4]),
                       /*AUTOINST*/
                       // Outputs
                       .s0_prm_vld      (s0_prm_vld),
                       .s0_flg_384      (s0_flg_384),
                       .s1_prm_vld      (s1_prm_vld),
                       .s1_flg_384      (s1_flg_384),
                       // Inputs
                       .clk             (clk),
                       .rst_n           (rst_n),
                       .clr_hash        (clr_hash),
                       .s0_prm_set      (s0_prm_set),
                       .s0_prm_clr      (s0_prm_clr),
                       .s1_prm_set      (s1_prm_set),
                       .s1_prm_clr      (s1_prm_clr));
   rcv_ctrl     RC    (/*AUTOINST*/
                       // Outputs
                       .rcv_last        (rcv_last),
                       .rcv_done        (rcv_done),
                       .rcv_size        (rcv_size[15:0]),
                       // Inputs
                       .clk             (clk),
                       .rst_n           (rst_n),
                       .wr_size         (wr_size[15:0]),
                       .cmd_extend      (cmd_extend[15:0]),
                       .rcv_wr_d        (rcv_wr_d),
                       .rcv_bc_d        (rcv_bc_d),
                       .rcv_clr         (rcv_clr),
                       .rcv_nxt0        (rcv_nxt0),
                       .rcv_nxt1        (rcv_nxt1),
                       .rcv_nxtk        (rcv_nxtk));
   rd_ctrl      RDC   (/*AUTOINST*/
                       // Outputs
                       .rd_d            (rd_d[31:0]),
                       // Inputs
                       .rd_addr         (rd_addr[3:0]),
                       .hash_f          (hash_f[511:128]));
   size_ctrl    SC    (/*AUTOINST*/
                       // Outputs
                       .size0           (size0[31:0]),
                       .size1           (size1[31:0]),
                       // Inputs
                       .clk             (clk),
                       .rst_n           (rst_n),
                       .s1_flg_384      (s1_flg_384),
                       .wr_size         (wr_size[15:0]),
                       .cmd_extend      (cmd_extend[15:0]),
                       .size0_clr       (size0_clr),
                       .size0_add       (size0_add),
                       .size1_clr       (size1_clr),
                       .size1_en        (size1_en),
                       .size1_op        (size1_op[1:0]));





endmodule // hash_core
