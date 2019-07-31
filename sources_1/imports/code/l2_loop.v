module l2_loop(
	//input
	pin_l2_loop, tx_fifo_empty, tx_fifo_dout, rx_fifo_empty, rx_fifo_dout, tx_fifo_rd_en_ahb,
	//output
	tx_fifo_rd_en, rx_fifo_rd_en_dbg, tx_fifo_empty_ahb, tx_fifo_dout_ahb
	);
   input           pin_l2_loop;

   input           tx_fifo_empty;
   input [31:0]    tx_fifo_dout;
   output          tx_fifo_rd_en;

   input           rx_fifo_empty;
   input [31:0]    rx_fifo_dout;
   output          rx_fifo_rd_en_dbg;

   output          tx_fifo_empty_ahb;
   output [31:0]   tx_fifo_dout_ahb;
   input           tx_fifo_rd_en_ahb;

   wire          tx_fifo_rd_en_dbg;
   wire          rx_fifo_rd_en_dbg;
   wire          tx_fifo_empty_ahb;
   wire [31:0]   tx_fifo_dout_ahb;

   assign tx_fifo_rd_en     = (pin_l2_loop == 1'b1) ? 1'b0 : tx_fifo_rd_en_ahb;
   assign rx_fifo_rd_en_dbg = (pin_l2_loop == 1'b1) ? tx_fifo_rd_en_ahb : 1'b0;
   assign tx_fifo_empty_ahb = (pin_l2_loop == 1'b1) ? rx_fifo_empty : tx_fifo_empty;
   assign tx_fifo_dout_ahb  = (pin_l2_loop == 1'b1) ? rx_fifo_dout  : tx_fifo_dout;

endmodule
