`include "define.v"
`include "timescale.v"

module host_spi(
	reset_n,
	clk,
	host_mode,

	ss_n,
	sck,
	mosi,
	miso,
	miso_edge,

	rx_fifo_rd_en,
	rx_fifo_dout,
	rx_fifo_empty,

	tx_fifo_rd_en,
	tx_fifo_din,
	tx_fifo_empty
);

input			reset_n;
input			clk;
input	[1:0]	host_mode;

input			ss_n;
input			sck;
input			mosi;
output			miso;
input			miso_edge;		// 0:falling_edge, 1:rising_edge
input			rx_fifo_rd_en;
output	[7:0]	rx_fifo_dout;
output			rx_fifo_empty;
output			tx_fifo_rd_en;
input	[7:0]	tx_fifo_din;
input			tx_fifo_empty;

reg				ss_n_d1;
reg				ss_n_d2;

reg				sck_d1;
reg				sck_d2;

reg				mosi_d1;
reg				mosi_d2;

wire			sck_rising;
reg				sck_rising_d1;
wire			sck_falling;
reg		[2:0]	sck_idx;
reg		[7:0]	mosi_shift;
reg		[7:0]	miso_shift;

reg				rx_fifo_full_inhibit;

reg				opcode_phase;
reg				opcode;

wire			rx_fifo_wr_en;
wire	[7:0]	rx_fifo_din;
wire	[7:0]	rx_fifo_dout_f;
wire	[7:0]	rx_fifo_dout;
wire			rx_fifo_full_f;
wire			rx_fifo_full;
wire			rx_fifo_empty_f;
wire			rx_fifo_empty;

reg				tx_fifo_rd_fetch;

// Write Direction (Host -> SoC)
fifo_8x16 u_host_rx_fifo_8x16(
	.clk(clk),
	.reset(~reset_n),
	.din(rx_fifo_din),
	.wr_en(rx_fifo_wr_en),
	.rd_en(rx_fifo_rd_en),
	.dout(rx_fifo_dout_f),
	.full(rx_fifo_full_f),
	.empty(rx_fifo_empty_f)
);
assign #1 rx_fifo_full  = rx_fifo_full_f;
assign #1 rx_fifo_empty = rx_fifo_empty_f;
assign #1 rx_fifo_dout  = rx_fifo_dout_f;

`define ST_IDLE				2'd0
`define ST_OPCODE			2'd1
`define ST_WRITE			2'd2
`define ST_READ				2'd3

reg		[1:0]	state;
reg		[1:0]	nstate;

//synopsys translate_off
reg		[30*8:1]	state_str;
always @(state)
begin
	case (state)
		`ST_IDLE			: state_str = "ST_IDLE";
		`ST_OPCODE			: state_str = "ST_OPCODE";
		`ST_WRITE			: state_str = "ST_WRITE";
		`ST_READ			: state_str = "ST_READ";
		default				: state_str = "default";
	endcase
end
//synopsys translate_on

always @( * )
begin
	case (state)
		`ST_IDLE :  begin
			if(ss_n_d2 & ~ss_n_d1)
				nstate = `ST_OPCODE;
			else begin
				nstate = `ST_IDLE;
			end
		end
		
		`ST_OPCODE :  begin
			if(sck_rising && sck_idx == 7) begin
				if(opcode == `DIR_RX)
					nstate = `ST_WRITE;
				else begin
					nstate = `ST_READ;
				end
			end
			else begin
				nstate = `ST_OPCODE;
			end
		end

		`ST_WRITE :  begin
			if(~ss_n_d2 & ss_n_d1)
				nstate = `ST_IDLE;
			else begin
				nstate = `ST_WRITE;
			end
		end

		`ST_READ :  begin
			if(~ss_n_d2 & ss_n_d1)
				nstate = `ST_IDLE;
			else begin
				nstate = `ST_READ;
			end
		end

		default : begin
			nstate = `ST_IDLE;
		end

	endcase
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n)
		state <= `ST_IDLE;
	else begin
		state <= #1 nstate;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n ) begin
		ss_n_d1 <= #1 0;
		ss_n_d2 <= #1 0;

		sck_d1 <= #1 0;
		sck_d2 <= #1 0;

		mosi_d1 <= #1 0;
		mosi_d2 <= #1 0;
	end
	else begin
		ss_n_d1 <= #1 ss_n;
		ss_n_d2 <= #1 ss_n_d1;

		sck_d1 <= #1 sck;
		sck_d2 <= #1 sck_d1;

		mosi_d1 <= #1 mosi;
		mosi_d2 <= #1 mosi_d1;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		sck_idx <= #1 0;
	else begin
		if(ss_n_d2 & ~ss_n_d1)
			sck_idx <= #1 0;
		else if(sck_rising) begin
			sck_idx <= #1 sck_idx + 1;
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		sck_rising_d1 <= #1 0;
	else begin
		sck_rising_d1 <= #1 sck_rising;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		opcode_phase <= #1 0;
	else begin
		if(ss_n_d2 & ~ss_n_d1)
			opcode_phase <= #1 1;
		else if(opcode_phase && sck_rising && sck_idx == 7) begin
			opcode_phase <= #1 0;
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		opcode <= #1 0;
	else begin
		if(opcode_phase && sck_rising && sck_idx == 0) begin
			opcode <= #1 mosi_d2;
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		mosi_shift <= #1 0;
	else begin
		if(sck_rising) begin
			mosi_shift <= #1 {mosi_shift[6:0], mosi_d2};
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		miso_shift <= #1 0;
	else begin
		if(ss_n_d2 & ~ss_n_d1)
			miso_shift <= #1 {6'd0, ~tx_fifo_empty, rx_fifo_full};
		else if(state == `ST_WRITE && sck_falling && sck_idx == 0)
			miso_shift <= #1 {6'd0, ~tx_fifo_empty, rx_fifo_full | rx_fifo_full_inhibit};
		else if(state == `ST_READ && sck_falling && sck_idx == 0)
			miso_shift <= #1 tx_fifo_din;
		else if((~miso_edge && sck_falling) || (miso_edge && sck_rising)) begin
//		else if(sck_falling) begin
			miso_shift <= #1 {miso_shift[6:0], 1'b0};
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		rx_fifo_full_inhibit <= #1 0;
	else begin
		if(ss_n_d2 & ss_n_d1)
			rx_fifo_full_inhibit <= #1 0;
		else if(state == `ST_WRITE & rx_fifo_full) begin
			rx_fifo_full_inhibit <= #1 1;
		end
	end
end

// TX
always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		tx_fifo_rd_fetch <= #1 0;
	else begin
		if(tx_fifo_rd_en)
			tx_fifo_rd_fetch <= #1 1;
		else if(state == `ST_READ && sck_rising_d1 && sck_idx == 1) begin
			tx_fifo_rd_fetch <= #1 0;
		end
	end
end

assign sck_rising  = ~sck_d2 &  sck_d1;
assign sck_falling =  sck_d2 & ~sck_d1;

assign miso = miso_shift[7];

assign rx_fifo_wr_en = ~rx_fifo_full && ~rx_fifo_full_inhibit && state == `ST_WRITE && sck_rising && sck_idx == 7;
assign rx_fifo_din = {mosi_shift[6:0], mosi_d2};

assign tx_fifo_rd_en = ~tx_fifo_empty && (host_mode != `HOST_MODE_SPI || (state == `ST_READ && sck_rising_d1 && sck_idx == 0 && ~tx_fifo_rd_fetch));

`ifdef MODELSIM
	`undef USE_CHIPSCOPE
`endif

`ifdef USE_CHIPSCOPE

ila_spi u_ila_spi(
	.clk(clk),
	.probe0(ss_n),
	.probe1(sck),
	.probe2(mosi),
	.probe3(miso),
	.probe4(miso_edge),
	.probe5(rx_fifo_rd_en),
	.probe6(rx_fifo_empty),
	.probe7(tx_fifo_rd_en),
	.probe8(tx_fifo_full)
);

`endif

endmodule
