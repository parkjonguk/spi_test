`include "define.v"
`include "timescale.v"

module host_ahb_slave(
	reset_n,
	clk,

	s_ahb_htrans,
	s_ahb_hwrite,
	s_ahb_hsize,
	s_ahb_haddr,
	s_ahb_hwdata,
	s_ahb_hrdata,
	s_ahb_hready,
	s_ahb_hresp,
	s_ahb_hburst,

	tx_fifo_rd_en,
	tx_fifo_dout,
	tx_fifo_empty
);

input			reset_n;
input			clk;

input	[1:0]	s_ahb_htrans;
input			s_ahb_hwrite;
input	[2:0]	s_ahb_hsize;
input	[31:0]	s_ahb_haddr;
input	[31:0]	s_ahb_hwdata;
output	[31:0]	s_ahb_hrdata;
output			s_ahb_hready;
`ifdef AHB_LITE
output			s_ahb_hresp;
`else
output	[1:0]	s_ahb_hresp;
`endif
input	[2:0]	s_ahb_hburst;

input			tx_fifo_rd_en;
output	[7:0]	tx_fifo_dout;
output			tx_fifo_empty;

reg				ahb_slave_wr_req;

reg				rx_fifo_rd_en_d1;

reg		[15:0]	data_len;
reg		[16:0]	data_idx;
wire	[16:0]	data_hdr_len;

wire			ahb_fifo_wr_en;
wire	[31:0]	ahb_fifo_din;
wire			ahb_fifo_rd_en;
reg				ahb_fifo_rd_en_d1;
reg				ahb_fifo_rd_en_valid;
wire	[31:0]	ahb_fifo_dout_f;
wire	[31:0]	ahb_fifo_dout;
wire			ahb_fifo_full_f;
wire			ahb_fifo_full;
wire			ahb_fifo_empty_f;
wire			ahb_fifo_empty;

// tx_fifo
wire			tx_fifo_wr_en;
wire	[7:0]	tx_fifo_din;
wire	[7:0]	tx_fifo_dout_f;
wire			tx_fifo_full_f;
wire			tx_fifo_full;

// TX = Host Read (SoC -> Host)
fifo_32x16 u_ahb_fifo_32x16(
	.clk(clk),
	.reset(~reset_n),
	.din(ahb_fifo_din),
	.wr_en(ahb_fifo_wr_en),
	.rd_en(ahb_fifo_rd_en),
	.dout(ahb_fifo_dout_f),
	.full(ahb_fifo_full_f),
	.empty(ahb_fifo_empty_f)
);
assign #1 ahb_fifo_full  = ahb_fifo_full_f;
assign #1 ahb_fifo_empty = ahb_fifo_empty_f;
assign #1 ahb_fifo_dout  = ahb_fifo_dout_f;

fifo_8x16 u_host_fifo_8x16(
	.clk(clk),
	.reset(!reset_n),
	.din(tx_fifo_din),
	.wr_en(tx_fifo_wr_en),
	.rd_en(tx_fifo_rd_en),
	.dout(tx_fifo_dout_f),
	.full(tx_fifo_full_f),
	.empty(tx_fifo_empty_f)
);

assign #1 tx_fifo_full  = tx_fifo_full_f;
assign #1 tx_fifo_empty = tx_fifo_empty_f;
assign #1 tx_fifo_dout  = tx_fifo_dout_f;


`define ST_SOF				1'd0
`define ST_DATA				1'd1

reg		[0:0]	state;
reg		[0:0]	nstate;

//synopsys translate_off
reg		[30*8:1]	state_str;
always @(state)
begin
	case (state)
		`ST_SOF				: state_str = "ST_SOF";
		`ST_DATA			: state_str = "ST_DATA";
		default				: state_str = "default";
	endcase
end
//synopsys translate_on

always @( * )
begin
	case (state)
		`ST_SOF :  begin
			if(ahb_fifo_rd_en_d1 && ahb_fifo_dout[15:8] == `SOF2 && ahb_fifo_dout[7:0] == `SOF1)
				nstate = `ST_DATA;
			else begin
				nstate = `ST_SOF;
			end
		end
		
		`ST_DATA :  begin
			if(data_hdr_len == data_idx)
				nstate = `ST_SOF;
			else begin
				nstate = `ST_DATA;
			end
		end
		
		default : begin
			nstate = `ST_SOF;
		end

	endcase
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n)
		state <= `ST_SOF;
	else begin
		state <= #1 nstate;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n)
		ahb_slave_wr_req <= #1 0;
	else begin
`ifdef AMBA_2V0_Figure_3_3_Simple_transfer_Address_Phase_Err_On_HREADY_not_valid
		if((s_ahb_htrans == `AHB_NONSEQ || s_ahb_htrans == `AHB_SEQ) && s_ahb_hwrite)
