`include "define.v"
`include "timescale.v"

module host_i2c(
	reset_n,
	clk,

	scl,
	sda_in,
	sda_out,
	sda_oe,
	i2c_addr,

	def_mode,
	host_mode,
`ifdef FPGA
	loop,
`endif
	inactive_io,
	unused_io,
	miso_edge,
	stop_bit,
	flow_control,
	baud_nco
);

input			reset_n;
input			clk;

input			scl;
input			sda_in;
output			sda_out;
output			sda_oe;
input			i2c_addr;

// Default Host I/F Mode
`ifdef FPGA
input	[2:0]	def_mode;
output			loop;
`else
input	[1:0]	def_mode;
`endif

output	[1:0]	host_mode;
output			inactive_io;
output			unused_io;
output			miso_edge;
output	[3:0]	stop_bit;
output			flow_control;
output	[31:0]	baud_nco;


`define I2C_COUNT_WIDTH		3

reg		[`I2C_COUNT_WIDTH-1:0]	scl_count;
reg				scl_d1;
reg				scl_d2;
reg				scl_lpf;
reg				scl_lpf_prev;

reg		[`I2C_COUNT_WIDTH-1:0]	sda_count;
reg				sda_d1;
reg				sda_d2;
reg				sda_lpf;
reg				sda_lpf_prev;

wire			start_condition;
wire			stop_condition;
wire			scl_rising_edge;
wire			scl_falling_edge;

reg		[3:0]	bit_count;
reg		[7:0]	slave_addr;
reg		[7:0]	sub_addr;
wire	[7:0]	next_sub_addr;
reg		[7:0]	wdata;
reg		[7:0]	rdata;
wire	[7:0]	rd_addr;

reg		[2:0]	state;
reg		[2:0]	nstate;

reg				sda_out;
reg				sda_oe;
reg				rw;

wire	[7:0]	i2c_slave_addr;

reg		[1:0]	host_mode;
`ifdef FPGA
reg				loop;
`endif
reg				inactive_io;
reg				unused_io;
reg				miso_edge;
reg		[3:0]	stop_bit;
reg				flow_control;
reg		[31:0]	baud_nco;


`define ST_IDLE				3'b000
`define ST_SLAVE_ADDR		3'b001
`define ST_SLAVE_ADDR_ACK	3'b010
`define ST_SUB_ADDR			3'b011
`define ST_SUB_ADDR_ACK		3'b100
`define ST_DATA				3'b101
`define ST_DATA_ACK			3'b110

// start of i2c core logic

//synopsys translate_off
reg		[20*8:1]	state_str;
always @(state)
begin
	case (state)
		`ST_IDLE			: state_str = "IDLE";
		`ST_SLAVE_ADDR		: state_str = "SLAVE_ADDR";
		`ST_SLAVE_ADDR_ACK	: state_str = "SLAVE_ADDR_ACK";
		`ST_SUB_ADDR		: state_str = "SUB_ADDR";
		`ST_SUB_ADDR_ACK	: state_str = "SUB_ADDR_ACK";
		`ST_DATA			: state_str = "DATA";
		`ST_DATA_ACK		: state_str = "DATA_ACK";
		default				: state_str = "default";
	endcase
end
//synopsys translate_on

