 module tb_spi_ahb();

   reg                  clk;                    // To master of spi_master.v
   reg                  rst_n;                // To master of spi_master.v

   reg [7:0]            opcode;                 // To master of spi_master.v
   reg                  last;

   reg                  rx_data_ready;          // To master of spi_master.v
   reg [7:0]            tx_data;                // To master of spi_master.v
   reg                  tx_data_valid;          // To master of spi_master.v

   wire                 ss_n;                   // To master of spi_master.v
   wire                 miso;                   // To master of spi_master.v
   wire                 mosi;                   // From master of spi_master.v
   wire                 sck;                    // From master of spi_master.v

   wire [7:0]           rx_data;                // From master of spi_master.v
   wire                 rx_data_valid;          // From master of spi_master.v
   wire                 tx_data_ready;          // From master of spi_master.v

   //wire                 rx_fifo_wr_en;
//   wire [7:0]           rx_fifo_din;
//   wire                 rx_fifo_full;
//   wire                 tx_fifo_rd_en;
//   wire [7:0]           tx_fifo_dout;
//   wire                 tx_fifo_empty;

   reg [8*32-1:0]            in_buffer;
   reg [8*32-1:0]            out_buffer;
   integer                   in_ptr, out_ptr;

   localparam OP_WRITE = 8'h80;
   localparam OP_READ = 8'h00;

   spi_master master(
                     // Outputs
                     .mosi              (mosi),
                     .sck               (sck),
                     .tx_data_ready     (tx_data_ready),
                     .rx_data           (rx_data[7:0]),
                     .rx_data_valid     (rx_data_valid),
                     // Inputs
                     .reset_n           (rst_n),
                     .clk               (clk),
                     .ss_n              (ss_n),
                     .miso              (miso),
                     .tx_data           (tx_data[7:0]),
                     .tx_data_valid     (tx_data_valid),
                     .rx_data_ready     (rx_data_ready),
                     .opcode            (opcode[7:0]));



//reg			scl;
//reg			sda_in;
wire			sda_out;
wire			sda_oe;
//reg			i2c_addr;
//input           dbg_crypto_ahb;

//reg  pin_crypto_clear;
//reg  pin_disable_timeout;
//reg  pin_loopback;





// Default I/F Mode
`ifdef FPGA
//reg	[2:0]	def_mode;
wire	[1:0]	host_mode;
`else
//reg	[1:0]	def_mode;
`endif

// FTDI
//reg			ft_clk;
wire			d0_sck_rxd_out;
//reg			d0_sck_rxd_in;
wire			d0_sck_rxd_oe;
wire			d1_mosi_txd_out;
//reg			d1_mosi_txd_in;
wire			d1_mosi_txd_oe;
wire			d2_miso_cts_n_out;
//reg			d2_miso_cts_n_in;
wire			d2_miso_cts_n_oe;
wire			d3_ss_n_rts_n_out;
//reg			d3_ss_n_rts_n_in;
wire			d3_ss_n_rts_n_oe;
wire	[3:0]	d7_4_out;
//reg	[3:0]	d7_4_in;
wire	[3:0]	d7_4_oe;
//output  [5:0]   l3_state;
wire			rxf_n_out;
//reg			rxf_n_in;
wire			rxf_n_oe;
wire			txe_n_out;
//reg			txe_n_in;
wire			txe_n_oe;
wire			rd_n_out;
wire			rd_n_oe;
wire			wr_n_out;
wire			wr_n_oe;
wire			oe_n_out;
wire			oe_n_oe;

kepco_dtls_v2 chip(
	.reset_n(rst_n),
	.clk(clk),
	// I2C
	.scl('b0),
	.sda_in('b0),
	.sda_out(sda_out),
	.sda_oe(sda_oe),
	.i2c_addr('b0),
	// Default Host I/F Mode
	.def_mode(),
`ifdef FPGA
	.host_mode(host_mode),
