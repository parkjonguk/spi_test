module l2_ahb (/*AUTOARG*/
   // Outputs
   m_ahb_htrans, m_ahb_hsize, m_ahb_hburst, m_ahb_hwrite, m_ahb_haddr,
   m_ahb_hwdata, s_ahb_hrdata, s_ahb_hready, s_ahb_hresp, tx_fifo_rd_en,
   rx_fifo_wr_en, rx_fifo_din,
   // Inputs
   rst_n, clk, pin_l2_clr, m_ahb_hrdata, m_ahb_hready, m_ahb_hresp,
   s_ahb_htrans, s_ahb_hsize, s_ahb_hburst, s_ahb_hwrite, s_ahb_haddr,
   s_ahb_hwdata, tx_fifo_empty, tx_fifo_dout, rx_fifo_full
   ) ;
   input  rst_n;
   input  clk;
   input  pin_l2_clr;

   output [1:0]    m_ahb_htrans;
   output [2:0]    m_ahb_hsize;
   output [2:0]    m_ahb_hburst;
   output          m_ahb_hwrite;
   output [31:0]   m_ahb_haddr;
   output [31:0]   m_ahb_hwdata;
   input [31:0]    m_ahb_hrdata;
   input           m_ahb_hready;
   input [1:0]     m_ahb_hresp;

   input [1:0]     s_ahb_htrans;
   input [2:0]     s_ahb_hsize;
   input [2:0]     s_ahb_hburst;
   input           s_ahb_hwrite;
   input [31:0]    s_ahb_haddr;
   input [31:0]    s_ahb_hwdata;
   output [31:0]   s_ahb_hrdata;
   output          s_ahb_hready;
   output [1:0]    s_ahb_hresp;

   input           tx_fifo_empty;
   input [31:0]    tx_fifo_dout;
   output          tx_fifo_rd_en;

   input           rx_fifo_full;
   output          rx_fifo_wr_en;
   output [31:0]   rx_fifo_din;

   localparam HSIZE_BIT32 = 3'd2;
   localparam AHB_IDLE    = 2'b00;
   localparam AHB_SEQ     = 2'b11;
   localparam AHB_NONSEQ  = 2'b10;

   reg             rx_fifo_req;

   // AHB Slave Control
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         rx_fifo_req <= 0;
      end else begin
         if(pin_l2_clr) begin
            rx_fifo_req <= 0;
         end else if((s_ahb_htrans == AHB_NONSEQ || s_ahb_htrans == AHB_SEQ) && s_ahb_hwrite)
           rx_fifo_req <= 1;
         else if(rx_fifo_req && s_ahb_hready) begin
            rx_fifo_req <= 0;
         end
      end
   end

   assign s_ahb_hrdata   = 32'd0;
   assign s_ahb_hready   = ~rx_fifo_full;
   assign s_ahb_hresp    = 0;
   assign rx_fifo_din    = s_ahb_hwdata;
   assign rx_fifo_wr_en  = ~rx_fifo_full && rx_fifo_req;

   // AHB Master Control
   assign m_ahb_htrans   = (m_ahb_hready && ~tx_fifo_empty) ? AHB_NONSEQ : AHB_IDLE;
   assign m_ahb_hsize    = HSIZE_BIT32;
   assign m_ahb_hburst   = 0;
   assign m_ahb_hwrite   = m_ahb_htrans == AHB_NONSEQ || m_ahb_htrans == AHB_SEQ; // CHECK
   assign m_ahb_haddr    = 32'h80000000;
   assign m_ahb_hwdata   = tx_fifo_dout;
   assign tx_fifo_rd_en  = ~tx_fifo_empty && m_ahb_hready;
endmodule // l2_ahb
