module ssk_core (/*AUTOARG*/
   // Outputs
   ssk_rd, ssk_rd_vld, ssk_resp, ssk_resp_vld, ssk_wd_rdy, cw_blk_k, cw_iv,
   cw_mac_k, sw_blk_k, sw_iv, sw_mac_k,
   // Inputs
   clk, clr_ssk, ssk_sel, id_err, l3_en, l3_extend, l3_op, l3_rd_rdy, l3_size,
   l3_wd, l3_wd_vld, mac, resp_rdy, rst_n, ss_expire, ssk_addr, ssk_wr
   ) ;
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                clk;                    // To HD of l3.v, ...
   input                clr_ssk;                // To CU of ssk_core_cu.v, ...
   input                ssk_sel;               // To HD of l3.v
   input                id_err;                 // To HD of l3.v
   input                l3_en;                  // To HD of l3.v
   input [15:0]         l3_extend;              // To HD of l3.v
   input [7:0]          l3_op;                  // To HD of l3.v
   input                l3_rd_rdy;              // To HD of l3.v
   input [15:0]         l3_size;                // To HD of l3.v
   input [31:0]         l3_wd;                  // To HD of l3.v
   input                l3_wd_vld;              // To HD of l3.v
   input [383:0]        mac;                    // To MEM of ssk_mem.v
   input                resp_rdy;               // To HD of l3.v
   input                rst_n;                  // To HD of l3.v, ...
   input                ss_expire;              // To CU of ssk_core_cu.v, ...
   input [3:0]          ssk_addr;               // To MEM of ssk_mem.v
   input                ssk_wr;                 // To MEM of ssk_mem.v
   // End of automatics
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [31:0]        ssk_rd;                // From HD of l3.v
   output               ssk_rd_vld;            // From HD of l3.v
   output [7:0]         ssk_resp;              // From HD of l3.v
   output               ssk_resp_vld;          // From HD of l3.v
   output               ssk_wd_rdy;            // From HD of l3.v
   output [255:0]       cw_blk_k;               // From MEM of ssk_mem.v
   output [127:0]       cw_iv;                  // From MEM of ssk_mem.v
   output [383:0]       cw_mac_k;               // From MEM of ssk_mem.v
   output [255:0]       sw_blk_k;               // From MEM of ssk_mem.v
   output [127:0]       sw_iv;                  // From MEM of ssk_mem.v
   output [383:0]       sw_mac_k;               // From MEM of ssk_mem.v
   // End of automatics
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 cmd_en;                 // From HD of l3.v
   wire [15:0]          cmd_extend;             // From HD of l3.v
   wire [7:0]           cmd_op;                 // From HD of l3.v
   wire                 cmd_rdy;                // From CU of ssk_core_cu.v
   wire [13:0]          rd_addr;                // From HD of l3.v
   wire [31:0]          rd_d;                   // From MEM of ssk_mem.v
   wire                 rd_open;                // From CU of ssk_core_cu.v
   wire                 resp_done;              // From CU of ssk_core_cu.v
   wire [1:0]           resp_err;               // From CU of ssk_core_cu.v
   wire [13:0]          wr_addr;                // From HD of l3.v
   wire [31:0]          wr_d;                   // From HD of l3.v
   wire                 wr_en;                  // From HD of l3.v
   wire                 wr_open;                // From CU of ssk_core_cu.v
   wire [15:0]          wr_size;                // From HD of l3.v
   // End of automatics


   l3          HD  (
                    .clr_core           (clr_ssk),
                    .core_rd            (ssk_rd[31:0]),
                    .core_rd_vld        (ssk_rd_vld),
                    .core_resp          (ssk_resp[7:0]),
                    .core_resp_vld      (ssk_resp_vld),
                    .core_wd_rdy        (ssk_wd_rdy),
                    .core_sel           (ssk_sel),
                    .rd_en              (),
                    .resp_res           (4'd0),
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
   ssk_core_cu CU  (/*AUTOINST*/
                    // Outputs
                    .cmd_rdy            (cmd_rdy),
                    .wr_open            (wr_open),
                    .rd_open            (rd_open),
                    .resp_done          (resp_done),
                    .resp_err           (resp_err[1:0]),
                    // Inputs
                    .clk                (clk),
                    .rst_n              (rst_n),
                    .clr_ssk            (clr_ssk),
                    .ss_expire          (ss_expire),
                    .cmd_en             (cmd_en),
                    .cmd_op             (cmd_op[7:0]),
                    .cmd_extend         (cmd_extend[15:0]),
                    .wr_size            (wr_size[15:0]),
                    .wr_en              (wr_en));
   ssk_mem     MEM (/*AUTOINST*/
                    // Outputs
                    .rd_d               (rd_d[31:0]),
                    .cw_mac_k           (cw_mac_k[383:0]),
                    .sw_mac_k           (sw_mac_k[383:0]),
                    .cw_blk_k           (cw_blk_k[255:0]),
                    .sw_blk_k           (sw_blk_k[255:0]),
                    .cw_iv              (cw_iv[127:0]),
                    .sw_iv              (sw_iv[127:0]),
                    // Inputs
                    .clk                (clk),
                    .rst_n              (rst_n),
                    .clr_ssk            (clr_ssk),
                    .ss_expire          (ss_expire),
                    .wr_en              (wr_en),
                    .wr_d               (wr_d[31:0]),
                    .cmd_op             (cmd_op[2:0]),
                    .wr_addr            (wr_addr[3:0]),
                    .rd_addr            (rd_addr[3:0]),
                    .ssk_wr             (ssk_wr),
                    .ssk_addr           (ssk_addr[3:0]),
                    .mac                (mac[383:0]));


endmodule // ssk_core
