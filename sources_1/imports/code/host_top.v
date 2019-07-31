`include "timescale.v"
`include "define.v"

module host_top (
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
	loop,
`endif
	// 8-bit FIFO
	rx_fifo_rd_en,
	rx_fifo_dout,
	rx_fifo_empty,

	tx_fifo_rd_en,
	tx_fifo_din,
	tx_fifo_empty,
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
	oe_n_oe
);

input			reset_n;
input			clk;				// SYS_CLK

// I2C
input			scl;
input			sda_in;
output			sda_out;
output			sda_oe;
input			i2c_addr;

// Default Host I/F Mode
`ifdef FPGA
input	[2:0]	def_mode;
output	[1:0]	host_mode;
output			loop;
`else
input	[1:0]	def_mode;
`endif

// 8-bit FIFO
input			rx_fifo_rd_en;
output	[7:0]	rx_fifo_dout;
output			rx_fifo_empty;

output			tx_fifo_rd_en;
input	[7:0]	tx_fifo_din;
input			tx_fifo_empty;
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

wire	[1:0]	host_mode;

`ifdef FPGA
wire			loop;
`endif

wire			inactive_io;
wire			unused_io;
wire			miso_edge;
wire	[3:0]	stop_bit;
wire			flow_control;
wire	[31:0]	baud_nco;

wire	[7:0]	sfifo_data_out;
wire	[7:0]	sfifo_data_in;
wire			sfifo_data_oe;

wire			rxf_n;
wire			txe_n;
wire			wr_n;
wire			oe_n;

wire			ss_n;
wire			sck;
wire			mosi;
wire			miso;

wire			txd;
wire			rxd;
wire			rts;
wire			cts;

// FIFO MUX
wire			rx_fifo_rd_en;
wire	[7:0]	rx_fifo_dout;
wire			rx_fifo_empty;
wire			tx_fifo_rd_en;
wire	[7:0]	tx_fifo_din;
wire			tx_fifo_empty;

// SFIFO
wire			sfifo_rx_fifo_rd_en;
wire	[7:0]	sfifo_rx_fifo_dout;
wire			sfifo_rx_fifo_empty;
wire			sfifo_tx_fifo_rd_en;
wire	[7:0]	sfifo_tx_fifo_din;
wire			sfifo_tx_fifo_empty;

// SPI
wire			spi_rx_fifo_rd_en;
wire	[7:0]	spi_rx_fifo_dout;
wire			spi_rx_fifo_empty;
wire			spi_tx_fifo_rd_en;
wire	[7:0]	spi_tx_fifo_din;
wire			spi_tx_fifo_empty;

// UART
wire			uart_rx_fifo_rd_en;
wire	[7:0]	uart_rx_fifo_dout;
wire			uart_rx_fifo_empty;
wire			uart_tx_fifo_rd_en;
wire	[7:0]	uart_tx_fifo_din;
wire			uart_tx_fifo_empty;


genvar i;

host_i2c u_host_i2c(
	.reset_n(reset_n),
	.clk(clk),
	
	.scl(scl),
	.sda_in(sda_in),
	.sda_out(sda_out),
	.sda_oe(sda_oe),
	.i2c_addr(i2c_addr),

	.def_mode(def_mode),
	.host_mode(host_mode),
`ifdef FPGA
	.loop(loop),
`endif
	.inactive_io(inactive_io),
	.unused_io(unused_io),
	.miso_edge(miso_edge),
	.stop_bit(stop_bit),
	.flow_control(flow_control),
	.baud_nco(baud_nco)
);

host_io_cntrl u_host_io_cntrl(
	.host_mode(host_mode),
	.inactive_io(inactive_io),
	.unused_io(unused_io),
	.flow_control(flow_control),
	// FTDI
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
	.oe_n_oe(oe_n_oe),
	// Sync-FIFO
	.sfifo_data_out(sfifo_data_out),
	.sfifo_data_in(sfifo_data_in),
	.sfifo_data_oe(sfifo_data_oe),
	.rxf_n(rxf_n),
	.txe_n(txe_n),
	.rd_n(rd_n),
	.wr_n(wr_n),
	.oe_n(oe_n),
	// SPI
	.ss_n(ss_n),
	.sck(sck),
	.mosi(mosi),
	.miso(miso),
	// UART
	.txd(txd),
	.rxd(rxd),
	.rts(rts),
	.cts(cts)
);


`ifdef HOST_IF_SPI
host_spi u_host_spi(
	.reset_n(reset_n),
	.clk(clk),
	.host_mode(host_mode),
	
	.ss_n(ss_n),
	.sck(sck),
	.mosi(mosi),
	.miso(miso),
	.miso_edge(miso_edge),

	.rx_fifo_rd_en(spi_rx_fifo_rd_en),
	.rx_fifo_dout(spi_rx_fifo_dout),
	.rx_fifo_empty(spi_rx_fifo_empty),

	.tx_fifo_rd_en(spi_tx_fifo_rd_en),
	.tx_fifo_din(spi_tx_fifo_din),
	.tx_fifo_empty(spi_tx_fifo_empty)
);
`else
assign miso = 0;
assign spi_rx_fifo_dout = 0;
assign spi_rx_fifo_empty = 1'b1;
assign spi_tx_fifo_empty = 1'b1;
`endif


`ifdef HOST_IF_SFIFO
host_sync_fifo u_host_sync_fifo(
	.reset_n(reset_n),
	.clk(clk),
	.host_mode(host_mode),

	.ft_clk(ft_clk),
	.data_out(sfifo_data_out),
	.data_in(sfifo_data_in),
	.data_oe(sfifo_data_oe),
	.rxf_n(rxf_n),
	.txe_n(txe_n),
	.rd_n(rd_n),
	.wr_n(wr_n),
	.oe_n(oe_n),

	.rx_fifo_rd_en(sfifo_rx_fifo_rd_en),
	.rx_fifo_dout(sfifo_rx_fifo_dout),
	.rx_fifo_empty(sfifo_rx_fifo_empty),

	.tx_fifo_rd_en(sfifo_tx_fifo_rd_en),
	.tx_fifo_din(sfifo_tx_fifo_din),
	.tx_fifo_empty(sfifo_tx_fifo_empty)
);
`else
assign sfifo_data_out = 0;
assign sfifo_data_oe = 0;
assign rd_n = 1;
assign wr_n = 1;
assign oe_n = 1;
assign sfifo_rx_fifo_dout = 0;
assign sfifo_rx_fifo_empty = 1;
assign sfifo_tx_fifo_empty = 1;
`endif


`ifdef HOST_IF_UART
host_uart u_host_uart(
	.reset_n(reset_n),
	.clk(clk),
	.baud_nco(baud_nco),
	.stop_bit(stop_bit),
	.flow_control(flow_control),
	.txd(txd),
	.rxd(rxd),
	.rts(rts),
	.cts(cts),
	
	.rx_fifo_rd_en(uart_rx_fifo_rd_en),
	.rx_fifo_dout(uart_rx_fifo_dout),
	.rx_fifo_empty(uart_rx_fifo_empty),

	.tx_fifo_rd_en(uart_tx_fifo_rd_en),
	.tx_fifo_din(uart_tx_fifo_din),
	.tx_fifo_empty(uart_tx_fifo_empty)
);
`else
assign txd = 1;
assign rts = 1;
assign uart_rx_fifo_dout = 0;
assign uart_rx_fifo_empty = 1;
assign uart_tx_fifo_empty = 1;
`endif


host_fifo_mux u_host_fifo_mux(
	.host_mode(host_mode),
	
	.sfifo_rx_fifo_rd_en(sfifo_rx_fifo_rd_en),
	.sfifo_rx_fifo_dout(sfifo_rx_fifo_dout),
	.sfifo_rx_fifo_empty(sfifo_rx_fifo_empty),
	.sfifo_tx_fifo_rd_en(sfifo_tx_fifo_rd_en),
	.sfifo_tx_fifo_din(sfifo_tx_fifo_din),
	.sfifo_tx_fifo_empty(sfifo_tx_fifo_empty),
	
	.spi_rx_fifo_rd_en(spi_rx_fifo_rd_en),
	.spi_rx_fifo_dout(spi_rx_fifo_dout),
	.spi_rx_fifo_empty(spi_rx_fifo_empty),
	.spi_tx_fifo_rd_en(spi_tx_fifo_rd_en),
	.spi_tx_fifo_din(spi_tx_fifo_din),
	.spi_tx_fifo_empty(spi_tx_fifo_empty),

	.uart_rx_fifo_rd_en(uart_rx_fifo_rd_en),
	.uart_rx_fifo_dout(uart_rx_fifo_dout),
	.uart_rx_fifo_empty(uart_rx_fifo_empty),
	.uart_tx_fifo_rd_en(uart_tx_fifo_rd_en),
	.uart_tx_fifo_din(uart_tx_fifo_din),
	.uart_tx_fifo_empty(uart_tx_fifo_empty),
	
	.rx_fifo_rd_en(rx_fifo_rd_en),
	.rx_fifo_dout(rx_fifo_dout),
	.rx_fifo_empty(rx_fifo_empty),
	
	.tx_fifo_rd_en(tx_fifo_rd_en),
	.tx_fifo_din(tx_fifo_din),
	.tx_fifo_empty(tx_fifo_empty)
);

`ifdef MODELSIM
	`undef USE_CHIPSCOPE
`endif

`ifdef USE_CHIPSCOPE

vio_0 u_vio_0(
	.clk(clk),
	.probe_in0(host_mode),
	.probe_in1(loop),
	.probe_in2(inactive_io),
	.probe_in3(unused_io),
	.probe_in4(miso_edge),
	.probe_in5(stop_bit),
	.probe_in6(flow_control),
	.probe_in7(baud_nco)
);

`endif

endmodule
