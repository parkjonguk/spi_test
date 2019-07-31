`include "timescale.v"
`include "define.v"

module host_fifo_mux(
	host_mode,
	
	sfifo_rx_fifo_rd_en,
	sfifo_rx_fifo_dout,
	sfifo_rx_fifo_empty,
	sfifo_tx_fifo_rd_en,
	sfifo_tx_fifo_din,
	sfifo_tx_fifo_empty,
	
	spi_rx_fifo_rd_en,
	spi_rx_fifo_dout,
	spi_rx_fifo_empty,
	spi_tx_fifo_rd_en,
	spi_tx_fifo_din,
	spi_tx_fifo_empty,

	uart_rx_fifo_rd_en,
	uart_rx_fifo_dout,
	uart_rx_fifo_empty,
	uart_tx_fifo_rd_en,
	uart_tx_fifo_din,
	uart_tx_fifo_empty,
	
	rx_fifo_rd_en,
	rx_fifo_dout,
	rx_fifo_empty,
	
	tx_fifo_rd_en,
	tx_fifo_din,
	tx_fifo_empty	
);

input	[1:0]	host_mode;

output			sfifo_rx_fifo_rd_en;
input	[7:0]	sfifo_rx_fifo_dout;
input			sfifo_rx_fifo_empty;
input			sfifo_tx_fifo_rd_en;
output	[7:0]	sfifo_tx_fifo_din;
output			sfifo_tx_fifo_empty;

output			spi_rx_fifo_rd_en;
input	[7:0]	spi_rx_fifo_dout;
input			spi_rx_fifo_empty;
input			spi_tx_fifo_rd_en;
output	[7:0]	spi_tx_fifo_din;
output			spi_tx_fifo_empty;

output			uart_rx_fifo_rd_en;
input	[7:0]	uart_rx_fifo_dout;
input			uart_rx_fifo_empty;
input			uart_tx_fifo_rd_en;
output	[7:0]	uart_tx_fifo_din;
output			uart_tx_fifo_empty;

input			rx_fifo_rd_en;
output	[7:0]	rx_fifo_dout;
output			rx_fifo_empty;

output			tx_fifo_rd_en;
input	[7:0]	tx_fifo_din;
input			tx_fifo_empty;

assign rx_fifo_dout		= (host_mode == `HOST_MODE_SFIFO ? sfifo_rx_fifo_dout :
						  (host_mode == `HOST_MODE_SPI ? spi_rx_fifo_dout :
						   uart_rx_fifo_dout));

assign rx_fifo_empty	= (host_mode == `HOST_MODE_SFIFO ? sfifo_rx_fifo_empty :
						  (host_mode == `HOST_MODE_SPI ? spi_rx_fifo_empty :
						   uart_rx_fifo_empty));

assign tx_fifo_rd_en	= (host_mode == `HOST_MODE_SFIFO ? sfifo_tx_fifo_rd_en :
						  (host_mode == `HOST_MODE_SPI ? spi_tx_fifo_rd_en :
						   uart_tx_fifo_rd_en));

//assign sfifo_rx_fifo_rd_en = (host_mode == `HOST_MODE_SFIFO) ? rx_fifo_rd_en : 1'b0;
assign sfifo_rx_fifo_rd_en = (host_mode == `HOST_MODE_SFIFO) ? rx_fifo_rd_en : ~sfifo_rx_fifo_empty;
assign sfifo_tx_fifo_din   = tx_fifo_din;
assign sfifo_tx_fifo_empty = tx_fifo_empty;

//assign spi_rx_fifo_rd_en   = (host_mode == `HOST_MODE_SPI) ? rx_fifo_rd_en : 1'b0;
assign spi_rx_fifo_rd_en   = (host_mode == `HOST_MODE_SPI) ? rx_fifo_rd_en : ~spi_rx_fifo_empty;
assign spi_tx_fifo_din     = tx_fifo_din;
assign spi_tx_fifo_empty   = tx_fifo_empty;

//assign uart_rx_fifo_rd_en  = (host_mode == `HOST_MODE_UART) ? rx_fifo_rd_en : 1'b0;
assign uart_rx_fifo_rd_en  = (host_mode == `HOST_MODE_UART) ? rx_fifo_rd_en : ~uart_rx_fifo_empty;
assign uart_tx_fifo_din    = tx_fifo_din;
assign uart_tx_fifo_empty  = tx_fifo_empty;

endmodule
