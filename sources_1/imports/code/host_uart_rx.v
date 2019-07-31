`include "timescale.v"
`include "define.v"

module host_uart_rx (
	reset_n,
	clk,
	baud_nco,
	flow_control,
	rxd,
	rts,
	
	fifo_rd_en,
	fifo_dout,
	fifo_empty
);

input			reset_n;
input			clk;
input	[31:0]	baud_nco;
input			flow_control;
input			rxd;
output			rts;

input			fifo_rd_en;
output	[7:0]	fifo_dout;
output			fifo_empty;

// uart_clk = SYS_CLK*baud_nco/2^32
reg		[31:0]	nco;
wire			nco_msb;
reg				nco_msb_d1;
wire			nco_trig;

wire	[7:0]	fifo_din;
wire			fifo_wr_en;
wire			fifo_full;
wire			fifo_empty;

wire	[7:0]	fifo_dout_f;
wire			fifo_full_f;
wire			fifo_empty_f;

reg		[2:0]	data_idx;

reg				rxd_d1;
reg				rxd_d2;
reg				rxd_d3;

reg		[7:0]	rx_shift_data;

`define ST_IDLE				2'd0
`define ST_START			2'd1
`define ST_DATA				2'd2
`define ST_STOP				2'd3

reg		[1:0]	state;
reg		[1:0]	nstate;

fifo_8x16 u_host_fifo_8x16(
	.clk(clk),
	.reset(~reset_n),
	.din(fifo_din),
	.wr_en(fifo_wr_en),
	.rd_en(fifo_rd_en),
	.dout(fifo_dout_f),
	.full(fifo_full_f),
	.empty(fifo_empty_f)
);
assign #1 fifo_full  = fifo_full_f;
assign #1 fifo_empty = fifo_empty_f;
assign #1 fifo_dout  = fifo_dout_f;

//synopsys translate_off
reg		[30*8:1]	state_str;
always @(state)
begin
	case (state)
		`ST_IDLE			: state_str = "ST_IDLE";
		`ST_START			: state_str = "ST_START";
		`ST_DATA			: state_str = "ST_DATA";
		`ST_STOP			: state_str = "ST_STOP";
		default				: state_str = "default";
	endcase
end
//synopsys translate_on

always @( * )
begin
	case (state)
		`ST_IDLE :  begin
			if(rxd_d3 == 1 && rxd_d2 == 0 && rxd_d1 == 0)
				nstate = `ST_START;
			else begin
				nstate = `ST_IDLE;
			end
		end

		`ST_START :  begin
			if(nco_trig) begin
				if(rxd_d3 == 0)
					nstate = `ST_DATA;
				else begin
					nstate = `ST_IDLE;
				end
			end
			else begin
				nstate = `ST_START;
			end
		end

		`ST_DATA :  begin
			if(nco_trig && data_idx == 7)
				nstate = `ST_STOP;
			else begin
				nstate = `ST_DATA;
			end
		end

		`ST_STOP :  begin
			if(nco_trig)
				nstate = `ST_IDLE;
			else begin
				nstate = `ST_STOP;
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
		state <= #1 `ST_IDLE;
	else begin
		state <= #1 nstate;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n) begin
		rxd_d1 <= #1 1;
		rxd_d2 <= #1 1;
		rxd_d3 <= #1 1;
	end
	else begin
		rxd_d1 <= #1 rxd;
		rxd_d2 <= #1 rxd_d1;
		rxd_d3 <= #1 rxd_d2;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		nco <= #1 0;
	else begin
		if(nstate == `ST_IDLE)
			nco <= #1 {1'b1, {31{1'b0}}};	// half
		else begin
			nco <= #1 nco + baud_nco;
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		nco_msb_d1 <= #1 0;
	else begin
		nco_msb_d1 <= #1 nco_msb;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		data_idx <= #1 0;
	else begin
		if(nco_trig) begin
			if(nstate == `ST_IDLE || nstate == `ST_STOP || nstate == `ST_START)
				data_idx <= #1 0;
			else if(state == `ST_DATA) begin
				data_idx <= #1 data_idx + 1'b1;
			end
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		rx_shift_data <= #1 0;
	else begin
		if(state == `ST_IDLE)
			rx_shift_data <= #1 0;
		else if(nco_trig && state == `ST_DATA) begin
			rx_shift_data <= #1 {rxd_d3, rx_shift_data[7:1]};
		end
	end
end

assign nco_msb = nco[31];

assign nco_trig = ~nco_msb & nco_msb_d1;

assign fifo_wr_en = !fifo_full && state == `ST_STOP && nstate == `ST_IDLE && rxd_d3 == 1;
assign fifo_din = rx_shift_data;

assign rts = flow_control ? fifo_full : 1'b0;

endmodule
