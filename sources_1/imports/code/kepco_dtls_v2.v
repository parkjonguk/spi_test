`include "timescale.v"
`include "define.v"

module kepco_dtls_v2(
	reset_n,
	clk,
	// I2C
	scl,
	sda_in,
	sda_out,
	sda_oe,
	i2c_addr,
	// Default Host I/F Mode
	def_mode,
`ifdef FPGA
	host_mode,
`endif
	// FTDI
	ft_clk,
	d0_sck_rxd_out,
	d0_sck_rxd_in,
	d0_sck_rxd_oe,
	d1_mosi_txd_out,
	d1_mosi_txd_in,
	d1_mosi_txd_oe,
	d2_miso_cts_n_out,
	d2_miso_cts_n_in,
	d2_miso_cts_n_oe,
	d3_ss_n_rts_n_out,
	d3_ss_n_rts_n_in,
	d3_ss_n_rts_n_oe,
	d7_4_out,
	d7_4_in,
	d7_4_oe,
	rxf_n_out,
	rxf_n_in,
	rxf_n_oe,
	txe_n_out,
	txe_n_in,
	txe_n_oe,
	rd_n_out,
	rd_n_oe,
	wr_n_out,
	wr_n_oe,
	oe_n_out,
	oe_n_oe,
//	l3_state,
  pin_crypto_clear,
  pin_disable_timeout,
  pin_loopback
);

input			reset_n;
input			clk;				// SYS_CLK
// I2C
input			scl;
input			sda_in;
output			sda_out;
output			sda_oe;
input			i2c_addr;
//input           dbg_crypto_ahb;

input  pin_crypto_clear;
input  pin_disable_timeout;
input  pin_loopback;





// Default I/F Mode
`ifdef FPGA
input	[2:0]	def_mode;
output	[1:0]	host_mode;
`else
input	[1:0]	def_mode;
`endif

// FTDI
input			ft_clk;
output			d0_sck_rxd_out;
input			d0_sck_rxd_in;
output			d0_sck_rxd_oe;
output			d1_mosi_txd_out;
input			d1_mosi_txd_in;
output			d1_mosi_txd_oe;
output			d2_miso_cts_n_out;
input			d2_miso_cts_n_in;
output			d2_miso_cts_n_oe;
output			d3_ss_n_rts_n_out;
input			d3_ss_n_rts_n_in;
output			d3_ss_n_rts_n_oe;
output	[3:0]	d7_4_out;
input	[3:0]	d7_4_in;
output	[3:0]	d7_4_oe;
//output  [5:0]   l3_state;
output			rxf_n_out;
input			rxf_n_in;
output			rxf_n_oe;
output			txe_n_out;
input			txe_n_in;
output			txe_n_oe;
output			rd_n_out;
output			rd_n_oe;
output			wr_n_out;
output			wr_n_oe;
output			oe_n_out;
output			oe_n_oe;

wire			sda_in;
wire			sda_out;
wire			sda_oe;

wire			rx_fifo_rd_en;
wire	[7:0]	rx_fifo_dout;
wire			rx_fifo_empty;

wire			tx_fifo_rd_en;
wire	[7:0]	tx_fifo_din;
wire			tx_fifo_empty;

wire			reset_n;
wire			clk;

`ifdef FPGA
wire			loop;
`endif

host_top u_host_top(
	.reset_n(reset_n),
	.clk(clk),

	// I2C
	.scl(scl),
	.sda_in(sda_in),
	.sda_out(sda_out),
	.sda_oe(sda_oe),
	.i2c_addr(i2c_addr),

	// Default Host I/F Mode
	.def_mode(def_mode),
`ifdef FPGA
	.host_mode(host_mode),
	.loop(loop),
