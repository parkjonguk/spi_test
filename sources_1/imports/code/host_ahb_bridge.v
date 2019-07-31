`include "define.v"
`include "timescale.v"

module host_ahb_bridge(
	reset_n,
	clk,

`ifdef HOST_IRQ_SUPPORT
	host_irq_en,
	host_irq_clr,
	host_irq,
`endif

	m_ahb_htrans,
	m_ahb_hwrite,
	m_ahb_hsize,
	m_ahb_hburst,
	m_ahb_haddr,
	m_ahb_hwdata,
	m_ahb_hrdata,
	m_ahb_hready,
	m_ahb_hresp,

	s_ahb_htrans,
	s_ahb_hwrite,
	s_ahb_hsize,
	s_ahb_hburst,
	s_ahb_haddr,
	s_ahb_hwdata,
	s_ahb_hrdata,
	s_ahb_hready,
	s_ahb_hresp,

	rx_fifo_rd_en,
	rx_fifo_din,
	rx_fifo_empty,

	tx_fifo_rd_en,
	tx_fifo_dout,
	tx_fifo_empty
);

input			reset_n;
input			clk;

`ifdef HOST_IRQ_SUPPORT
input			host_irq_en;
input			host_irq_clr;
output			host_irq;
`endif

output	[1:0]	m_ahb_htrans;
output			m_ahb_hwrite;
output	[2:0]	m_ahb_hsize;
output	[2:0]	m_ahb_hburst;
output	[31:0]	m_ahb_haddr;
output	[31:0]	m_ahb_hwdata;
input	[31:0]	m_ahb_hrdata;
input			m_ahb_hready;
`ifdef AHB_LITE
input			m_ahb_hresp;
`else
input	[1:0]	m_ahb_hresp;
`endif

input	[1:0]	s_ahb_htrans;
input			s_ahb_hwrite;
input	[2:0]	s_ahb_hsize;
input	[2:0]	s_ahb_hburst;
input	[31:0]	s_ahb_haddr;
input	[31:0]	s_ahb_hwdata;
output	[31:0]	s_ahb_hrdata;
output			s_ahb_hready;
`ifdef AHB_LITE
output			s_ahb_hresp;
`else
output	[1:0]	s_ahb_hresp;
`endif

output			rx_fifo_rd_en;
input	[7:0]	rx_fifo_din;
input			rx_fifo_empty;

input			tx_fifo_rd_en;
output	[7:0]	tx_fifo_dout;
output			tx_fifo_empty;

host_ahb_master u_host_ahb_master(
	.reset_n(reset_n),
	.clk(clk),

`ifdef HOST_IRQ_SUPPORT
	.host_irq_en(host_irq_en),
	.host_irq_clr(host_irq_clr),
	.host_irq(host_irq),
`endif

	.m_ahb_htrans(m_ahb_htrans),
	.m_ahb_hsize(m_ahb_hsize),
	.m_ahb_hburst(m_ahb_hburst),
	.m_ahb_hwrite(m_ahb_hwrite),
	.m_ahb_haddr(m_ahb_haddr),
	.m_ahb_hwdata(m_ahb_hwdata),
	.m_ahb_hrdata(m_ahb_hrdata),
	.m_ahb_hready(m_ahb_hready),
	.m_ahb_hresp(m_ahb_hresp),

	.rx_fifo_rd_en(rx_fifo_rd_en),
	.rx_fifo_din(rx_fifo_din),
	.rx_fifo_empty(rx_fifo_empty)
);

host_ahb_slave u_host_ahb_slave(
	.reset_n(reset_n),
	.clk(clk),

	.s_ahb_htrans(s_ahb_htrans),
	.s_ahb_hsize(s_ahb_hsize),
	.s_ahb_hburst(s_ahb_hburst),
	.s_ahb_hwrite(s_ahb_hwrite),
	.s_ahb_haddr(s_ahb_haddr),
	.s_ahb_hwdata(s_ahb_hwdata),
	.s_ahb_hrdata(s_ahb_hrdata),
	.s_ahb_hready(s_ahb_hready),
	.s_ahb_hresp(s_ahb_hresp),

	.tx_fifo_rd_en(tx_fifo_rd_en),
	.tx_fifo_dout(tx_fifo_dout),
	.tx_fifo_empty(tx_fifo_empty)
);

endmodule
