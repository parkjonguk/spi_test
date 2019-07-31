module l2_tx (/*AUTOARG*/
   // Outputs
   tx_fifo_wr, tx_fifo_din, l3_cmd_done, timer_stop, l3_rd_rdy,
   // Inputs
   clk, rst_n, pin_l2_clr, tx_fifo_full, l3_en, l3_extend, sw0, sw1, resp_err,
   resp_done, l3_rd, l3_rd_vld
   ) ;
   /* I/O Information */
   // System Input
   input          clk, rst_n;
   input          pin_l2_clr;
   // TX FIFO Control
   input          tx_fifo_full;
   output         tx_fifo_wr;
   output [31:0]  tx_fifo_din;
   // L3 OP
   input          l3_en;
   input  [15:0]  l3_extend;
   output         l3_cmd_done;
   output         timer_stop;

   input [7:0]    sw0, sw1;
   input          resp_err;
   input          resp_done;

   input  [31:0]  l3_rd;
   input          l3_rd_vld;
   output         l3_rd_rdy;

   reg            tx_fifo_wr;
   reg [31:0]     tx_fifo_din;
   reg            l3_cmd_done;
   reg            l3_rd_rdy;
   reg            timer_stop;


   wire [15:0]    l2_size_i;
   assign l2_size_i = l3_extend + 16'd2;

   reg [15:0]     l2_size;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         l2_size <= 16'd0;
      end else begin
         if(l3_en) begin
            l2_size <= l2_size_i;
         end else if (l3_cmd_done) begin
            l2_size <= 16'd0;
         end
      end
   end

   reg   [15:0] l3_size;
   wire [15:0]   l3_size_nxt;
   wire [15:0]   l3_size_sub;
   wire          l3_size_lst;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         l3_size <= 16'd0;
      end else begin
         if(l3_en) begin
            l3_size <= l3_extend;
         end else if (l3_rd_vld & l3_rd_rdy) begin
            l3_size <= l3_size_nxt;
         end
      end
   end

   wire   flg_l3_done;

   assign l3_size_sub  = l3_size - 16'd4;
   assign l3_size_lst  = (l3_size <  16'd5) ? 1 : 0;
   assign l3_size_nxt  = l3_size_lst ? 16'd0 : l3_size_sub;
   assign flg_l3_done  = (l3_size == 16'd0) ? 1 : 0;



   wire [31:0]   msk;
   wire [31:0]   msk_rd;
   wire [47:0]   sw;
   wire [47:0]   sw_rsh;
   wire [47:0]   rd_lst;
   wire          l2_fin;
   assign msk       = {32{1'b1}} >> {l3_size[2:0], 3'd0};
   assign msk_rd    = l3_rd & (~msk);
   assign sw        = {sw0, sw1, 32'd0};
   assign sw_rsh    = sw >> {l3_size[2:0], 3'd0};
   assign rd_lst    = {msk_rd, 16'd0} | sw_rsh;
   assign l2_fin    = (l3_size[2:0] < 3'd3) ? 1 : 0;

   wire [31:0]   buf_nxt;
   wire [15:0]   tmp_nxt;
   wire          l2d_nxt;
   assign buf_nxt   = l3_size_lst ? rd_lst[47:16] : l3_rd;
   assign tmp_nxt   = l3_size_lst ? rd_lst[15:0]  : 16'd0;
   assign l2d_nxt   = l3_size_lst ? l2_fin : 1'b0;


   reg [31:0]    rd_buf;
   reg [15:0]    rd_tmp;
   reg           flg_l2_done;
   reg           tx_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         rd_buf  <= 32'd0;
         rd_tmp  <= 16'd0;
         flg_l2_done <= 1'b0;
      end else begin
         if(l3_en | l3_cmd_done) begin
            rd_buf  <= 32'd0;
            rd_tmp  <= 16'd0;
            flg_l2_done <= 1'b0;
         end else if(l3_rd_vld & l3_rd_rdy) begin
            rd_buf  <= buf_nxt;
            rd_tmp  <= tmp_nxt;
            flg_l2_done <= l2d_nxt;
         end else if(tx_nxt) begin
            rd_buf  <= {rd_tmp, 16'd0};
            rd_tmp  <= 16'd0;
            flg_l2_done <= 1'b1;
         end
      end
   end


   wire   [31:0] atoi;
   assign atoi    = {rd_buf[7:0], rd_buf[15:8], rd_buf[23:16], rd_buf[31:24]};

   reg [1:0]     tx_sel;
   always @ (*) begin
      case (tx_sel)
        2'b00 : tx_fifo_din = 32'h000255AA;
        2'b01 : tx_fifo_din = {16'd0, sw1, sw0};
        2'b10 : tx_fifo_din = {l2_size, 16'h55AA};
        2'b11 : tx_fifo_din = atoi;
      endcase // case (tx_sel)
   end


   localparam L2_IDLE       = 8'b00000001;
   localparam L3_RESP_WAIT  = 8'b00000010;
   localparam L3_RESP_WR    = 8'b00000100;
   localparam L3_RD_WAIT    = 8'b00001000;
   localparam L3_TX_HEAD    = 8'b00010000;
   localparam L3_TXD        = 8'b00100000;
   localparam L3_RDD        = 8'b01000000;
   localparam L2_DONE       = 8'b10000000;

   reg   [7:0] state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= L2_IDLE;
      end else begin
         if(pin_l2_clr) begin
            state <= L2_IDLE;
         end else begin
            state <= state_nxt;
         end
      end
   end

   always @ (*) begin
      state_nxt     = state;
      tx_sel        = 2'b00;
      tx_fifo_wr    = 0;
      l3_rd_rdy     = 0;
      tx_nxt        = 0;
      l3_cmd_done   = 0;
      timer_stop    = 0;
      case (state)
        L2_IDLE     : begin
           if(l3_en) begin
              if(l3_extend == 16'd0) begin
                 state_nxt = L3_RESP_WAIT;
              end else begin
                 state_nxt = L3_RD_WAIT;
              end
           end
        end
        L3_RESP_WAIT  : begin
           tx_sel       = 2'b00;
           if((resp_done | resp_err) & (!tx_fifo_full)) begin
              tx_fifo_wr   = 1;
              state_nxt    = L3_RESP_WR;
           end
        end
        L3_RESP_WR    : begin
           tx_sel       = 2'b01;
           if(!tx_fifo_full) begin
              tx_fifo_wr   = 1;
              state_nxt    = L2_DONE;
           end
        end
        L3_RD_WAIT    : begin
           l3_rd_rdy  = 1;
           if(resp_err | resp_done) begin
              state_nxt  = L3_RESP_WAIT;
           end else if(l3_rd_vld) begin
              timer_stop = 1;
              state_nxt  = L3_TX_HEAD;
           end
        end
        L3_TX_HEAD    : begin
           tx_sel      = 2'b10;
           if(!tx_fifo_full) begin
              tx_fifo_wr   = 1;
              state_nxt    = L3_TXD;
           end
        end
        L3_TXD         : begin
           tx_sel      = 2'b11;
           if(!tx_fifo_full) begin
              tx_fifo_wr   = 1;
              state_nxt    = L3_RDD;
           end
        end
        L3_RDD         : begin
           if(!flg_l3_done) begin
              l3_rd_rdy  = 1;
           end
           if(flg_l3_done) begin
              if(flg_l2_done) begin
                 state_nxt  = L2_DONE;
              end else begin
                 state_nxt  = L3_TXD;
                 tx_nxt     = 1;
              end
           end else if(l3_rd_vld) begin
              state_nxt   = L3_TXD;
           end
        end
        L2_DONE          : begin
           l3_cmd_done   = 1;
           state_nxt     = L2_IDLE;
        end
      endcase // case (state)
   end
endmodule // l2_tx