`else
		if((s_ahb_htrans == `AHB_NONSEQ || s_ahb_htrans == `AHB_SEQ) && s_ahb_hwrite && s_ahb_hready)
`endif
			ahb_slave_wr_req <= #1 1;
		else if(ahb_slave_wr_req && s_ahb_htrans != `AHB_BUSY && s_ahb_hready) begin
			ahb_slave_wr_req <= #1 0;
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		ahb_fifo_rd_en_d1 <= #1 0;
	else begin
		ahb_fifo_rd_en_d1 <= #1 ahb_fifo_rd_en;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		ahb_fifo_rd_en_valid <= #1 0;
	else begin
		if(ahb_fifo_rd_en)
			ahb_fifo_rd_en_valid <= #1 1'b1;
		else if((tx_fifo_wr_en && data_idx[1:0] == 2'd3) || (state == `ST_SOF && ahb_fifo_rd_en_d1 && (ahb_fifo_dout[7:0] != `SOF1 || ahb_fifo_dout[15:8] != `SOF2))) begin
			ahb_fifo_rd_en_valid <= #1 1'b0;
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		data_len <= #1 0;
	else begin
		if(state == `ST_SOF && nstate == `ST_DATA) begin
			data_len <= #1 ahb_fifo_dout[31:16];
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		data_idx <= #1 0;
	else begin
		if(nstate == `ST_SOF)
			data_idx <= #1 0;
		else if(state == `ST_SOF && nstate == `ST_DATA)
			data_idx <= #1 1;
		else if(tx_fifo_wr_en) begin
			data_idx <= #1 data_idx + 1;
		end
	end
end

assign s_ahb_hrdata = 32'hDEAD_BEEF;
assign s_ahb_hready = ~ahb_fifo_full;
assign s_ahb_hresp = 0;

assign ahb_fifo_wr_en = ~ahb_fifo_full && ahb_slave_wr_req && s_ahb_htrans != `AHB_BUSY;
assign ahb_fifo_din = s_ahb_hwdata;

assign ahb_fifo_rd_en = ~ahb_fifo_empty && ~ahb_fifo_rd_en_d1 && (state == `ST_SOF || (state == `ST_DATA && (~ahb_fifo_rd_en_valid || (tx_fifo_wr_en && data_idx[1:0] == 2'd3))));

assign tx_fifo_wr_en = ~tx_fifo_full && nstate == `ST_DATA && ahb_fifo_rd_en_valid;
assign tx_fifo_din = (data_idx[1:0] == 2'd0 ? ahb_fifo_dout[7:0] :
					 (data_idx[1:0] == 2'd1 ? ahb_fifo_dout[15:8] :
					 (data_idx[1:0] == 2'd2 ? ahb_fifo_dout[23:16] :
					  ahb_fifo_dout[31:24])));

assign data_hdr_len = data_len + 3'd4;

`ifdef MODELSIM
	`undef USE_CHIPSCOPE
`endif

`ifdef USE_CHIPSCOPE
/*
ila_ahb_slave u_ila_ahb_slave(
	.clk(clk),
	.probe0(s_ahb_htrans),
	.probe1(s_ahb_hwrite),
	.probe2(s_ahb_haddr),
	.probe3(s_ahb_hwdata),
	.probe4(s_ahb_hready),
	.probe5(tx_fifo_wr_en),
	.probe6(tx_fifo_dout),
	.probe7(tx_fifo_full),
	.probe8(ahb_fifo_wr_en),
	.probe9(ahb_fifo_full),
	.probe10(ahb_fifo_rd_en),
	.probe11(ahb_fifo_dout),
	.probe12(ahb_fifo_empty),
	.probe13(state),
	.probe14(nstate),
	.probe15(ahb_fifo_rd_en_d1),
	.probe16(ahb_fifo_rd_en_valid),
	.probe17(data_len),
	.probe18(ahb_slave_wr_req)
);
*/
`endif

endmodule
