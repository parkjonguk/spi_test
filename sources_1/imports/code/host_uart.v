`include "define.v"
`include "timescale.v"

module host_uart(
	reset_n,
	clk,

	baud_nco,
	stop_bit,
	flow_control,
	txd,
	rxd,
	rts,
	cts,
	
	rx_fifo_rd_en,
	rx_fifo_dout,
	rx_fifo_empty,

	tx_fifo_rd_en,
	tx_fifo_din,
	tx_fifo_empty
);

input			reset_n;
input			clk;

input	[31:0]	baud_nco;
input	[3:0]	stop_bit;
input			flow_control;
output			txd;
input			rxd;
output			rts;
input			cts;

input			rx_fifo_rd_en;
output	[7:0]	rx_fifo_dout;
output			rx_fifo_empty;

output			tx_fifo_rd_en;
input	[7:0]	tx_fifo_din;
input			tx_fifo_empty;


host_uart_tx u_host_uart_tx(
	.reset_n(reset_n),
	.clk(clk),
	.baud_nco(baud_nco),
	.stop_bit(stop_bit),
	.flow_control(flow_control),
	.txd(txd),
	.cts(cts),
	.fifo_rd_en(tx_fifo_rd_en),
	.fifo_din(tx_fifo_din),
	.fifo_empty(tx_fifo_empty)
);

host_uart_rx u_host_uart_rx(
	.reset_n(reset_n),
	.clk(clk),
	.baud_nco(baud_nco),
	.flow_control(flow_control),
	.rxd(rxd),
	.rts(rts),
	.fifo_rd_en(rx_fifo_rd_en),
	.fifo_dout(rx_fifo_dout),
	.fifo_empty(rx_fifo_empty)
);

endmodule
