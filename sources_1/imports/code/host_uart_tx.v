`include "timescale.v"
`include "define.v"

module host_uart_tx (
	reset_n,
	clk,
	baud_nco,
	stop_bit,
	flow_control,
	txd,
	cts,
	
	fifo_rd_en,
	fifo_din,
	fifo_empty
);

input			reset_n;
input			clk;
input	[31:0]	baud_nco;
input	[3:0]	stop_bit;
input			flow_control;
output			txd;
input			cts;

output			fifo_rd_en;
input	[7:0]	fifo_din;
input			fifo_empty;

// uart_clk = SYS_CLK*baud_nco/2^32
reg		[31:0]	nco;
wire			nco_msb;
reg				nco_msb_d1;
wire			nco_trig;

reg		[2:0]	data_idx;
reg		[3:0]	stop_idx;

reg				txd;

`define ST_IDLE				2'd0
`define ST_START			2'd1
`define ST_DATA				2'd2
`define ST_STOP				2'd3

reg		[1:0]	state;
reg		[1:0]	nstate;

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
			if(nco_trig & fifo_rd_en)
				nstate = `ST_START;
			else begin
				nstate = `ST_IDLE;
			end
		end

		`ST_START :  begin
			if(nco_trig) begin
				nstate = `ST_DATA;
			end
			else begin
				nstate = `ST_START;
			end
		end

		`ST_DATA :  begin
			if(nco_trig && data_idx == 0)
				nstate = `ST_STOP;
			else begin
				nstate = `ST_DATA;
			end
		end

		`ST_STOP :  begin
			if(nco_trig && fifo_rd_en)
				nstate = `ST_START;
			else if(nco_trig && stop_idx == stop_bit)
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
	if(!reset_n)
		nco <= #1 0;
	else begin
		nco <= #1 nco + baud_nco;
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
			if(state == `ST_IDLE || state == `ST_STOP)
				data_idx <= #1 0;
			else if(state == `ST_START)
				data_idx <= #1 1;
			else if(state == `ST_DATA) begin
				data_idx <= #1 data_idx + 1'b1;
			end
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		stop_idx <= #1 0;
	else begin
		if(nco_trig) begin
			if(state == `ST_IDLE || state == `ST_DATA)
				stop_idx <= #1 0;
			else if(state == `ST_STOP) begin
				stop_idx <= #1 stop_idx + 1'b1;
			end
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		txd <= #1 1;
	else begin
		if(nco_trig) begin
			if(nstate == `ST_START)
				txd <= #1 0;
			else if(nstate == `ST_STOP)
				txd <= #1 1;
			else if(nstate == `ST_DATA) begin
				txd <= #1 fifo_din[data_idx];
			end
		end
	end
end


assign nco_msb = nco[31];

assign nco_trig = nco_msb & ~nco_msb_d1;

assign fifo_rd_en = (state == `ST_IDLE || (state == `ST_STOP && stop_idx == stop_bit)) && nco_trig && !fifo_empty && (~flow_control || ~cts);

endmodule
