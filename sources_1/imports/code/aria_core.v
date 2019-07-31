module aria_core (/*AUTOARG*/
   // Outputs
   bc_d, bc_en, aria_rd, aria_rd_vld, aria_resp, aria_resp_vld, aria_wd_rdy,
   // Inputs
   clk, clr_aria, aria_sel, cw_blk_k, cw_iv, id_err, l3_en, l3_extend, l3_op,
   l3_rd_rdy, l3_size, l3_wd, l3_wd_vld, resp_rdy, rst_n, sw_blk_k, sw_iv
   ) ;
   output [31:0]        bc_d;
   output               bc_en;
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                clk;                    // To CMD of l3_cmd.v, ...
   input                clr_aria;               // To CMD of l3_cmd.v, ...
   input                aria_sel;               // To CMD of l3_cmd.v, ...
   input [255:0]        cw_blk_k;               // To KB of aria_key_buf.v
   input [127:0]        cw_iv;                  // To MI of moo_iv_buf.v, ...
   input                id_err;                 // To CMD of l3_cmd.v
   input                l3_en;                  // To CMD of l3_cmd.v, ...
   input [15:0]         l3_extend;              // To CMD of l3_cmd.v
   input [7:0]          l3_op;                  // To CMD of l3_cmd.v
   input                l3_rd_rdy;              // To L3R of l3_rd.v
   input [15:0]         l3_size;                // To CMD of l3_cmd.v
   input [31:0]         l3_wd;                  // To KB of aria_wr_buf.v
   input                l3_wd_vld;              // To KB of aria_wr_buf.v
   input                resp_rdy;               // To L3RP of l3_resp.v
   input                rst_n;                  // To CMD of l3_cmd.v, ...
   input [255:0]        sw_blk_k;               // To KB of aria_key_buf.v
   input [127:0]        sw_iv;                  // To MI of moo_iv_buf.v, ...
   // End of automatics
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [31:0]        aria_rd;                // From L3R of l3_rd.v
   output               aria_rd_vld;            // From L3R of l3_rd.v
   output [7:0]         aria_resp;              // From L3RP of l3_resp.v
   output               aria_resp_vld;          // From L3RP of l3_resp.v
   output               aria_wd_rdy;            // From KB of aria_wr_buf.v
   // End of automatics
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 add_size_en;            // From CU of aria_core_cu.v
   wire [7:0]           ccm_b0;                 // From MI of moo_iv_buf.v, ...
   wire [127:0]         ccm_d;                  // From MO of moo.v
   wire                 cmd_en;                 // From CMD of l3_cmd.v
   wire [15:0]          cmd_extend;             // From CMD of l3_cmd.v
   wire [7:0]           cmd_op;                 // From CMD of l3_cmd.v
   wire                 cmd_rdy;                // From CU of aria_core_cu.v
   wire [127:0]         ecb_do;                 // From MO of moo.v
   wire                 err_if_id;              // From CMD of l3_cmd.v
   wire                 err_if_rdy;             // From CMD of l3_cmd.v
   wire                 flg_hmac_dec;           // From MI of moo_iv_buf.v, ...
   wire                 flg_hmac_enc;           // From MI of moo_iv_buf.v, ...
   wire                 flg_rb_xfb;             // From MI of moo_iv_buf.v, ...
   wire                 gcm_mac_final;          // From CU of aria_core_cu.v
   wire [127:0]         ghash;                  // From GH of moo_ghash.v
   wire                 ghash_clr;              // From CU of aria_core_cu.v
   wire                 ghash_en;               // From CU of aria_core_cu.v
   wire [1:0]           ghash_op;               // From CU of aria_core_cu.v
   wire                 ghash_rdy;              // From GH of moo_ghash.v
   wire [15:0]          init_size;              // From MI of moo_iv_buf.v, ...
   wire [127:0]         iv;                     // From MI of moo_iv_buf.v, ...
   wire                 iv_clr;                 // From CU of aria_core_cu.v
   wire                 iv_en;                  // From CU of aria_core_cu.v
   wire                 iv_gnc;                 // From CU of aria_core_cu.v
   wire                 kb_clr;                 // From CU of aria_core_cu.v
   wire                 kb_d_rdy;               // From KB of aria_key_buf.v
   wire                 kb_d_vld;               // From CU of aria_core_cu.v
   wire                 kb_en;                  // From CU of aria_core_cu.v
   wire [1:0]           kb_op;                  // From CU of aria_core_cu.v
   wire [255:0]         key;                    // From KB of aria_key_buf.v
   wire [127:0]         mac_do;                 // From MO of moo.v
   wire                 moo_add;                // From MI of moo_iv_buf.v, ...
   wire                 moo_add_lst;            // From CU of aria_core_cu.v
   wire                 moo_add_rdy;            // From MO of moo.v
   wire                 moo_add_vld;            // From CU of aria_core_cu.v
   wire                 moo_clr;                // From CU of aria_core_cu.v
   wire                 moo_di_lst;             // From CU of aria_core_cu.v
   wire                 moo_di_rdy;             // From MO of moo.v
   wire                 moo_di_vld;             // From CU of aria_core_cu.v
   wire                 moo_do_rdy;             // From CU of aria_core_cu.v
   wire                 moo_do_vld;             // From MO of moo.v
   wire                 moo_done;               // From MO of moo.v
   wire                 moo_en;                 // From CU of aria_core_cu.v
   wire [3:0]           moo_op;                 // From MI of moo_iv_buf.v, ...
   wire                 moo_rdy;                // From MO of moo.v
   wire                 msg_done;               // From MS of moo_size_buf.v
   wire                 msg_lst;                // From MS of moo_size_buf.v
   wire                 rb_d_rdy;               // From KB of aria_rd_buf.v
   wire                 rb_d_vld;               // From CU of aria_core_cu.v
   wire                 rb_done;                // From KB of aria_rd_buf.v
   wire                 rb_en;                  // From CU of aria_core_cu.v
   wire [1:0]           rb_op;                  // From CU of aria_core_cu.v
   wire [31:0]          rd_d;                   // From KB of aria_rd_buf.v
   wire                 rd_en;                  // From L3R of l3_rd.v
   wire                 rd_open;                // From CU of aria_core_cu.v
   wire                 remain_nxt;             // From CU of aria_core_cu.v
   wire [31:0]          remain_size;            // From MS of moo_size_buf.v
   wire                 remain_up;              // From CU of aria_core_cu.v
   wire                 resp_done;              // From CU of aria_core_cu.v
   wire [1:0]           resp_err;               // From CU of aria_core_cu.v
   wire [15:0]          size_add;               // From MS of moo_size_buf.v
   wire [31:0]          size_msg;               // From KB of aria_wr_buf.v
   wire [127:0]         wb_d;                   // From KB of aria_wr_buf.v
   wire                 wb_d_lst;               // From KB of aria_wr_buf.v
   wire                 wb_d_rdy;               // From CU of aria_core_cu.v
   wire                 wb_d_vld;               // From KB of aria_wr_buf.v
   wire                 wb_en;                  // From CU of aria_core_cu.v
   wire                 wb_one;                 // From CU of aria_core_cu.v
   wire [1:0]           wb_op;                  // From CU of aria_core_cu.v
   wire                 wb_op_rdy;              // From KB of aria_wr_buf.v
   wire [15:0]          wr_size;                // From CMD of l3_cmd.v
   wire [127:0]         xfb_do;                 // From MO of moo.v
   // End of automatics
   wire                 warn_ksize;             // From MO of moo.v
   wire                 warn_rterm;             // From MO of moo.v
   wire                 bc_dec_en;              // From KB of aria_wr_buf.v
   wire   [31:0]        bc_enc;                 // From KB of aria_rd_buf.v
   wire                 bc_enc_en;              // From KB of aria_rd_buf.v
   wire                 bc_en;
   wire [31:0]          bc_d;

   assign bc_en = bc_enc_en | bc_dec_en;
   assign bc_d  = bc_enc_en ? bc_enc : l3_wd;

   l3_cmd        CMD  (
                       // Outputs
                       .err_if_rdy      (err_if_rdy),
                       .err_if_id       (err_if_id),
                       .cmd_en          (cmd_en),
                       .cmd_op          (cmd_op[7:0]),
                       .cmd_extend      (cmd_extend[15:0]),
                       .wr_size         (wr_size[15:0]),
                       // Inputs
                       .clk             (clk),
                       .rst_n           (rst_n),
                       .clr_core        (clr_aria),
                       .core_sel        (aria_sel),
                       .id_err          (id_err),
                       .l3_en           (l3_en),
                       .l3_op           (l3_op[7:0]),
                       .l3_extend       (l3_extend[15:0]),
                       .l3_size         (l3_size[15:0]),
                       .cmd_rdy         (cmd_rdy));

   l3_rd         L3R  (
                       .rd_addr         (),
                       // Outputs
                       .core_rd_vld     (aria_rd_vld),
                       .core_rd         (aria_rd[31:0]),
                       .rd_en           (rd_en),
                       // Inputs
                       .clk             (clk),
                       .rst_n           (rst_n),
                       .clr_core        (clr_aria),
                       .cmd_en          (cmd_en),
                       .cmd_extend      (cmd_extend[15:0]),
                       .rd_open         (rd_open),
                       .l3_rd_rdy       (l3_rd_rdy),
                       .rd_d            (rd_d[31:0]));

   l3_resp       L3RP (
                       .resp_res        ({2'd0, warn_ksize, warn_rterm}),
                       // Outputs
                       .core_resp       (aria_resp[7:0]),
                       .core_resp_vld   (aria_resp_vld),
                       // Inputs
                       .clk             (clk),
                       .rst_n           (rst_n),
                       .clr_core        (clr_aria),
                       .l3_en           (l3_en),
                       .core_sel        (aria_sel),
                       .err_if_id       (err_if_id),
                       .err_if_rdy      (err_if_rdy),
                       .resp_done       (resp_done),
                       .resp_err        (resp_err[1:0]),
                       .resp_rdy        (resp_rdy));


   moo_size_buf   MS   (
                        // Outputs
                        .msg_done       (msg_done),
                        .msg_lst        (msg_lst),
                        .remain_size    (remain_size[31:0]),
                        .size_add       (size_add[15:0]),
                        // Inputs
                        .clk            (clk),
                        .rst_n          (rst_n),
                        .clr_core       (clr_aria),
                        .size_msg       (size_msg[31:0]),
                        .remain_nxt     (remain_nxt),
                        .remain_up      (remain_up),
                        .add_size_en    (add_size_en),
                        .wr_size        (wr_size[15:0]));

   aria_core_cu   CU   (
                        // Outputs
                        .cmd_rdy        (cmd_rdy),
                        .rd_open        (rd_open),
                        .resp_done      (resp_done),
                        .resp_err       (resp_err[1:0]),
                        .iv_en          (iv_en),
                        .iv_clr         (iv_clr),
                        .iv_gnc         (iv_gnc),
                        .wb_op          (wb_op[1:0]),
                        .wb_en          (wb_en),
                        .wb_one         (wb_one),
                        .wb_d_rdy       (wb_d_rdy),
                        .rb_op          (rb_op[1:0]),
                        .rb_en          (rb_en),
                        .rb_d_vld       (rb_d_vld),
                        .kb_op          (kb_op[1:0]),
                        .kb_en          (kb_en),
                        .kb_clr         (kb_clr),
                        .kb_d_vld       (kb_d_vld),
                        .moo_en         (moo_en),
                        .moo_clr        (moo_clr),
                        .moo_di_vld     (moo_di_vld),
                        .moo_di_lst     (moo_di_lst),
                        .moo_do_rdy     (moo_do_rdy),
                        .moo_add_vld    (moo_add_vld),
                        .moo_add_lst    (moo_add_lst),
                        .gcm_mac_final  (gcm_mac_final),
                        .add_size_en    (add_size_en),
                        .remain_nxt     (remain_nxt),
                        .remain_up      (remain_up),
                        .ghash_op       (ghash_op[1:0]),
                        .ghash_en       (ghash_en),
                        .ghash_clr      (ghash_clr),
                        // Inputs
                        .clk            (clk),
                        .rst_n          (rst_n),
                        .clr_core       (clr_aria),
                        .flg_hmac_dec   (flg_hmac_dec),
                        .flg_hmac_enc   (flg_hmac_enc),
                        .flg_rb_xfb     (flg_rb_xfb),
                        .ghash_rdy      (ghash_rdy),
                        .cmd_en         (cmd_en),
                        .cmd_op         (cmd_op[7:0]),
                        .cmd_extend     (cmd_extend[15:0]),
                        .wr_size        (wr_size[15:0]),
                        .init_size      (init_size[15:0]),
                        .moo_op         (moo_op[3:0]),
                        .wb_op_rdy      (wb_op_rdy),
                        .wb_d_vld       (wb_d_vld),
                        .wb_d_lst       (wb_d_lst),
                        .rb_d_rdy       (rb_d_rdy),
                        .rb_done        (rb_done),
                        .kb_d_rdy       (kb_d_rdy),
                        .moo_done       (moo_done),
                        .moo_di_rdy     (moo_di_rdy),
                        .moo_do_vld     (moo_do_vld),
                        .moo_add_rdy    (moo_add_rdy),
                        .moo_rdy        (moo_rdy),
                        .remain_size    (remain_size[31:0]),
                        .msg_lst        (msg_lst));
   aria_key_buf   KB   (
                        // Outputs
                        .kb_d_rdy       (kb_d_rdy),
                        .key            (key[255:0]),
                        // Inputs
                        .clk            (clk),
                        .rst_n          (rst_n),
                        .clr_core       (clr_aria),
                        .kb_op          (kb_op[1:0]),
                        .kb_en          (kb_en),
                        .kb_clr         (kb_clr),
                        .wb_d           (wb_d[127:0]),
                        .kb_d_vld       (kb_d_vld),
                        .sw_blk_k       (sw_blk_k[255:0]),
                        .cw_blk_k       (cw_blk_k[255:0]));
   aria_rd_buf    RB   (
                        .bc_enc_en      (bc_enc_en),
                        .bc_enc         (bc_enc[31:0]),
                        // Outputs
                        .rd_d           (rd_d[31:0]),
                        .rb_d_rdy       (rb_d_rdy),
                        .rb_done        (rb_done),
                        // Inputs
                        .clk            (clk),
                        .rst_n          (rst_n),
                        .clr_core       (clr_aria),
                        .rd_en          (rd_en),
                        .cmd_extend     (cmd_extend[15:0]),
                        .rb_op          (rb_op[1:0]),
                        .rb_en          (rb_en),
                        .ecb_do         (ecb_do[127:0]),
                        .xfb_do         (xfb_do[127:0]),
                        .mac_do         (mac_do[127:0]),
                        .rb_d_vld       (rb_d_vld));
   aria_wr_buf    WB   (
                        .bc_dec_en      (bc_dec_en),
                        // Outputs
                        .core_wd_rdy    (aria_wd_rdy),
                        .wb_op_rdy      (wb_op_rdy),
                        .size_msg       (size_msg[31:0]),
                        .wb_d           (wb_d[127:0]),
                        .wb_d_vld       (wb_d_vld),
                        .wb_d_lst       (wb_d_lst),
                        // Inputs
                        .clk            (clk),
                        .rst_n          (rst_n),
                        .clr_core       (clr_aria),
                        .cmd_en         (cmd_en),
                        .wr_size        (wr_size[15:0]),
                        .l3_wd          (l3_wd[31:0]),
                        .l3_wd_vld      (l3_wd_vld),
                        .wb_op          (wb_op[1:0]),
                        .wb_en          (wb_en),
                        .wb_one         (wb_one),
                        .wb_d_rdy       (wb_d_rdy));
   moo_iv_buf     MI   (
                        // Outputs
                        .init_size      (init_size[15:0]),
                        .moo_op         (moo_op[3:0]),
                        .moo_add        (moo_add),
                        .flg_hmac_dec   (flg_hmac_dec),
                        .flg_hmac_enc   (flg_hmac_enc),
                        .flg_rb_xfb     (flg_rb_xfb),
                        .iv             (iv[127:0]),
                        .ccm_b0         (ccm_b0[7:0]),
                        // Inputs
                        .clk            (clk),
                        .rst_n          (rst_n),
                        .clr_core       (clr_aria),
                        .wb_d           (wb_d[127:0]),
                        .sw_iv          (sw_iv[127:0]),
                        .cw_iv          (cw_iv[127:0]),
                        .ghash          (ghash[127:0]),
                        .cmd_op         (cmd_op[4:0]),
                        .wr_size        (wr_size[15:0]),
                        .iv_en          (iv_en),
                        .iv_clr         (iv_clr),
                        .iv_gnc         (iv_gnc));
   moo            MO   (
                        .key_size       (cmd_op[6:5]),
                        .moo_key_rdy    (),
                        .warn_ksize     (warn_ksize),
                        .warn_rterm     (warn_rterm),
                        // Outputs
                        .ecb_do         (ecb_do[127:0]),
                        .xfb_do         (xfb_do[127:0]),
                        .mac_do         (mac_do[127:0]),
                        .ccm_d          (ccm_d[127:0]),
                        .moo_add_rdy    (moo_add_rdy),
                        .moo_di_rdy     (moo_di_rdy),
                        .moo_do_vld     (moo_do_vld),
                        .moo_done       (moo_done),
                        .moo_rdy        (moo_rdy),
                        // Inputs
                        .ccm_b0         (ccm_b0[7:0]),
                        .clk            (clk),
                        .clr_core       (clr_aria),
                        .gcm_mac_final  (gcm_mac_final),
                        .ghash          (ghash[127:0]),
                        .iv             (iv[127:0]),
                        .key            (key[255:0]),
                        .moo_add        (moo_add),
                        .moo_add_lst    (moo_add_lst),
                        .moo_add_vld    (moo_add_vld),
                        .moo_clr        (moo_clr),
                        .moo_di_lst     (moo_di_lst),
                        .moo_di_vld     (moo_di_vld),
                        .moo_do_rdy     (moo_do_rdy),
                        .moo_en         (moo_en),
                        .moo_op         (moo_op[3:0]),
                        .msg_done       (msg_done),
                        .rst_n          (rst_n),
                        .size_msg       (size_msg[31:0]),
                        .wb_d           (wb_d[127:0]));
   moo_ghash      GH   (
                        // Outputs
                        .ghash_rdy      (ghash_rdy),
                        .ghash          (ghash[127:0]),
                        // Inputs
                        .clk            (clk),
                        .rst_n          (rst_n),
                        .clr_core       (clr_aria),
                        .ghash_op       (ghash_op[1:0]),
                        .ghash_en       (ghash_en),
                        .ghash_clr      (ghash_clr),
                        .ccm_d          (ccm_d[127:0]),
                        .wb_d           (wb_d[127:0]),
                        .xfb_do         (xfb_do[127:0]),
                        .wr_size        (wr_size[15:0]),
                        .size_add       (size_add[15:0]),
                        .size_msg       (size_msg[31:0]),
                        .msg_done       (msg_done));

endmodule // aria_core

