module crypto_core (/*AUTOARG*/
   // Outputs
   s_ahb_hresp, s_ahb_hready, s_ahb_hrdata, m_ahb_hwrite, m_ahb_hwdata,
   m_ahb_htrans, m_ahb_hsize, m_ahb_hburst, m_ahb_haddr,
   // Inputs
   reset_n, pin_crypto_clear, pin_disable_timeout, pin_loopback, clk,
   m_ahb_hrdata, m_ahb_hready, m_ahb_hresp, s_ahb_haddr, s_ahb_hburst,
   s_ahb_hsize, s_ahb_htrans, s_ahb_hwdata, s_ahb_hwrite
   ) ;
   input                reset_n;                  // To BRDG of crypto_bridge.v, ...
   input                pin_crypto_clear;
   input                pin_disable_timeout;
   input                pin_loopback;
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                clk;                    // To L2_T of l2.v, ...
   input [31:0]         m_ahb_hrdata;           // To L2_T of l2.v
   input                m_ahb_hready;           // To L2_T of l2.v
   input [1:0]          m_ahb_hresp;            // To L2_T of l2.v
   input [31:0]         s_ahb_haddr;            // To L2_T of l2.v
   input [2:0]          s_ahb_hburst;           // To L2_T of l2.v
   input [2:0]          s_ahb_hsize;            // To L2_T of l2.v
   input [1:0]          s_ahb_htrans;           // To L2_T of l2.v
   input [31:0]         s_ahb_hwdata;           // To L2_T of l2.v
   input                s_ahb_hwrite;           // To L2_T of l2.v
   /*AUTOINPUT*/
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [31:0]        m_ahb_haddr;            // From L2_T of l2.v
   output [2:0]         m_ahb_hburst;           // From L2_T of l2.v
   output [2:0]         m_ahb_hsize;            // From L2_T of l2.v
   output [1:0]         m_ahb_htrans;           // From L2_T of l2.v
   output [31:0]        m_ahb_hwdata;           // From L2_T of l2.v
   output               m_ahb_hwrite;           // From L2_T of l2.v
   output [31:0]        s_ahb_hrdata;           // From L2_T of l2.v
   output               s_ahb_hready;           // From L2_T of l2.v
   output [1:0]         s_ahb_hresp;            // From L2_T of l2.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [31:0]          aria_rd;                // From AR of aria_core.v
   wire                 aria_rd_vld;            // From AR of aria_core.v
   wire [7:0]           aria_resp;              // From AR of aria_core.v
   wire                 aria_resp_vld;          // From AR of aria_core.v
   wire                 aria_sel;               // From BR of bridge.v
   wire                 aria_wd_rdy;            // From AR of aria_core.v
   wire [31:0]          bc_d;                   // From AR of aria_core.v
   wire                 bc_en;                  // From AR of aria_core.v
   wire [255:0]         cw_blk_k;               // From SK of ssk_core.v
   wire [127:0]         cw_iv;                  // From SK of ssk_core.v
   wire [383:0]         cw_mac_k;               // From SK of ssk_core.v
   wire [31:0]          ecc_rd;                 // From EC of ecc_core.v
   wire                 ecc_rd_vld;             // From EC of ecc_core.v
   wire [7:0]           ecc_resp;               // From EC of ecc_core.v
   wire                 ecc_resp_vld;           // From EC of ecc_core.v
   wire                 ecc_sel;                // From BR of bridge.v
   wire                 ecc_wd_rdy;             // From EC of ecc_core.v
   wire [31:0]          hash_rd;                // From HC of hash_core.v
   wire                 hash_rd_vld;            // From HC of hash_core.v
   wire [7:0]           hash_resp;              // From HC of hash_core.v
   wire                 hash_resp_vld;          // From HC of hash_core.v
   wire                 hash_sel;               // From BR of bridge.v
   wire                 hash_wd_rdy;            // From HC of hash_core.v
   wire                 l3_en;                  // From L2_T of l2.v
   wire [15:0]          l3_extend;              // From L2_T of l2.v
   wire [3:0]           l3_id;                  // From L2_T of l2.v
   wire [7:0]           l3_op;                  // From L2_T of l2.v
   wire [31:0]          l3_rd;                  // From BR of bridge.v
   wire                 l3_rd_rdy;              // From L2_T of l2.v
   wire                 l3_rd_vld;              // From BR of bridge.v
   wire [3:0]           l3_sel;                 // From L2_T of l2.v
   wire [15:0]          l3_size;                // From L2_T of l2.v
   wire [31:0]          l3_wd;                  // From L2_T of l2.v
   wire                 l3_wd_rdy;              // From BR of bridge.v
   wire                 l3_wd_vld;              // From L2_T of l2.v
   wire [383:0]         mac;                    // From HC of hash_core.v
   wire [31:0]          mk_rd;                  // From MK_T of mk_core.v
   wire                 mk_rd_vld;              // From MK_T of mk_core.v
   wire [7:0]           mk_resp;                // From MK_T of mk_core.v
   wire                 mk_resp_vld;            // From MK_T of mk_core.v
   wire                 mk_sel;                 // From BR of bridge.v
   wire                 mk_wd_rdy;              // From MK_T of mk_core.v
   wire [7:0]           resp;                   // From BR of bridge.v
   wire                 resp_rdy;               // From L2_T of l2.v
   wire                 resp_vld;               // From BR of bridge.v
   wire [3:0]           ssk_addr;               // From HC of hash_core.v
   wire [31:0]          ssk_rd;                 // From SK of ssk_core.v
   wire                 ssk_rd_vld;             // From SK of ssk_core.v
   wire [7:0]           ssk_resp;               // From SK of ssk_core.v
   wire                 ssk_resp_vld;           // From SK of ssk_core.v
   wire                 ssk_sel;                // From BR of bridge.v
   wire                 ssk_wd_rdy;             // From SK of ssk_core.v
   wire                 ssk_wr;                 // From HC of hash_core.v
   wire [255:0]         sw_blk_k;               // From SK of ssk_core.v
   wire [127:0]         sw_iv;                  // From SK of ssk_core.v
   wire [383:0]         sw_mac_k;               // From SK of ssk_core.v
   // End of automatics
   wire                id_err;                 // From MK_T of mk_core.v
   wire  [255:0]       k;                      // From MK_T of mk_core.v
   wire  [255:0]       ecdh_sk;                // To MK_T of mk_core.v
   wire                ecdh_sk_update;         // To MK_T of mk_core.v
   wire   [255:0]      psk;                    // From MK_T of mk_core.v
   // End of automatics
   wire         rst_n;
   wire         ss_expire;

   assign ss_expire  = 1'b0;
   assign rst_n      = reset_n;


   bridge BR (/*AUTOINST*/
              // Outputs
              .l3_rd                    (l3_rd[31:0]),
              .l3_rd_vld                (l3_rd_vld),
              .l3_wd_rdy                (l3_wd_rdy),
              .resp                     (resp[7:0]),
              .resp_vld                 (resp_vld),
              .mk_sel                   (mk_sel),
              .ecc_sel                  (ecc_sel),
              .aria_sel                 (aria_sel),
              .ssk_sel                  (ssk_sel),
              .hash_sel                 (hash_sel),
              // Inputs
              .l3_sel                   (l3_sel[3:0]),
              .mk_resp_vld              (mk_resp_vld),
              .mk_rd                    (mk_rd[31:0]),
              .mk_rd_vld                (mk_rd_vld),
              .mk_resp                  (mk_resp[7:0]),
              .mk_wd_rdy                (mk_wd_rdy),
              .ecc_resp_vld             (ecc_resp_vld),
              .ecc_rd                   (ecc_rd[31:0]),
              .ecc_rd_vld               (ecc_rd_vld),
              .ecc_resp                 (ecc_resp[7:0]),
              .ecc_wd_rdy               (ecc_wd_rdy),
              .aria_resp_vld            (aria_resp_vld),
              .aria_rd                  (aria_rd[31:0]),
              .aria_rd_vld              (aria_rd_vld),
              .aria_resp                (aria_resp[7:0]),
              .aria_wd_rdy              (aria_wd_rdy),
              .ssk_resp_vld             (ssk_resp_vld),
              .ssk_rd                   (ssk_rd[31:0]),
              .ssk_rd_vld               (ssk_rd_vld),
              .ssk_resp                 (ssk_resp[7:0]),
              .ssk_wd_rdy               (ssk_wd_rdy),
              .hash_resp_vld            (hash_resp_vld),
              .hash_rd                  (hash_rd[31:0]),
              .hash_rd_vld              (hash_rd_vld),
              .hash_resp                (hash_resp[7:0]),
              .hash_wd_rdy              (hash_wd_rdy));


   l2      L2_T (
                 .pin_l2_loop           (pin_loopback),
                 .pin_l2_clr            (pin_crypto_clear),
                 .pin_timer_disable     (pin_disable_timeout), // Need to Check Final
                 /*AUTOINST*/
                 // Outputs
                 .l3_en                 (l3_en),
                 .l3_extend             (l3_extend[15:0]),
                 .l3_id                 (l3_id[3:0]),
                 .l3_op                 (l3_op[7:0]),
                 .l3_rd_rdy             (l3_rd_rdy),
                 .l3_sel                (l3_sel[3:0]),
                 .l3_size               (l3_size[15:0]),
                 .l3_wd                 (l3_wd[31:0]),
                 .l3_wd_vld             (l3_wd_vld),
                 .m_ahb_haddr           (m_ahb_haddr[31:0]),
                 .m_ahb_hburst          (m_ahb_hburst[2:0]),
                 .m_ahb_hsize           (m_ahb_hsize[2:0]),
                 .m_ahb_htrans          (m_ahb_htrans[1:0]),
                 .m_ahb_hwdata          (m_ahb_hwdata[31:0]),
                 .m_ahb_hwrite          (m_ahb_hwrite),
                 .resp_rdy              (resp_rdy),
                 .s_ahb_hrdata          (s_ahb_hrdata[31:0]),
                 .s_ahb_hready          (s_ahb_hready),
                 .s_ahb_hresp           (s_ahb_hresp[1:0]),
                 // Inputs
                 .clk                   (clk),
                 .l3_rd                 (l3_rd[31:0]),
                 .l3_rd_vld             (l3_rd_vld),
                 .l3_wd_rdy             (l3_wd_rdy),
                 .m_ahb_hrdata          (m_ahb_hrdata[31:0]),
                 .m_ahb_hready          (m_ahb_hready),
                 .m_ahb_hresp           (m_ahb_hresp[1:0]),
                 .resp                  (resp[7:0]),
                 .resp_vld              (resp_vld),
                 .rst_n                 (rst_n),
                 .s_ahb_haddr           (s_ahb_haddr[31:0]),
                 .s_ahb_hburst          (s_ahb_hburst[2:0]),
                 .s_ahb_hsize           (s_ahb_hsize[2:0]),
                 .s_ahb_htrans          (s_ahb_htrans[1:0]),
                 .s_ahb_hwdata          (s_ahb_hwdata[31:0]),
                 .s_ahb_hwrite          (s_ahb_hwrite));
   mk_core MK_T (
                 .clr_mk                (pin_crypto_clear),
                 /*AUTOINST*/
                 // Outputs
                 .id_err                (id_err),
                 .mk_rd                 (mk_rd[31:0]),
                 .mk_rd_vld             (mk_rd_vld),
                 .mk_resp               (mk_resp[7:0]),
                 .mk_resp_vld           (mk_resp_vld),
                 .mk_wd_rdy             (mk_wd_rdy),
                 .k                     (k[255:0]),
                 .psk                   (psk[255:0]),
                 // Inputs
                 .clk                   (clk),
                 .mk_sel                (mk_sel),
                 .ecdh_sk               (ecdh_sk[255:0]),
                 .ecdh_sk_update        (ecdh_sk_update),
                 .l3_op                 (l3_op[7:0]),
                 .l3_en                 (l3_en),
                 .l3_extend             (l3_extend[15:0]),
                 .l3_id                 (l3_id[3:0]),
                 .l3_rd_rdy             (l3_rd_rdy),
                 .l3_size               (l3_size[15:0]),
                 .l3_wd                 (l3_wd[31:0]),
                 .l3_wd_vld             (l3_wd_vld),
                 .resp_rdy              (resp_rdy),
                 .rst_n                 (rst_n));

   ecc_core    EC (
                   .cert_msg            (mac[383:128]),
                   .clr_ecc             (pin_crypto_clear),
                   /*AUTOINST*/
                   // Outputs
                   .ecdh_sk             (ecdh_sk[255:0]),
                   .ecc_rd              (ecc_rd[31:0]),
                   .ecc_rd_vld          (ecc_rd_vld),
                   .ecc_resp            (ecc_resp[7:0]),
                   .ecc_resp_vld        (ecc_resp_vld),
                   .ecc_wd_rdy          (ecc_wd_rdy),
                   .ecdh_sk_update      (ecdh_sk_update),
                   // Inputs
                   .clk                 (clk),
                   .ecc_sel             (ecc_sel),
                   .id_err              (id_err),
                   .k                   (k[255:0]),
                   .l3_en               (l3_en),
                   .l3_extend           (l3_extend[15:0]),
                   .l3_op               (l3_op[7:0]),
                   .l3_rd_rdy           (l3_rd_rdy),
                   .l3_size             (l3_size[15:0]),
                   .l3_wd               (l3_wd[31:0]),
                   .l3_wd_vld           (l3_wd_vld),
                   .resp_rdy            (resp_rdy),
                   .rst_n               (rst_n),
                   .ss_expire           (ss_expire));
   hash_core   HC (
                   .clr_hash            (pin_crypto_clear),
                   /*AUTOINST*/
                   // Outputs
                   .mac                 (mac[383:0]),
                   .hash_rd             (hash_rd[31:0]),
                   .hash_rd_vld         (hash_rd_vld),
                   .hash_resp           (hash_resp[7:0]),
                   .hash_resp_vld       (hash_resp_vld),
                   .hash_wd_rdy         (hash_wd_rdy),
                   .ssk_addr            (ssk_addr[3:0]),
                   .ssk_wr              (ssk_wr),
                   // Inputs
                   .bc_d                (bc_d[31:0]),
                   .bc_en               (bc_en),
                   .clk                 (clk),
                   .hash_sel            (hash_sel),
                   .cw_mac_k            (cw_mac_k[383:0]),
                   .id_err              (id_err),
                   .l3_en               (l3_en),
                   .l3_extend           (l3_extend[15:0]),
                   .l3_op               (l3_op[7:0]),
                   .l3_rd_rdy           (l3_rd_rdy),
                   .l3_size             (l3_size[15:0]),
                   .l3_wd               (l3_wd[31:0]),
                   .l3_wd_vld           (l3_wd_vld),
                   .psk                 (psk[255:0]),
                   .resp_rdy            (resp_rdy),
                   .rst_n               (rst_n),
                   .ss_expire           (ss_expire),
                   .sw_mac_k            (sw_mac_k[383:0]));
   ssk_core    SK (
                   .clr_ssk             (pin_crypto_clear),
                   /*AUTOINST*/
                   // Outputs
                   .ssk_rd              (ssk_rd[31:0]),
                   .ssk_rd_vld          (ssk_rd_vld),
                   .ssk_resp            (ssk_resp[7:0]),
                   .ssk_resp_vld        (ssk_resp_vld),
                   .ssk_wd_rdy          (ssk_wd_rdy),
                   .cw_blk_k            (cw_blk_k[255:0]),
                   .cw_iv               (cw_iv[127:0]),
                   .cw_mac_k            (cw_mac_k[383:0]),
                   .sw_blk_k            (sw_blk_k[255:0]),
                   .sw_iv               (sw_iv[127:0]),
                   .sw_mac_k            (sw_mac_k[383:0]),
                   // Inputs
                   .clk                 (clk),
                   .ssk_sel             (ssk_sel),
                   .id_err              (id_err),
                   .l3_en               (l3_en),
                   .l3_extend           (l3_extend[15:0]),
                   .l3_op               (l3_op[7:0]),
                   .l3_rd_rdy           (l3_rd_rdy),
                   .l3_size             (l3_size[15:0]),
                   .l3_wd               (l3_wd[31:0]),
                   .l3_wd_vld           (l3_wd_vld),
                   .mac                 (mac[383:0]),
                   .resp_rdy            (resp_rdy),
                   .rst_n               (rst_n),
                   .ss_expire           (ss_expire),
                   .ssk_addr            (ssk_addr[3:0]),
                   .ssk_wr              (ssk_wr));
   aria_core   AR (
                   .clr_aria            (pin_crypto_clear),
                   /*AUTOINST*/
                   // Outputs
                   .bc_d                (bc_d[31:0]),
                   .bc_en               (bc_en),
                   .aria_rd             (aria_rd[31:0]),
                   .aria_rd_vld         (aria_rd_vld),
                   .aria_resp           (aria_resp[7:0]),
                   .aria_resp_vld       (aria_resp_vld),
                   .aria_wd_rdy         (aria_wd_rdy),
                   // Inputs
                   .clk                 (clk),
                   .aria_sel            (aria_sel),
                   .cw_blk_k            (cw_blk_k[255:0]),
                   .cw_iv               (cw_iv[127:0]),
                   .id_err              (id_err),
                   .l3_en               (l3_en),
                   .l3_extend           (l3_extend[15:0]),
                   .l3_op               (l3_op[7:0]),
                   .l3_rd_rdy           (l3_rd_rdy),
                   .l3_size             (l3_size[15:0]),
                   .l3_wd               (l3_wd[31:0]),
                   .l3_wd_vld           (l3_wd_vld),
                   .resp_rdy            (resp_rdy),
                   .rst_n               (rst_n),
                   .sw_blk_k            (sw_blk_k[255:0]),
                   .sw_iv               (sw_iv[127:0]));


endmodule // crypto_core
