`include "define.v"
`include "timescale.v"

module host_ahb_master(
	reset_n,
	clk,

`ifdef HOST_IRQ_SUPPORT
	host_irq_en,
	host_irq_clr,
	host_irq,
`endif

	m_ahb_htrans,
	m_ahb_hwrite,
	m_ahb_hsize,
	m_ahb_hburst,
	m_ahb_haddr,
	m_ahb_hwdata,
	m_ahb_hrdata,
	m_ahb_hready,
	m_ahb_hresp,

	rx_fifo_rd_en,
	rx_fifo_din,
	rx_fifo_empty
);

input			reset_n;
input			clk;

`ifdef HOST_IRQ_SUPPORT
input			host_irq_en;
input			host_irq_clr;
output			host_irq;
`endif

output	[1:0]	m_ahb_htrans;
output			m_ahb_hwrite;
output	[2:0]	m_ahb_hsize;
output	[2:0]	m_ahb_hburst;
output	[31:0]	m_ahb_haddr;
output	[31:0]	m_ahb_hwdata;
input	[31:0]	m_ahb_hrdata;
input			m_ahb_hready;
`ifdef AHB_LITE
input			m_ahb_hresp;
`else
input	[1:0]	m_ahb_hresp;
`endif

output			rx_fifo_rd_en;
input	[7:0]	rx_fifo_din;
input			rx_fifo_empty;


reg				host_irq_req;
`ifdef HOST_IRQ_SUPPORT
reg				host_irq;
`endif

reg				rx_fifo_rd_en_d1;

reg		[15:0]	data_len;
reg		[15:0]	data_idx;

// ahb_fifo -> AHB Write
wire			addr_phase;
reg				data_phase;
reg		[13:0]	ahb_addr_idx;
wire	[31:0]	target_ahb_slave_addr;
wire	[31:0]	m_ahb_hwdata;

reg				ahb_fifo_wr_req;

wire			ahb_fifo_wr_en;
reg				ahb_fifo_wr_en_d1;
reg		[31:0]	ahb_fifo_din;
wire			ahb_fifo_rd_en;
wire	[31:0]	ahb_fifo_dout_f;
wire	[31:0]	ahb_fifo_dout;
wire			ahb_fifo_full_f;
wire			ahb_fifo_full;
wire			ahb_fifo_empty_f;
wire			ahb_fifo_empty;

// RX = Host Write (Host -> SoC)
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


`define ST_SOF1				3'd0
`define ST_SOF2				3'd1
`define ST_LEN1				3'd2
`define ST_LEN2				3'd3
`define ST_DATA				3'd4

reg		[2:0]	in_state;
reg		[2:0]	in_nstate;