always @( * )
begin
	case (state)
		`ST_IDLE : begin
			if(start_condition)
				nstate = `ST_SLAVE_ADDR;
			else begin
				nstate = `ST_IDLE;
			end
		end

		`ST_SLAVE_ADDR : begin
			if(start_condition)
				nstate = `ST_SLAVE_ADDR;
			else if(stop_condition)
				nstate = `ST_IDLE;
			else if(bit_count == 4'h7 && scl_rising_edge) begin
				nstate = `ST_SLAVE_ADDR_ACK;
			end
			else begin
				nstate = `ST_SLAVE_ADDR;
			end
		end

		`ST_SLAVE_ADDR_ACK : begin
			if(start_condition)
				nstate = `ST_SLAVE_ADDR;
			else if(stop_condition)
				nstate = `ST_IDLE;
			else if(scl_rising_edge) begin
				if(slave_addr == i2c_slave_addr) begin
					if(rw)
						nstate = `ST_DATA;
					else begin
						nstate = `ST_SUB_ADDR;
					end
				end
				else begin
					nstate = `ST_IDLE;
				end
			end
			else begin
				nstate = `ST_SLAVE_ADDR_ACK;
			end
		end

		`ST_SUB_ADDR : begin
			if(start_condition)
				nstate = `ST_SLAVE_ADDR;
			else if(stop_condition)
				nstate = `ST_IDLE;
			else if(bit_count == 4'h7 && scl_rising_edge) begin
				nstate = `ST_SUB_ADDR_ACK;
			end
			else begin
				nstate = `ST_SUB_ADDR;
			end
		end

		`ST_SUB_ADDR_ACK : begin
			if(start_condition)
				nstate = `ST_SLAVE_ADDR;
			else if(stop_condition)
				nstate = `ST_IDLE;
			else if(scl_rising_edge) begin
				nstate = `ST_DATA;
			end
			else begin
				nstate = `ST_SUB_ADDR_ACK;
			end
		end

		`ST_DATA : begin
			if(start_condition)
				nstate = `ST_SLAVE_ADDR;
			else if(stop_condition)
				nstate = `ST_IDLE;
			else if(bit_count == 4'h7 && scl_rising_edge) begin
				nstate = `ST_DATA_ACK;
			end
			else begin
				nstate = `ST_DATA;
			end
		end

		`ST_DATA_ACK : begin
			if(start_condition)
				nstate = `ST_SLAVE_ADDR;
			else if(stop_condition)
				nstate = `ST_IDLE;
			else if(scl_rising_edge) begin
				if(rw == 1'b1 && sda_lpf == 1'b1)
					nstate = `ST_IDLE;
				else begin
					nstate = `ST_DATA;
				end
			end
			else begin
				nstate = `ST_DATA_ACK;
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
		state <= #1 `ST_SLAVE_ADDR;
	else begin
		state <= #1 nstate;
	end
end

// scl
always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		scl_count <= #1 {`I2C_COUNT_WIDTH{1'b0}};
	else begin
		if(scl_d1 != scl_d2) begin
			scl_count <= #1 {`I2C_COUNT_WIDTH{1'b0}};
		end
		else if(scl_count != {`I2C_COUNT_WIDTH{1'b1}}) begin
			scl_count <= #1 scl_count + 1'b1;
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		scl_d1 <= #1 1'b1;
	else begin
		scl_d1 <= #1 scl;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		scl_d2 <= #1 1'b1;
	else begin
		scl_d2 <= #1 scl_d1;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		scl_lpf <= #1 1'b1;
	else begin
		if(scl_d2 == scl_d1 && scl_count == {`I2C_COUNT_WIDTH{1'b1}}) begin
			scl_lpf <= #1 scl_d1;
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		scl_lpf_prev <= #1 1'b1;
	else begin
		scl_lpf_prev <= #1 scl_lpf;
	end
end

// sda
always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		sda_count <= #1 {`I2C_COUNT_WIDTH{1'b0}};
	else begin
		if(sda_d1 != sda_d2) begin
			sda_count <= #1 {`I2C_COUNT_WIDTH{1'b0}};
		end
		else if(sda_count != {`I2C_COUNT_WIDTH{1'b1}}) begin
			sda_count <= #1 sda_count + 1'b1;
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		sda_d1 <= #1 1'b1;
	else begin
		sda_d1 <= #1 sda_in;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		sda_d2 <= #1 1'b1;
	else begin
		sda_d2 <= #1 sda_d1;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		sda_lpf <= #1 1'b1;
	else begin
		if(sda_d2 == sda_d1 && sda_count == {`I2C_COUNT_WIDTH{1'b1}}) begin
			sda_lpf <= #1 sda_d1;
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		sda_lpf_prev <= #1 1'b1;
	else begin
		sda_lpf_prev <= #1 sda_lpf;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		bit_count <= #1 4'h0;
	else begin
		if(start_condition)
			bit_count <= #1 4'h0;
		else if(scl_rising_edge) begin
			if(bit_count == 4'h8)
				bit_count <= #1 4'h0;
			else begin
				bit_count <= #1 bit_count + 1'b1;
			end
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		slave_addr <= #1 8'h00;
	else begin
		if(scl_rising_edge && state == `ST_SLAVE_ADDR && bit_count != 4'h7) begin
//			slave_addr[3'b111 - bit_count[2:0]] <= #1 sda_lpf;
			slave_addr[7:2] <= #1 slave_addr[6:1];
			slave_addr[1] <= #1 sda_lpf;
			slave_addr[0] <= #1 1'b0;
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		sub_addr <= #1 8'h00;
	else begin
		if(scl_rising_edge) begin
			if(state == `ST_SUB_ADDR) begin
//				sub_addr[3'b111 - bit_count[2:0]] <= #1 sda_lpf;
				sub_addr[7:1] <= #1 sub_addr[6:0];
				sub_addr[0] <= #1 sda_lpf;
			end
			else if(state == `ST_DATA_ACK) begin
				sub_addr <= #1 sub_addr + 1'b1;
			end
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		wdata <= #1 8'h00;
	else begin
		if(scl_rising_edge) begin
			if(state == `ST_DATA) begin
//				wdata[3'b111 - bit_count[2:0]] <= #1 sda_lpf;
				wdata[7:1] <= #1 wdata[6:0];
				wdata[0] <= #1 sda_lpf;
			end
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		rw <= #1 1'b0;
	else begin
		if(scl_rising_edge) begin
			if(state == `ST_SLAVE_ADDR && bit_count == 4'h7) begin
				rw <= #1 sda_lpf;
			end
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		sda_oe <= #1 1'b0;
	else begin
		if(scl_falling_edge) begin
			if(state == `ST_SLAVE_ADDR_ACK && slave_addr == i2c_slave_addr)
				sda_oe <= #1 1'b1;
			else if(state == `ST_SUB_ADDR_ACK)
				sda_oe <= #1 1'b1;
			else if(state == `ST_DATA_ACK && rw == 1'b0)
				sda_oe <= #1 1'b1;
			else if(state == `ST_DATA && rw == 1'b1)
				sda_oe <= #1 1'b1;
			else begin
				sda_oe <= #1 1'b0;
			end
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		sda_out <= #1 1'b0;
	else begin
		if(scl_falling_edge) begin
			if(state == `ST_SLAVE_ADDR_ACK && slave_addr == i2c_slave_addr)
				sda_out <= #1 1'b0;
			else if(state == `ST_SUB_ADDR_ACK)
				sda_out <= #1 1'b0;
			else if(state == `ST_DATA_ACK && rw == 1'b0)
				sda_out <= #1 1'b0;
			else if(state == `ST_DATA && rw == 1'b1)
				sda_out <= #1 rdata[3'b111 - bit_count[2:0]];
			else begin
				sda_out <= #1 1'b1;
			end
		end
	end
end

// end of i2c core logic

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
`ifndef FPGA
		{host_mode} <= #1 {def_mode[0] == 1'b0 ? `HOST_MODE_SPI : def_mode[1:0]};
`elsif HOST_IF_SPI
		{loop, host_mode} <= #1 {def_mode[2], def_mode[0] == 1'b0 ? `HOST_MODE_SPI : def_mode[1:0]};
`elsif HOST_IF_SFIFO
		{loop, host_mode} <= #1 {def_mode[2], `HOST_MODE_SFIFO};
`else
		{loop, host_mode} <= #1 {def_mode[2], `HOST_MODE_UART};
`endif
	else begin
		if(scl_falling_edge && state == `ST_DATA_ACK && rw == 1'b0 && sub_addr == `I2C_ADDR_MODE) begin
`ifndef FPGA
			{host_mode} <= #1 {wdata[1:0]};
`else
	`ifdef HOST_IF_SPI
	`ifdef HOST_IF_UART
	`ifdef HOST_IF_SFIFO
			{loop, host_mode} <= #1 {wdata[4], wdata[1:0]};
	`endif
	`endif
	`endif
`endif
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		{miso_edge, unused_io, inactive_io} <= #1 {def_mode[1], 2'b00};
	else begin
		if(scl_falling_edge && state == `ST_DATA_ACK && rw == 1'b0 && sub_addr == `I2C_ADDR_IO_CONFIG) begin
			{miso_edge, unused_io, inactive_io} <= #1 wdata[2:0];
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		{flow_control, stop_bit} <= #1 0;
	else begin
		if(scl_falling_edge && state == `ST_DATA_ACK && rw == 1'b0 && sub_addr == `I2C_ADDR_UART_CONFIG) begin
			{flow_control, stop_bit} <= #1 wdata[4:0];
		end
	end
end

// baud_nco[7:0]
always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		baud_nco[7:0] <= #1 `DEF_BAUD_NCO_0;
	else begin
		if(scl_falling_edge && state == `ST_DATA_ACK && rw == 1'b0 && sub_addr == `I2C_ADDR_UART_BAUD_0) begin
			baud_nco[7:0] <= #1 wdata;
		end
	end
end

// baud_nco[15:8]
always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		baud_nco[15:8] <= #1 `DEF_BAUD_NCO_1;
	else begin
		if(scl_falling_edge && state == `ST_DATA_ACK && rw == 1'b0 && sub_addr == `I2C_ADDR_UART_BAUD_1) begin
			baud_nco[15:8] <= #1 wdata;
		end
	end
end

// baud_nco[23:16]
always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		baud_nco[23:16] <= #1 `DEF_BAUD_NCO_2;
	else begin
		if(scl_falling_edge && state == `ST_DATA_ACK && rw == 1'b0 && sub_addr == `I2C_ADDR_UART_BAUD_2) begin
			baud_nco[23:16] <= #1 wdata;
		end
	end
end

// baud_nco[31:24]
always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		baud_nco[31:24] <= #1 `DEF_BAUD_NCO_3;
	else begin
		if(scl_falling_edge && state == `ST_DATA_ACK && rw == 1'b0 && sub_addr == `I2C_ADDR_UART_BAUD_3) begin
			baud_nco[31:24] <= #1 wdata;
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if(!reset_n)
		rdata <= #1 8'h00;
	else begin
		if(scl_rising_edge) begin
			if((state == `ST_SLAVE_ADDR_ACK || state == `ST_DATA_ACK) && rw == 1'b1) begin
				case (rd_addr)
					`I2C_ADDR_VERSION				: rdata <= #1 `I2C_VERSION_VALUE;
`ifndef FPGA
					`I2C_ADDR_MODE					: rdata <= #1 {6'd0, host_mode};
`else
					`I2C_ADDR_MODE					: rdata <= #1 {3'd0, loop, 2'd0, host_mode};
`endif
					`I2C_ADDR_IO_CONFIG				: rdata <= #1 {5'd0, miso_edge, unused_io, inactive_io};
					`I2C_ADDR_UART_CONFIG			: rdata <= #1 {3'd0, flow_control, stop_bit};
					`I2C_ADDR_UART_BAUD_0			: rdata <= #1 baud_nco[ 7: 0];
					`I2C_ADDR_UART_BAUD_1			: rdata <= #1 baud_nco[15: 8];
					`I2C_ADDR_UART_BAUD_2			: rdata <= #1 baud_nco[23:16];
					`I2C_ADDR_UART_BAUD_3			: rdata <= #1 baud_nco[31:24];
					default							: rdata <= #1 8'd0;
				endcase
			end
		end
	end
end

assign i2c_slave_addr = `I2C_SLAVE_ADDR + {i2c_addr, 1'b0};

assign next_sub_addr    = sub_addr + 1'b1;
assign rd_addr	= (state == `ST_DATA_ACK) ? next_sub_addr : sub_addr;

assign start_condition  = sda_lpf_prev == 1'b1 && sda_lpf == 1'b0 && scl_lpf == 1'b1;
assign stop_condition   = sda_lpf_prev == 1'b0 && sda_lpf == 1'b1 && scl_lpf == 1'b1;
assign scl_rising_edge  = ~scl_lpf_prev &  scl_lpf;
assign scl_falling_edge =  scl_lpf_prev & ~scl_lpf;

endmodule
