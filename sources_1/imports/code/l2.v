module l2 (/*AUTOARG*/
   // Outputs
   l3_en, l3_extend, l3_id, l3_op, l3_rd_rdy, l3_sel, l3_size, l3_wd, l3_wd_vld,
   m_ahb_haddr, m_ahb_hburst, m_ahb_hsize, m_ahb_htrans, m_ahb_hwdata,
   m_ahb_hwrite, resp_rdy, s_ahb_hrdata, s_ahb_hready, s_ahb_hresp,
   // Inputs
   clk, l3_rd, l3_rd_vld, l3_wd_rdy, m_ahb_hrdata, m_ahb_hready, m_ahb_hresp,
   pin_l2_clr, pin_l2_loop, pin_timer_disable, resp, resp_vld, rst_n,
   s_ahb_haddr, s_ahb_hburst, s_ahb_hsize, s_ahb_htrans, s_ahb_hwdata,
   s_ahb_hwrite
   ) ;
   output               l3_en;                  // From RX of l2_rx.v
   output [15:0]        l3_extend;              // From RX of l2_rx.v
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                clk;                    // To AHB of l2_ahb.v, ...
   input [31:0]         l3_rd;                  // To TX of l2_tx.v
   input                l3_rd_vld;              // To TX of l2_tx.v
   input                l3_wd_rdy;              // To RX of l2_rx.v
   input [31:0]         m_ahb_hrdata;           // To AHB of l2_ahb.v
   input                m_ahb_hready;           // To AHB of l2_ahb.v
   input [1:0]          m_ahb_hresp;            // To AHB of l2_ahb.v
   input                pin_l2_clr;             // To AHB of l2_ahb.v, ...
   input                pin_l2_loop;            // To LP of l2_loop.v
   input                pin_timer_disable;      // To TM of l2_timer.v
   input [7:0]          resp;                   // To RSP of l2_resp.v
   input                resp_vld;               // To RSP of l2_resp.v
   input                rst_n;                  // To AHB of l2_ahb.v, ...
   input [31:0]         s_ahb_haddr;            // To AHB of l2_ahb.v
   input [2:0]          s_ahb_hburst;           // To AHB of l2_ahb.v
   input [2:0]          s_ahb_hsize;            // To AHB of l2_ahb.v
   input [1:0]          s_ahb_htrans;           // To AHB of l2_ahb.v
   input [31:0]         s_ahb_hwdata;           // To AHB of l2_ahb.v
   input                s_ahb_hwrite;           // To AHB of l2_ahb.v
   // End of automatics
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [3:0]         l3_id;                  // From RX of l2_rx.v
   output [7:0]         l3_op;                  // From RX of l2_rx.v
   output               l3_rd_rdy;              // From TX of l2_tx.v
   output [3:0]         l3_sel;                 // From RX of l2_rx.v
   output [15:0]        l3_size;                // From RX of l2_rx.v
   output [31:0]        l3_wd;                  // From RX of l2_rx.v
   output               l3_wd_vld;              // From RX of l2_rx.v
   output [31:0]        m_ahb_haddr;            // From AHB of l2_ahb.v
   output [2:0]         m_ahb_hburst;           // From AHB of l2_ahb.v
   output [2:0]         m_ahb_hsize;            // From AHB of l2_ahb.v
   output [1:0]         m_ahb_htrans;           // From AHB of l2_ahb.v
   output [31:0]        m_ahb_hwdata;           // From AHB of l2_ahb.v
   output               m_ahb_hwrite;           // From AHB of l2_ahb.v
   output               resp_rdy;               // From RSP of l2_resp.v
   output [31:0]        s_ahb_hrdata;           // From AHB of l2_ahb.v
   output               s_ahb_hready;           // From AHB of l2_ahb.v
   output [1:0]         s_ahb_hresp;            // From AHB of l2_ahb.v
   // End of automatics
   wire   [31:0]        rx_fifo_din;            // From AHB of l2_ahb.v
   wire                 rx_fifo_rd;             // From RX of l2_rx.v
   wire                 rx_fifo_rd_en_dbg;      // From LP of l2_loop.v
   wire                 tx_fifo_wr;             // From TX of l2_tx.v
   wire                 tx_fifo_rd_en_ahb;      // To LP of l2_loop.v
   wire                 tx_fifo_wr_en;          // To RXF of l2_fifo.v
   wire   [31:0]        tx_fifo_dout_ahb;       // From LP of l2_loop.v
   wire                 tx_fifo_empty_ahb;      // From LP of l2_loop.v
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 err_timeout;            // From TM of l2_timer.v
   wire                 l3_cmd_done;            // From TX of l2_tx.v
   wire                 resp_done;              // From RSP of l2_resp.v
   wire                 resp_err;               // From RSP of l2_resp.v
   wire [31:0]          rx_fifo_dout;           // From TXF of l2_fifo.v
   wire                 rx_fifo_empty;          // From TXF of l2_fifo.v
   wire                 rx_fifo_full;           // From TXF of l2_fifo.v
   wire                 rx_fifo_wr_en;          // From AHB of l2_ahb.v
   wire [7:0]           sw0;                    // From RSP of l2_resp.v
   wire [7:0]           sw1;                    // From RSP of l2_resp.v
   wire                 timer_stop;             // From TX of l2_tx.v
   wire [31:0]          tx_fifo_din;            // From TX of l2_tx.v
   wire [31:0]          tx_fifo_dout;           // From RXF of l2_fifo.v
   wire                 tx_fifo_empty;          // From RXF of l2_fifo.v
   wire                 tx_fifo_full;           // From RXF of l2_fifo.v
   wire                 tx_fifo_rd_en;          // From LP of l2_loop.v
   // End of automatics
   /*AUTOREG*/

   l2_ahb   AHB (
                 .tx_fifo_rd_en         (tx_fifo_rd_en_ahb),
                 .tx_fifo_empty         (tx_fifo_empty_ahb),
                 .tx_fifo_dout          (tx_fifo_dout_ahb[31:0]),
                 /*AUTOINST*/
                 // Outputs
                 .m_ahb_htrans          (m_ahb_htrans[1:0]),
                 .m_ahb_hsize           (m_ahb_hsize[2:0]),
                 .m_ahb_hburst          (m_ahb_hburst[2:0]),
                 .m_ahb_hwrite          (m_ahb_hwrite),
                 .m_ahb_haddr           (m_ahb_haddr[31:0]),
                 .m_ahb_hwdata          (m_ahb_hwdata[31:0]),
                 .s_ahb_hrdata          (s_ahb_hrdata[31:0]),
                 .s_ahb_hready          (s_ahb_hready),
                 .s_ahb_hresp           (s_ahb_hresp[1:0]),
                 .rx_fifo_wr_en         (rx_fifo_wr_en),
                 .rx_fifo_din           (rx_fifo_din[31:0]),
                 // Inputs
                 .rst_n                 (rst_n),
                 .clk                   (clk),
                 .pin_l2_clr            (pin_l2_clr),
                 .m_ahb_hrdata          (m_ahb_hrdata[31:0]),
                 .m_ahb_hready          (m_ahb_hready),
                 .m_ahb_hresp           (m_ahb_hresp[1:0]),
                 .s_ahb_htrans          (s_ahb_htrans[1:0]),
                 .s_ahb_hsize           (s_ahb_hsize[2:0]),
                 .s_ahb_hburst          (s_ahb_hburst[2:0]),
                 .s_ahb_hwrite          (s_ahb_hwrite),
                 .s_ahb_haddr           (s_ahb_haddr[31:0]),
                 .s_ahb_hwdata          (s_ahb_hwdata[31:0]),
                 .rx_fifo_full          (rx_fifo_full));
   l2_fifo  TXF (
                 // Outputs
                 .empty                 (tx_fifo_empty),
                 .full                  (tx_fifo_full),
                 .dout                  (tx_fifo_dout[31:0]),
                 // Inputs
                 .pin_l2_clr            (pin_l2_clr),
                 .wr                    (tx_fifo_wr_en),
                 .rd                    (tx_fifo_rd_en),
                 .din                   (tx_fifo_din[31:0]),
                 /*AUTOINST*/
                 // Inputs
                 .clk                   (clk),
                 .rst_n                 (rst_n));

   l2_fifo  RXF (
                 // Outputs
                 .empty                 (rx_fifo_empty),
                 .full                  (rx_fifo_full),
                 .dout                  (rx_fifo_dout[31:0]),
                 // Inputs
                 .pin_l2_clr            (pin_l2_clr),
                 .wr                    (rx_fifo_wr_en),
                 .rd                    (rx_fifo_rd_en | rx_fifo_rd_en_dbg),
                 .din                   (rx_fifo_din[31:0]),
                 /*AUTOINST*/
                 // Inputs
                 .clk                   (clk),
                 .rst_n                 (rst_n));




   l2_loop  LP  (/*AUTOINST*/
                 // Outputs
                 .tx_fifo_rd_en         (tx_fifo_rd_en),
                 .rx_fifo_rd_en_dbg     (rx_fifo_rd_en_dbg),
                 .tx_fifo_empty_ahb     (tx_fifo_empty_ahb),
                 .tx_fifo_dout_ahb      (tx_fifo_dout_ahb[31:0]),
                 // Inputs
                 .pin_l2_loop           (pin_l2_loop),
                 .tx_fifo_empty         (tx_fifo_empty),
                 .tx_fifo_dout          (tx_fifo_dout[31:0]),
                 .rx_fifo_empty         (rx_fifo_empty),
                 .rx_fifo_dout          (rx_fifo_dout[31:0]),
                 .tx_fifo_rd_en_ahb     (tx_fifo_rd_en_ahb));

   l2_resp  RSP (/*AUTOINST*/
                 // Outputs
                 .resp_err              (resp_err),
                 .resp_done             (resp_done),
                 .sw0                   (sw0[7:0]),
                 .sw1                   (sw1[7:0]),
                 .resp_rdy              (resp_rdy),
                 // Inputs
                 .clk                   (clk),
                 .rst_n                 (rst_n),
                 .pin_l2_clr            (pin_l2_clr),
                 .l3_en                 (l3_en),
                 .l3_cmd_done           (l3_cmd_done),
                 .err_timeout           (err_timeout),
                 .resp                  (resp[7:0]),
                 .resp_vld              (resp_vld));
   l2_rx    RX  (
                 .pin_l2_loop           (pin_l2_loop),
                 .rx_fifo_rd            (rx_fifo_rd_en),
                 /*AUTOINST*/
                 // Outputs
                 .l3_sel                (l3_sel[3:0]),
                 .l3_id                 (l3_id[3:0]),
                 .l3_op                 (l3_op[7:0]),
                 .l3_size               (l3_size[15:0]),
                 .l3_extend             (l3_extend[15:0]),
                 .l3_en                 (l3_en),
                 .l3_wd                 (l3_wd[31:0]),
                 .l3_wd_vld             (l3_wd_vld),
                 // Inputs
                 .clk                   (clk),
                 .rst_n                 (rst_n),
                 .pin_l2_clr            (pin_l2_clr),
                 .rx_fifo_empty         (rx_fifo_empty),
                 .rx_fifo_dout          (rx_fifo_dout[31:0]),
                 .l3_cmd_done           (l3_cmd_done),
                 .l3_wd_rdy             (l3_wd_rdy));
   l2_tx    TX  (
                 .tx_fifo_wr            (tx_fifo_wr_en),
                 /*AUTOINST*/
                 // Outputs
                 .tx_fifo_din           (tx_fifo_din[31:0]),
                 .l3_cmd_done           (l3_cmd_done),
                 .timer_stop            (timer_stop),
                 .l3_rd_rdy             (l3_rd_rdy),
                 // Inputs
                 .clk                   (clk),
                 .rst_n                 (rst_n),
                 .pin_l2_clr            (pin_l2_clr),
                 .tx_fifo_full          (tx_fifo_full),
                 .l3_en                 (l3_en),
                 .l3_extend             (l3_extend[15:0]),
                 .sw0                   (sw0[7:0]),
                 .sw1                   (sw1[7:0]),
                 .resp_err              (resp_err),
                 .resp_done             (resp_done),
                 .l3_rd                 (l3_rd[31:0]),
                 .l3_rd_vld             (l3_rd_vld));
   l2_timer TM  (/*AUTOINST*/
                 // Outputs
                 .err_timeout           (err_timeout),
                 // Inputs
                 .clk                   (clk),
                 .rst_n                 (rst_n),
                 .pin_timer_disable     (pin_timer_disable),
                 .l3_en                 (l3_en),
                 .l3_cmd_done           (l3_cmd_done),
                 .timer_stop            (timer_stop));
endmodule // l2