`endif
	// 8-bit FIFO
	.rx_fifo_rd_en(rx_fifo_rd_en),
	.rx_fifo_dout(rx_fifo_dout),
	.rx_fifo_empty(rx_fifo_empty),

	.tx_fifo_rd_en(tx_fifo_rd_en),
	.tx_fifo_din(tx_fifo_din),
	.tx_fifo_empty(tx_fifo_empty),
	// FTDI
	.ft_clk(ft_clk),
	.d0_sck_rxd_out(d0_sck_rxd_out),
	.d0_sck_rxd_in(d0_sck_rxd_in),
	.d0_sck_rxd_oe(d0_sck_rxd_oe),
	.d1_mosi_txd_out(d1_mosi_txd_out),
	.d1_mosi_txd_in(d1_mosi_txd_in),
	.d1_mosi_txd_oe(d1_mosi_txd_oe),
	.d2_miso_cts_n_out(d2_miso_cts_n_out),
	.d2_miso_cts_n_in(d2_miso_cts_n_in),
	.d2_miso_cts_n_oe(d2_miso_cts_n_oe),
	.d3_ss_n_rts_n_out(d3_ss_n_rts_n_out),
	.d3_ss_n_rts_n_in(d3_ss_n_rts_n_in),
	.d3_ss_n_rts_n_oe(d3_ss_n_rts_n_oe),
	.d7_4_out(d7_4_out),
	.d7_4_in(d7_4_in),
	.d7_4_oe(d7_4_oe),
	.rxf_n_out(rxf_n_out),
	.rxf_n_in(rxf_n_in),
	.rxf_n_oe(rxf_n_oe),
	.txe_n_out(txe_n_out),
	.txe_n_in(txe_n_in),
	.txe_n_oe(txe_n_oe),
	.rd_n_out(rd_n_out),
	.rd_n_oe(rd_n_oe),
	.wr_n_out(wr_n_out),
	.wr_n_oe(wr_n_oe),
	.oe_n_out(oe_n_out),
	.oe_n_oe(oe_n_oe)
);


`ifdef HOST_AHB_BRIDGE_SUPPORT

// master 0
wire	[1:0]	m0_htrans;
wire	[2:0]	m0_hsize;
wire	[2:0]	m0_hburst;
wire			m0_hwrite;
wire	[31:0]	m0_haddr;
wire	[31:0]	m0_hwdata;
wire	[31:0]	m0_hrdata;
wire			m0_hready;
wire	[1:0]	m0_hresp;

// master 1
wire	[1:0]	m1_htrans;
wire	[2:0]	m1_hsize;
wire	[2:0]	m1_hburst;
wire			m1_hwrite;
wire	[31:0]	m1_haddr;
wire	[31:0]	m1_hwdata;
wire	[31:0]	m1_hrdata;
wire			m1_hready;
wire	[1:0]	m1_hresp;

`ifdef CPU_8051
// master 2
wire	[1:0]	m2_htrans;
wire	[2:0]	m2_hsize;
wire	[2:0]	m2_hburst;
wire			m2_hwrite;
wire	[31:0]	m2_haddr;
wire	[31:0]	m2_hwdata;
wire	[31:0]	m2_hrdata;
wire			m2_hready;
wire	[1:0]	m2_hresp;
`endif

// slave 0
wire			s0_hsel_default;
wire			s0_hsel;
wire	[1:0]	s0_htrans;
wire	[2:0]	s0_hsize;
wire	[2:0]	s0_hburst;
wire			s0_hwrite;
wire	[31:0]	s0_haddr;
wire	[31:0]	s0_hwdata;
wire	[31:0]	s0_hrdata;
wire			s0_hready;
wire	[1:0]	s0_hresp;

// slave 1
wire			s1_hsel;
wire	[1:0]	s1_htrans;
wire	[2:0]	s1_hsize;
wire	[2:0]	s1_hburst;
wire			s1_hwrite;
wire	[31:0]	s1_haddr;
wire	[31:0]	s1_hwdata;
wire	[31:0]	s1_hrdata;
wire			s1_hready;
wire	[1:0]	s1_hresp;