`endif
	// FTDI
	.ft_clk(clk),
	.d0_sck_rxd_out(d0_sck_rxd_out),
	.d0_sck_rxd_in(sck),
	.d0_sck_rxd_oe(d0_sck_rxd_oe),
	.d1_mosi_txd_out(d1_mosi_txd_out),
	.d1_mosi_txd_in(mosi),
	.d1_mosi_txd_oe(d1_mosi_txd_oe),
	.d2_miso_cts_n_out(miso),
	.d2_miso_cts_n_in('b0),
	.d2_miso_cts_n_oe(d2_miso_cts_n_oe),
	.d3_ss_n_rts_n_out(d3_ss_n_rts_n_out),
	.d3_ss_n_rts_n_in(ss_n),
	.d3_ss_n_rts_n_oe(d3_ss_n_rts_n_oe),
	.d7_4_out(d7_4_out),
	.d7_4_in('b0),
	.d7_4_oe(d7_4_oe),
	.rxf_n_out(rxf_n_out),
	.rxf_n_in('b0),
	.rxf_n_oe(rxf_n_oe),
	.txe_n_out(txe_n_out),
	.txe_n_in('b0),
	.txe_n_oe(txe_n_oe),
	.rd_n_out(rd_n_out),
	.rd_n_oe(rd_n_oe),
	.wr_n_out(wr_n_out),
	.wr_n_oe(wr_n_oe),
	.oe_n_out(oe_n_out),
	.oe_n_oe(oe_n_oe),
//	l3_state,
  .pin_crypto_clear('b0),
  .pin_disable_timeout('b0),
  .pin_loopback('b1)
);


   always begin
      #5 clk = ~clk;
   end

   task master_write;
      input [7:0] data;
      begin
         #100 opcode = OP_WRITE;
         tx_data = data;
         tx_data_valid = 1;
         while(!tx_data_ready) begin
            #10 tx_data_valid = 1;
         end
         #10 tx_data_valid = 0;
      end
   endtask // master_send


   task master_read;
      input integer len;
      integer       i;
      begin
         opcode = OP_READ;
         in_ptr = 0;
         in_buffer = 0;
         for(i = 0; i < len; i = i + 1) begin
            #100 tx_data_valid = 1;
            rx_data_ready = 0;
            while(!rx_data_valid) begin
               #10 rx_data_ready = 0;
            end
            #10 rx_data_ready = 1;
            in_buffer = {in_buffer[31*8-1:0],rx_data};
            #10 rx_data_ready = 0;
            in_ptr = in_ptr + 8;
         end
         tx_data_valid = 0;
         #100 rx_data_ready = 0;
         while(!rx_data_valid) begin
            #10 rx_data_ready = 0;
         end
         #10 rx_data_ready = 1;
         in_buffer = {in_buffer[31*8-1:0],rx_data};
         #10 rx_data_ready = 0;
         $display("%x", in_buffer);
      end
   endtask // master_read


   initial begin;

        $timeformat(-9, 1, "ns", 10);
      $display("START");
      clk = 0;
      rst_n = 0;
      tx_data = 0;
      tx_data_valid = 0;
      rx_data_ready = 0;
      last = 0;

      #10
      rst_n = 1;
      #10000

      master_write(8'hAA); //SOF
      master_write(8'h55); //CONF
      master_write(8'h55); //ADDR_H
      master_write(8'h07); //ADDR_L

      master_write(8'h00);
      master_write(8'h08);
      master_write(8'h00);
      master_write(8'h08);

      master_write(8'h01);
      master_write(8'h00);
      master_write(8'h01);
      master_write(8'h04);

      master_write(8'h00);
      master_write(8'h00);
      master_write(8'h00);
      master_write(8'hC3);

      #10000
        master_read('h08);
      #10000

        #(20000-50)

      master_write(8'hAA); //SOF
      master_write({2'b11, 1'b0, 1'b0, 4'h0}); //CONF
      master_write(8'h00); //ADDR_H
      master_write(8'h04); //ADDR_L

      master_write(8'h00);
      master_write(8'h08);
      master_write(8'h00);
      master_write(8'h00);

      master_write(8'h00);
      master_write(8'h00);
      master_write(8'h00);
      master_write(8'h04);

      master_write(8'h00);
      master_write(8'h00);
      master_write(8'h00);
      master_write(8'hC3);

      #(10000-30)

      master_write(8'hAA); //SOF
      master_write({2'b11, 1'b0, 1'b1, 4'h0}); //CONF
      master_write(8'h00); //ADDR_H
      master_write(8'h0c); //ADDR_L

      master_write(8'h00);
      master_write(8'h00);
      master_write(8'h00);
      master_write(8'h04);

     #10000
        master_read(4 + 'h04);
      #10000


      #3000
        rst_n = 0;

      $display("FINISH");
      $finish;
   end
endmodule // top_module

// Local Variables:
// verilog-library-directories:("." "../rtl/")
// End:

