`include "define.v"
`include "timescale.v"

module host_sync_fifo(
	reset_n,
	clk,
	host_mode,

	ft_clk,
	data_out,
	data_in,
	data_oe,
	rxf_n,
	txe_n,
	rd_n,
	wr_n,
	oe_n,

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

input			ft_clk;
output	[7:0]	data_out;
input	[7:0]	data_in;
output			data_oe;
input			rxf_n;
input			txe_n;
output			rd_n;
output			wr_n;
output			oe_n;
input			rx_fifo_rd_en;
output	[7:0]	rx_fifo_dout;
output			rx_fifo_empty;
output			tx_fifo_rd_en;
input	[7:0]	tx_fifo_din;
input			tx_fifo_empty;

reg		[1:0]	host_mode_sfifo;

reg				tx_rx_priority;			// 0:TX, 1:RX
reg		[1:0]	tx_dcfifo_read_pnd_cnt;
reg				tx_setup_pnd_cnt_dec;

reg				oe_n;
reg				rd_n;
reg				wr_n;
reg				rx_fifo_write_pending;
reg		[7:0]	rx_fifo_pending_data;

reg		[7:0]	data_out;

wire			rx_fifo_wr_en;
wire	[7:0]	rx_fifo_din;
wire	[7:0]	rx_fifo_dout_f;
wire	[7:0]	rx_fifo_dout;
wire			rx_fifo_full_f;
wire			rx_fifo_full;
wire			rx_fifo_empty_f;
wire			rx_fifo_empty;

reg				tx_fifo_rd_en_d1;

reg				tx_fifo_wr_pending;
reg				tx_dcfifo_rd_en_d1;
wire	[7:0]	tx_dcfifo_dout_f;
wire	[7:0]	tx_dcfifo_dout;
wire			tx_dcfifo_wr_en;
wire			tx_dcfifo_full_f;
wire			tx_dcfifo_full;
wire			tx_dcfifo_empty_f;
wire			tx_dcfifo_empty;

// Write Direction (Host -> SoC)
fifo_8x16_dc u_host_dc_rx_fifo_8x16(
	.rst(~reset_n),
	.wr_clk(ft_clk),
	.rd_clk(clk),
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

// Read Direction (SoC -> Host)
fifo_8x16_dc u_host_dc_tx_fifo_8x16(
	.rst(~reset_n),
	.wr_clk(clk),
	.rd_clk(ft_clk),
	.din(tx_fifo_din),
	.wr_en(tx_dcfifo_wr_en),
	.rd_en(tx_dcfifo_rd_en),
	.dout(tx_dcfifo_dout_f),
	.full(tx_dcfifo_full_f),
	.empty(tx_dcfifo_empty_f)
);
assign #1 tx_dcfifo_full  = tx_dcfifo_full_f;
assign #1 tx_dcfifo_empty = tx_dcfifo_empty_f;
assign #1 tx_dcfifo_dout  = tx_dcfifo_dout_f;


`define ST_IDLE				3'd0
`define ST_RX_SETUP			3'd1
`define ST_RX_DATA			3'd2
`define ST_TX_SETUP			3'd3
`define ST_TX_DATA			3'd4

reg		[2:0]	state;
reg		[2:0]	nstate;

//synopsys translate_off
reg		[30*8:1]	state_str;
always @(state)
begin
	case (state)
		`ST_IDLE			: state_str = "ST_IDLE";
		`ST_RX_SETUP		: state_str = "ST_RX_SETUP";
		`ST_RX_DATA			: state_str = "ST_RX_DATA";
		`ST_TX_SETUP		: state_str = "ST_TX_SETUP";
		`ST_TX_DATA			: state_str = "ST_TX_DATA";
		default				: state_str = "default";
	endcase
end
//synopsys translate_on

always @( * )
begin
	case (state)
		`ST_IDLE :  begin
			if(host_mode_sfifo != `HOST_MODE_SFIFO)
				nstate = `ST_IDLE;
			else if(tx_rx_priority == `DIR_TX) begin
				if(tx_dcfifo_rd_en_d1)
					nstate = `ST_IDLE;
				else if(~txe_n && (~tx_dcfifo_empty || tx_dcfifo_read_pnd_cnt != 0))
					nstate = `ST_TX_SETUP;
				else if(~rxf_n && ~rx_fifo_full)
					nstate = `ST_RX_SETUP;
				else begin
					nstate = `ST_IDLE;
				end
			end
			else begin
				if(~rxf_n && ~rx_fifo_full)
					nstate = `ST_RX_SETUP;
				else if(tx_dcfifo_rd_en_d1)
					nstate = `ST_IDLE;
				else if(~txe_n && (~tx_dcfifo_empty || tx_dcfifo_read_pnd_cnt != 0))
					nstate = `ST_TX_SETUP;
				else begin
					nstate = `ST_IDLE;
				end
			end
		end

		`ST_TX_SETUP :  begin
			if(txe_n)
				nstate = `ST_IDLE;
			else begin
				nstate = `ST_TX_DATA;
			end
		end

		`ST_TX_DATA :  begin
			if(txe_n || tx_dcfifo_empty || tx_dcfifo_read_pnd_cnt == 0)
				nstate = `ST_IDLE;
			else begin
				nstate = `ST_TX_DATA;
			end
		end

		`ST_RX_SETUP :  begin
//			if(rx_fifo_full) -> IDLE ???
			nstate = `ST_RX_DATA;
		end

		`ST_RX_DATA :  begin
			if(rxf_n || rx_fifo_full)
				nstate = `ST_IDLE;
			else begin
				nstate = `ST_RX_DATA;
			end
		end

		default : begin
			nstate = `ST_IDLE;
		end

	endcase
end

always @(negedge reset_n or posedge ft_clk)
begin
	if (!reset_n)
		state <= #1 `ST_IDLE;
	else begin
		state <= #1 nstate;
	end
end

always @(negedge reset_n or posedge ft_clk)
begin
	if (!reset_n)
		host_mode_sfifo <= #1 0;
	else begin
		host_mode_sfifo <= #1 host_mode;
	end
end

always @(negedge reset_n or posedge ft_clk)
begin
	if (!reset_n)
		tx_rx_priority <= #1 0;
	else begin
		if(state == `ST_TX_SETUP)
			tx_rx_priority <= #1 `DIR_RX;
		else if(state == `ST_RX_SETUP)
			tx_rx_priority <= #1 `DIR_TX;
		else if(state == `ST_IDLE) begin
			tx_rx_priority <= #1 ~tx_rx_priority;
		end
	end
end

always @(negedge reset_n or posedge ft_clk)
begin
	if (!reset_n)
		oe_n <= #1 1;
	else begin
		if(nstate == `ST_RX_SETUP)
			oe_n <= #1 0;
		else if(nstate == `ST_IDLE) begin
			oe_n <= #1 1;
		end
	end
end

always @(negedge reset_n or posedge ft_clk)
begin
	if (!reset_n)
		rd_n <= #1 1;
	else begin
		if(nstate == `ST_RX_DATA)
			rd_n <= #1 0;
		else if(nstate == `ST_IDLE) begin
			rd_n <= #1 1;
		end
	end
end

always @(negedge reset_n or posedge ft_clk)
begin
	if (!reset_n)
		wr_n <= #1 1;
	else begin
		if(state == `ST_TX_SETUP && nstate == `ST_TX_DATA)
			wr_n <= #1 0;
		else if(nstate == `ST_IDLE) begin
			wr_n <= #1 1;
		end
	end
end

always @(negedge reset_n or posedge ft_clk)
begin
	if (!reset_n)
		rx_fifo_write_pending <= #1 0;
	else begin
		if(state == `ST_RX_DATA && nstate == `ST_IDLE && rx_fifo_full && ~rxf_n)
			rx_fifo_write_pending <= #1 1;
		else if(rx_fifo_wr_en) begin
			rx_fifo_write_pending <= #1 0;
		end
	end
end

always @(negedge reset_n or posedge ft_clk)
begin
	if (!reset_n)
		rx_fifo_pending_data <= #1 0;
	else begin
		if(state == `ST_RX_DATA && nstate == `ST_IDLE && rx_fifo_full) begin
			rx_fifo_pending_data <= #1 data_in;
		end
	end
end

// TX
always @(negedge reset_n or posedge ft_clk)
begin
	if (!reset_n)
		tx_dcfifo_rd_en_d1 <= #1 0;
	else begin
		tx_dcfifo_rd_en_d1 <= #1 tx_dcfifo_rd_en;
	end
end

always @(negedge reset_n or posedge ft_clk)
begin
	if (!reset_n)
		tx_dcfifo_read_pnd_cnt <= #1 0;
	else begin
		if(state == `ST_IDLE && tx_dcfifo_rd_en_d1)
			tx_dcfifo_read_pnd_cnt <= #1 tx_dcfifo_read_pnd_cnt + 1;
		else if(tx_dcfifo_rd_en && (state == `ST_TX_SETUP || nstate == `ST_TX_SETUP))
			tx_dcfifo_read_pnd_cnt <= #1 tx_dcfifo_read_pnd_cnt + 1;
		else if(state == `ST_TX_SETUP && nstate == `ST_TX_DATA && ~tx_dcfifo_rd_en && tx_dcfifo_empty) begin
			if(tx_dcfifo_read_pnd_cnt != 0) begin
				tx_dcfifo_read_pnd_cnt <= #1 tx_dcfifo_read_pnd_cnt - 1;
			end
		end
		else if(state == `ST_TX_DATA && ~txe_n && ~tx_dcfifo_rd_en && ~tx_setup_pnd_cnt_dec) begin
			if(tx_dcfifo_read_pnd_cnt != 0) begin
				tx_dcfifo_read_pnd_cnt <= #1 tx_dcfifo_read_pnd_cnt - 1;
			end
		end
	end
end

always @(negedge reset_n or posedge ft_clk)
begin
	if (!reset_n)
		tx_setup_pnd_cnt_dec <= #1 0;
	else begin
		if(tx_setup_pnd_cnt_dec)
			tx_setup_pnd_cnt_dec <= #1 0;
		else if(state == `ST_TX_SETUP && nstate == `ST_TX_DATA && ~tx_dcfifo_rd_en && tx_dcfifo_empty) begin
			tx_setup_pnd_cnt_dec <= #1 1;
		end
	end
end

always @(negedge reset_n or posedge ft_clk)
begin
	if (!reset_n)
		data_out <= #1 0;
	else begin
		if(state == `ST_TX_SETUP && tx_dcfifo_read_pnd_cnt == 1)
			data_out <= #1 tx_dcfifo_dout;
		else if((tx_dcfifo_rd_en_d1 && ~txe_n) || (state == `ST_TX_DATA && nstate != `ST_IDLE)) begin
			data_out <= #1 tx_dcfifo_dout;
		end
	end
end

// clk domain
always @(negedge reset_n or posedge clk)
begin
	if (!reset_n)
		tx_fifo_rd_en_d1 <= #1 0;
	else begin
		tx_fifo_rd_en_d1 <= #1 tx_fifo_rd_en;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n)
		tx_fifo_wr_pending <= #1 0;
	else begin
		if(tx_fifo_rd_en_d1 && tx_dcfifo_full)
			tx_fifo_wr_pending <= #1 1;
		else if(tx_dcfifo_wr_en) begin
			tx_fifo_wr_pending <= #1 0;
		end
	end
end

assign data_oe = ~wr_n;

// ft_clk domain
assign rx_fifo_wr_en = ~rx_fifo_full && ((~rxf_n && ~rd_n) || (rx_fifo_write_pending));
assign rx_fifo_din   = rx_fifo_write_pending ? rx_fifo_pending_data : data_in;

assign tx_dcfifo_rd_en = ~tx_dcfifo_empty && ~txe_n && (((tx_dcfifo_read_pnd_cnt < 1 && nstate == `ST_TX_SETUP) || (tx_dcfifo_read_pnd_cnt < 2 && state == `ST_TX_SETUP)) || state == `ST_TX_DATA);

// clk domain
assign tx_fifo_rd_en = ~tx_fifo_empty && ~tx_dcfifo_full && ~tx_fifo_wr_pending;
assign tx_dcfifo_wr_en = ~tx_dcfifo_full && (tx_fifo_rd_en_d1 || tx_fifo_wr_pending);

`ifdef MODELSIM
	`undef USE_CHIPSCOPE
`endif

`ifdef USE_CHIPSCOPE
/*
reg		[7:0]	data_out_d1;

always @(negedge reset_n or posedge ft_clk)
begin
	if (!reset_n)
		data_out_d1 <= #1 0;
	else begin
		if(~txe_n && ~wr_n) begin
			data_out_d1 <= #1 data_out;
		end
	end
end

ila_sfifo u_ila_sfifo(
	.clk(ft_clk),
	.probe0(rxf_n),
	.probe1(txe_n),
	.probe2(rd_n),
	.probe3(wr_n),
	.probe4(oe_n),
	.probe5(data_out),
	.probe6(data_in),
	.probe7(data_oe),
	.probe8(rx_fifo_wr_en),
	.probe9(rx_fifo_din),
	.probe10(rx_fifo_full),
	.probe11(tx_fifo_rd_en),
	.probe12(tx_fifo_dout),
	.probe13(tx_fifo_empty),
	.probe14(rx_fifo_write_pending),
	.probe15(rx_fifo_pending_data),
	.probe16(tx_fifo_rd_en_d1),
	.probe17(tx_dcfifo_read_pnd_cnt),
	.probe18(state),
	.probe19(nstate),
	.probe20(data_out_d1)
);
*/

/*
ila_sfifo_simple u_ila_sfifo_simple(
	.clk(ft_clk),
	.probe0(rxf_n),
	.probe1(txe_n),
	.probe2(rd_n),
	.probe3(wr_n)
);
*/

`endif

endmodule
