`include "timescale.v"
`include "define.v"

module host_io_cntrl(
	host_mode,
	inactive_io,
	unused_io,
	flow_control,
	// FTDI
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
	// Sync-FIFO
	sfifo_data_out,
	sfifo_data_in,
	sfifo_data_oe,
	rxf_n,
	txe_n,
	rd_n,
	wr_n,
	oe_n,
	// SPI
	ss_n,
	sck,
	mosi,
	miso,
	// UART
	txd,
	rxd,
	rts,
	cts
);

input	[1:0]	host_mode;
input			inactive_io;
input			unused_io;
input			flow_control;
// FTDI
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
// Sync-FIFO
input	[7:0]	sfifo_data_out;
output	[7:0]	sfifo_data_in;
input			sfifo_data_oe;
output			rxf_n;
output			txe_n;
input			rd_n;
input			wr_n;
input			oe_n;
// SPI
output			ss_n;
output			sck;
output			mosi;
input			miso;
// UART
input			txd;
output			rxd;
input			rts;
output			cts;

wire			sfifo_inactive_state;
wire			spi_inactive_state;

genvar i;

assign sfifo_data_in = {d7_4_in, d3_ss_n_rts_n_in, d2_miso_cts_n_in, d1_mosi_txd_in, d0_sck_rxd_in};//ft232h_adbus_in;

assign sfifo_inactive_state = oe_n & wr_n;
assign spi_inactive_state   = ss_n;


// adbus[0]
assign d0_sck_rxd_out = (host_mode == `HOST_MODE_SFIFO ? ((inactive_io & sfifo_inactive_state) ? d0_sck_rxd_in : sfifo_data_out[0]) : 1'b0);
assign d0_sck_rxd_oe  = (host_mode == `HOST_MODE_SFIFO ? ((sfifo_data_oe | (inactive_io & sfifo_inactive_state)) ? 1'b1 : 1'b0) :
							  1'b0);

// adbus[1]
assign d1_mosi_txd_out = (host_mode == `HOST_MODE_SFIFO ? ((inactive_io & sfifo_inactive_state) ? d1_mosi_txd_in : sfifo_data_out[1]) :
						 (host_mode == `HOST_MODE_UART ? txd :
						  1'b0));
assign d1_mosi_txd_oe  = (host_mode == `HOST_MODE_SFIFO ? ((sfifo_data_oe | (inactive_io & sfifo_inactive_state)) ? 1'b1 : 1'b0) :
						 (host_mode == `HOST_MODE_UART ? 1'b1 :															// TXD
						  1'b0));

// adbus[2]
assign d2_miso_cts_n_out = (host_mode == `HOST_MODE_SFIFO ? ((inactive_io & sfifo_inactive_state) ? d2_miso_cts_n_in : sfifo_data_out[2]) :
						   (host_mode == `HOST_MODE_SPI ? ((inactive_io & spi_inactive_state) ? 1'b0 : miso) :
							1'b0));
assign d2_miso_cts_n_oe  = (host_mode == `HOST_MODE_SFIFO ? ((sfifo_data_oe | (inactive_io & sfifo_inactive_state)) ? 1'b1 : 1'b0) :
						   (host_mode == `HOST_MODE_SPI ? ((~ss_n | (inactive_io & spi_inactive_state)) ? 1'b1 : 1'b0) :	// MISO
						   (host_mode == `HOST_MODE_UART ? ((~flow_control & unused_io) ? 1'b1 : 1'b0) :					// CTS
							1'b0)));

// adbus[3]
assign d3_ss_n_rts_n_out = (host_mode == `HOST_MODE_SFIFO ? ((inactive_io & sfifo_inactive_state) ? d3_ss_n_rts_n_in : sfifo_data_out[3]) :
						   (host_mode == `HOST_MODE_UART ? (flow_control ? rts : 1'b0) :
							1'b0));
assign d3_ss_n_rts_n_oe  = (host_mode == `HOST_MODE_SFIFO ? ((sfifo_data_oe | (inactive_io & sfifo_inactive_state)) ? 1'b1 : 1'b0) :
						   (host_mode == `HOST_MODE_UART ? ((flow_control | unused_io) ? 1'b1 : 1'b0) :					// RTS
							1'b0));

// adbus[7:4]
generate
for(i = 0; i < 4; i=i+1)
begin

	assign d7_4_out[i] = (host_mode == `HOST_MODE_SFIFO ? ((inactive_io & sfifo_inactive_state) ? d7_4_in[i] : sfifo_data_out[4+i]) : 1'b0);
	assign d7_4_oe[i]  = (host_mode == `HOST_MODE_SFIFO ? ((sfifo_data_oe | (inactive_io & sfifo_inactive_state)) ? 1'b1 : 1'b0) : (unused_io ? 1'b1 : 1'b0));

end
endgenerate

// acbus[0] : RXF#
assign rxf_n_out = 1'b0;
assign rxf_n	 = (host_mode == `HOST_MODE_SFIFO ? rxf_n_in : 1'b1);
assign rxf_n_oe  = (host_mode == `HOST_MODE_SFIFO ? 1'b0 : (unused_io ? 1'b1 : 1'b0));

// acbus[1] : TXE#
assign txe_n_out = 1'b0;
assign txe_n	 = (host_mode == `HOST_MODE_SFIFO ? txe_n_in : 1'b1);
assign txe_n_oe  = (host_mode == `HOST_MODE_SFIFO ? 1'b0 : (unused_io ? 1'b1 : 1'b0));

// acbus[2] : RD#
assign rd_n_out = (host_mode == `HOST_MODE_SFIFO ? rd_n : 1'b0);
assign rd_n_oe  = (host_mode == `HOST_MODE_SFIFO ? 1'b1 : (unused_io ? 1'b1 : 1'b0));

// acbus[3] : WR#
assign wr_n_out = (host_mode == `HOST_MODE_SFIFO ? wr_n : 1'b0);
assign wr_n_oe  = (host_mode == `HOST_MODE_SFIFO ? 1'b1 : (unused_io ? 1'b1 : 1'b0));

// acbus[6] : OE#
assign oe_n_out = (host_mode == `HOST_MODE_SFIFO ? oe_n : 1'b0);
assign oe_n_oe	= (host_mode == `HOST_MODE_SFIFO ? 1'b1 : (unused_io ? 1'b1 : 1'b0));

// SPI
assign sck  = (host_mode == `HOST_MODE_SPI) ? d0_sck_rxd_in : 1'b0;
assign mosi = (host_mode == `HOST_MODE_SPI) ? d1_mosi_txd_in : 1'b0;
assign ss_n = (host_mode == `HOST_MODE_SPI) ? d3_ss_n_rts_n_in : 1'b1;

// UART
assign rxd  = (host_mode == `HOST_MODE_UART) ? d0_sck_rxd_in : 1'b1;
assign cts  = (host_mode == `HOST_MODE_UART) ? d2_miso_cts_n_in : 1'b1;

endmodule