`ifdef CPU_8051
// slave 2
wire			s2_hsel;
wire	[1:0]	s2_htrans;
wire	[2:0]	s2_hsize;
wire	[2:0]	s2_hburst;
wire			s2_hwrite;
wire	[31:0]	s2_haddr;
wire	[31:0]	s2_hwdata;
wire	[31:0]	s2_hrdata;
wire			s2_hready;
wire	[1:0]	s2_hresp;
`endif

`ifdef HOST_IRQ_SUPPORT
wire			host_irq_en;
wire			host_irq_clr;
wire			host_irq;

assign host_irq_en = 1;
assign host_irq_clr = 1;
`endif

ml_ahb u_ml_ahb(
	.resetn(reset_n),
	.hclk(clk),

`ifdef CPU_8051
	.mapped_to_common(2'd0),
	.s0_round_robin(1'b0),
	.m0_s0_prio(2'd0),
	.m1_s0_prio(2'd0),
	.m2_s0_prio(2'd0),
	.s1_round_robin(1'b0),
	.m0_s1_prio(2'd0),
	.m1_s1_prio(2'd0),
	.m2_s1_prio(2'd0),
	.s2_round_robin(1'b0),
	.m0_s2_prio(2'd0),
	.m1_s2_prio(2'd0),
	.m2_s2_prio(2'd0),
`else
	.mapped_to_common(1'b0),
	.s0_round_robin(1'b0),
	.m0_s0_prio(1'b0),
	.m1_s0_prio(1'b0),
	.s1_round_robin(1'b0),
	.m0_s1_prio(1'b0),
	.m1_s1_prio(1'b0),
`endif

	// master 0
	.m0_htrans	(m0_htrans),
	.m0_hsize	(m0_hsize),
	.m0_hburst	(m0_hburst),
	.m0_hwrite	(m0_hwrite),
	.m0_haddr	(m0_haddr),
	.m0_hwdata	(m0_hwdata),
	.m0_hrdata	(m0_hrdata),
	.m0_hready	(m0_hready),
	.m0_hresp	(m0_hresp),

	// master 1
	.m1_htrans	(m1_htrans),
	.m1_hsize	(m1_hsize),
	.m1_hburst	(m1_hburst),
	.m1_hwrite	(m1_hwrite),
	.m1_haddr	(m1_haddr),
	.m1_hwdata	(m1_hwdata),
	.m1_hrdata	(m1_hrdata),
	.m1_hready	(m1_hready),
	.m1_hresp	(m1_hresp),

`ifdef CPU_8051
	// master 2
	.m2_htrans	(m2_htrans),
	.m2_hsize	(m2_hsize),
	.m2_hburst	(m2_hburst),
	.m2_hwrite	(m2_hwrite),
	.m2_haddr	(m2_haddr),
	.m2_hwdata	(m2_hwdata),
	.m2_hrdata	(m2_hrdata),
	.m2_hready	(m2_hready),
	.m2_hresp	(m2_hresp),
`endif

	// slave 0
	.s0_hsel_default(s0_hsel_default),
	.s0_hsel	(s0_hsel),
	.s0_htrans	(s0_htrans),
	.s0_hsize	(s0_hsize),
	.s0_hburst	(s0_hburst),
	.s0_hwrite	(s0_hwrite),
	.s0_haddr	(s0_haddr),
	.s0_hwdata	(s0_hwdata),
	.s0_hrdata	(s0_hrdata),
	.s0_hready	(s0_hready),
	.s0_hresp	(s0_hresp),

	// slave 1
	.s1_hsel	(s1_hsel),
	.s1_htrans	(s1_htrans),
	.s1_hsize	(s1_hsize),
	.s1_hburst	(s1_hburst),
	.s1_hwrite	(s1_hwrite),
	.s1_haddr	(s1_haddr),
	.s1_hwdata	(s1_hwdata),
	.s1_hrdata	(s1_hrdata),
	.s1_hready	(s1_hready),
	.s1_hresp	(s1_hresp)

`ifdef CPU_8051
	,
	// slave 2
	.s2_hsel	(s2_hsel),
	.s2_htrans	(s2_htrans),
	.s2_hsize	(s2_hsize),
	.s2_hburst	(s2_hburst),
	.s2_hwrite	(s2_hwrite),
	.s2_haddr	(s2_haddr),
	.s2_hwdata	(s2_hwdata),
	.s2_hrdata	(s2_hrdata),
	.s2_hready	(s2_hready),
	.s2_hresp	(s2_hresp)
`endif
);

host_ahb_bridge u_host_ahb_bridge(
	.reset_n(reset_n),
	.clk(clk),

`ifdef HOST_IRQ_SUPPORT
	.host_irq_en(host_irq_en),
	.host_irq_clr(host_irq_clr),
	.host_irq(host_irq),
`endif

	.m_ahb_htrans(m0_htrans),
	.m_ahb_hsize(m0_hsize),
	.m_ahb_hburst(m0_hburst),
	.m_ahb_hwrite(m0_hwrite),
	.m_ahb_haddr(m0_haddr),
	.m_ahb_hwdata(m0_hwdata),
	.m_ahb_hrdata(m0_hrdata),
	.m_ahb_hready(m0_hready),
	.m_ahb_hresp(m0_hresp),

	.s_ahb_htrans(s0_htrans),
	.s_ahb_hsize(s0_hsize),
	.s_ahb_hburst(s0_hburst),
	.s_ahb_hwrite(s0_hwrite),
	.s_ahb_haddr(s0_haddr),
	.s_ahb_hwdata(s0_hwdata),
	.s_ahb_hrdata(s0_hrdata),
	.s_ahb_hready(s0_hready),
	.s_ahb_hresp(s0_hresp),

	.rx_fifo_rd_en(rx_fifo_rd_en),
	.rx_fifo_din(rx_fifo_dout),
	.rx_fifo_empty(rx_fifo_empty),

	.tx_fifo_rd_en(tx_fifo_rd_en),
	.tx_fifo_dout(tx_fifo_din),
	.tx_fifo_empty(tx_fifo_empty)
);

crypto_core u_crypto_core(
	.reset_n(reset_n),
	.clk(clk),
  .pin_crypto_clear    (pin_crypto_clear),
  .pin_disable_timeout (pin_disable_timeout),
  .pin_loopback        (pin_loopback),

`ifdef FPGA
	.loop(loop),
`endif

`ifdef FIFO_TEST
	.fifo_read_en(fifo_read_en),
`endif

	.m_ahb_htrans(m1_htrans),
	.m_ahb_hsize(m1_hsize),
	.m_ahb_hburst(m1_hburst),
	.m_ahb_hwrite(m1_hwrite),
	.m_ahb_haddr(m1_haddr),
	.m_ahb_hwdata(m1_hwdata),
	.m_ahb_hrdata(m1_hrdata),
	.m_ahb_hready(m1_hready),
	.m_ahb_hresp(m1_hresp),

	.s_ahb_htrans(s1_htrans),
	.s_ahb_hsize(s1_hsize),
	.s_ahb_hburst(s1_hburst),
	.s_ahb_hwrite(s1_hwrite),
	.s_ahb_haddr(s1_haddr),
	.s_ahb_hwdata(s1_hwdata),
	.s_ahb_hrdata(s1_hrdata),
	.s_ahb_hready(s1_hready),
	.s_ahb_hresp(s1_hresp)
);

`else	// HOST_AHB_BRIDGE_SUPPORT


`endif	// HOST_AHB_BRIDGE_SUPPORT


`ifdef MODELSIM
	`undef USE_CHIPSCOPE
`endif

`ifdef USE_CHIPSCOPE

`endif

endmodule