//synopsys translate_off
reg		[30*8:1]	in_state_str;
always @(in_state)
begin
	case (in_state)
		`ST_SOF1			: in_state_str = "ST_SOF1";
		`ST_SOF2			: in_state_str = "ST_SOF2";
		`ST_LEN1			: in_state_str = "ST_LEN1";
		`ST_LEN2			: in_state_str = "ST_LEN2";
		`ST_DATA			: in_state_str = "ST_DATA";
		default				: in_state_str = "default";
	endcase
end
//synopsys translate_on

always @( * )
begin
	case (in_state)
		`ST_SOF1 :  begin
			if(rx_fifo_rd_en_d1 && rx_fifo_din == `SOF1)
				in_nstate = `ST_SOF2;
			else begin
				in_nstate = `ST_SOF1;
			end
		end

		`ST_SOF2 :  begin
			if(rx_fifo_rd_en_d1) begin
				if(rx_fifo_din == `SOF2)
					in_nstate = `ST_LEN1;
				else begin
					in_nstate = `ST_SOF1;
				end
			end
			else begin
				in_nstate = `ST_SOF2;
			end
		end

		`ST_LEN1 :  begin
			if(rx_fifo_rd_en_d1)
				in_nstate = `ST_LEN2;
			else begin
				in_nstate = `ST_LEN1;
			end
		end

		`ST_LEN2 :  begin
			if(rx_fifo_rd_en_d1) begin
				if(data_len[7:0] == 0 && rx_fifo_din == 0)	// data_len == 0
					in_nstate = `ST_SOF1;
				else begin
					in_nstate = `ST_DATA;
				end
			end
			else begin
				in_nstate = `ST_LEN2;
			end
		end

		`ST_DATA :  begin
			if(rx_fifo_rd_en_d1) begin
				if(data_len == (data_idx + 1'b1))
					in_nstate = `ST_SOF1;
				else begin
					in_nstate = `ST_DATA;
				end
			end
			else begin
				in_nstate = `ST_DATA;
			end
		end

		default : begin
			in_nstate = `ST_SOF1;
		end

	endcase
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n)
		in_state <= `ST_SOF1;
	else begin
		in_state <= #1 in_nstate;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n)
		rx_fifo_rd_en_d1 <= #1 0;
	else begin
		rx_fifo_rd_en_d1 <= #1 rx_fifo_rd_en;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		data_len <= #1 0;
	else begin
		if(rx_fifo_rd_en_d1) begin
			if(in_state == `ST_LEN1) begin
				data_len[7:0] <= #1 rx_fifo_din;
			end

			if(in_state == `ST_LEN2) begin
				data_len[15:8] <= #1 rx_fifo_din;
			end
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		data_idx <= #1 0;
	else begin
		if(rx_fifo_rd_en_d1) begin
			if(in_state != `ST_DATA && in_nstate == `ST_DATA)
				data_idx <= #1 0;
			else if(in_state == `ST_DATA) begin
				data_idx <= #1 data_idx + 1;
			end
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		ahb_fifo_wr_req <= #1 0;
	else begin
		if(rx_fifo_rd_en_d1 && (in_state == `ST_LEN2 || (in_state == `ST_DATA && (in_nstate == `ST_SOF1 || data_idx[1:0] == 3))))
			ahb_fifo_wr_req <= #1 1;
		else if(ahb_fifo_wr_req && ahb_fifo_wr_en) begin
			ahb_fifo_wr_req <= #1 0;
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		ahb_fifo_din <= #1 0;
	else begin
		if(rx_fifo_rd_en_d1) begin
			if(in_state == `ST_SOF1 || (in_state == `ST_DATA && data_idx[1:0] == 0)) begin
				ahb_fifo_din[7:0] <= #1 rx_fifo_din;
			end

			if(in_state == `ST_SOF2 || (in_state == `ST_DATA && data_idx[1:0] == 1)) begin
				ahb_fifo_din[15:8] <= #1 rx_fifo_din;
			end

			if(in_state == `ST_LEN1 || (in_state == `ST_DATA && data_idx[1:0] == 2)) begin
				ahb_fifo_din[23:16] <= #1 rx_fifo_din;
			end

			if(in_state == `ST_LEN2 || (in_state == `ST_DATA && data_idx[1:0] == 3)) begin
				ahb_fifo_din[31:24] <= #1 rx_fifo_din;
			end
		end
	end
end

// out_side
reg				ahb_fifo_rd_en_d1;
reg		[15:0]	ahb_data_len;
reg		[15:0]	ahb_data_idx;

reg		[2:0]	out_state;
reg		[2:0]	out_nstate;

//synopsys translate_off
reg		[30*8:1]	out_state_str;
always @(out_state)
begin
	case (out_state)
		`ST_SOF1			: out_state_str = "ST_SOF1";
		`ST_SOF2			: out_state_str = "ST_SOF2";
		`ST_LEN1			: out_state_str = "ST_LEN1";
		`ST_LEN2			: out_state_str = "ST_LEN2";
		`ST_DATA			: out_state_str = "ST_DATA";
		default				: out_state_str = "default";
	endcase
end
//synopsys translate_on

always @( * )
begin
	case (out_state)
		`ST_SOF1 :  begin
			if(ahb_fifo_rd_en_d1 && ahb_fifo_dout[7:0] == `SOF1 && ahb_fifo_dout[15:8] == `SOF2 && ahb_fifo_dout[31:16] != 0)
				out_nstate = `ST_DATA;
			else begin
				out_nstate = `ST_SOF1;
			end
		end

		`ST_DATA :  begin
			if(ahb_fifo_rd_en_d1) begin
				if((ahb_data_idx + 3'd4) >= ahb_data_len)
					out_nstate = `ST_SOF1;
				else begin
					out_nstate = `ST_DATA;
				end
			end
			else begin
				out_nstate = `ST_DATA;
			end
		end

		default : begin
			out_nstate = `ST_SOF1;
		end

	endcase
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n)
		out_state <= `ST_SOF1;
	else begin
		out_state <= #1 out_nstate;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n)
		ahb_fifo_rd_en_d1 <= #1 0;
	else begin
		ahb_fifo_rd_en_d1 <= #1 ahb_fifo_rd_en;
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		ahb_data_len <= #1 0;
	else begin
		if(host_irq_req)
			ahb_data_len <= #1 0;
		else if(ahb_fifo_rd_en_d1) begin
			if(out_state == `ST_SOF1 && out_nstate == `ST_DATA) begin
				ahb_data_len <= #1 ahb_fifo_dout[31:16];
			end
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		ahb_data_idx <= #1 0;
	else begin
		if(host_irq_req)
			ahb_data_idx <= #1 0;
		else if(ahb_fifo_rd_en_d1) begin
			if(out_state != `ST_DATA && out_nstate == `ST_DATA)
				ahb_data_idx <= #1 0;
			else if(out_state == `ST_DATA) begin
				ahb_data_idx <= #1 ahb_data_idx + 3'd4;
			end
		end
	end
end

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n)
		data_phase <= #1 0;
	else begin
		if(addr_phase)
			data_phase <= #1 1;
		else if(m_ahb_hready) begin
			data_phase <= #1 0;
		end
	end
end

`ifdef AHB_ADDR_INC
always @(negedge reset_n or posedge clk)
begin
	if (!reset_n )
		ahb_addr_idx <= #1 0;
	else begin
		if(host_irq_req)
			ahb_addr_idx <= #1 0;
		else if(addr_phase) begin
			ahb_addr_idx <= #1 ahb_addr_idx + 1;
		end
	end
end
`endif

always @(negedge reset_n or posedge clk)
begin
	if (!reset_n)
		host_irq_req <= #1 0;
	else begin
		if(host_irq_req == 0) begin
			if((out_state == `ST_SOF1 && ahb_fifo_rd_en_d1 && ahb_fifo_dout[31:16] == 0) || (out_state == `ST_DATA && out_nstate == `ST_SOF1)) begin
				host_irq_req <= #1 1;
			end
		end
`ifdef HOST_IRQ_SUPPORT
		else if(~host_irq_en || host_irq) begin
`else
		else begin
`endif
			host_irq_req <= #1 0;
		end
	end
end

`ifdef HOST_IRQ_SUPPORT
always @(negedge reset_n or posedge clk)
begin
	if (!reset_n)
		host_irq <= #1 0;
	else begin
		if(host_irq_en) begin
			if(host_irq == 0) begin
				if(host_irq_req && m_ahb_hready) begin
					host_irq <= #1 1;
				end
			end
			else if(host_irq_clr) begin
				host_irq <= #1 0;
			end
		end
		else begin
			host_irq <= #1 0;
		end
	end
end
`endif


assign rx_fifo_rd_en = ~rx_fifo_empty && ~ahb_fifo_full && (out_state != `ST_SOF1 || m_ahb_hready);

assign ahb_fifo_wr_en = ~ahb_fifo_full && ahb_fifo_wr_req;
assign ahb_fifo_rd_en = ~ahb_fifo_empty && (~data_phase || m_ahb_hready);
assign addr_phase = ahb_fifo_rd_en;

assign m_ahb_htrans = addr_phase ? `AHB_NONSEQ : `AHB_IDLE;

`ifdef MODELSIM
assign m_ahb_hwrite = m_ahb_htrans == `AHB_NONSEQ || m_ahb_htrans == `AHB_SEQ;
assign m_ahb_haddr  = m_ahb_htrans == `AHB_NONSEQ || m_ahb_htrans == `AHB_SEQ ? target_ahb_slave_addr : 32'd0;
assign m_ahb_hwdata = data_phase ? ahb_fifo_dout : 32'd0;
`else
assign m_ahb_hwrite = 1;
assign m_ahb_haddr  = target_ahb_slave_addr;
assign m_ahb_hwdata = ahb_fifo_dout;
`endif

assign m_ahb_hsize = `HSIZE_BIT32;
assign m_ahb_hburst = 0;

`ifdef AHB_ADDR_INC
assign target_ahb_slave_addr = `AHB_ADDR_CRYPTO + {ahb_addr_idx, 2'd0};
`else
assign target_ahb_slave_addr = `AHB_ADDR_CRYPTO;
`endif


`ifdef MODELSIM
	`undef USE_CHIPSCOPE
`endif

`ifdef USE_CHIPSCOPE
/*
ila_ahb_master u_ila_ahb_master(
	.clk(clk),
	.probe0(m_ahb_htrans),
	.probe1(m_ahb_hwrite),
	.probe2(m_ahb_haddr),
	.probe3(m_ahb_hwdata),
	.probe4(m_ahb_hready),
	.probe5(rx_fifo_rd_en),
	.probe6(rx_fifo_din),
	.probe7(rx_fifo_empty),
	.probe8(state),
	.probe9(nstate),
	.probe10(data_idx),
	.probe11(rx_fifo_rd_en_d1),
	.probe12(addr_phase),
	.probe13(data_phase),
	.probe14(ahb_fifo_wr_en),
	.probe15(ahb_fifo_din),
	.probe16(ahb_fifo_full),
	.probe17(ahb_fifo_rd_en),
	.probe18(ahb_fifo_dout),
	.probe19(ahb_fifo_empty)
);
*/
`endif

endmodule
