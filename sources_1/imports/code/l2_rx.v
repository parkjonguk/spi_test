module l2_rx (/*AUTOARG*/
   // Outputs
   rx_fifo_rd, l3_sel, l3_id, l3_op, l3_size, l3_extend, l3_en, l3_wd,
   l3_wd_vld,
   // Inputs
   clk, rst_n, pin_l2_clr, pin_l2_loop, rx_fifo_empty, rx_fifo_dout,
   l3_cmd_done, l3_wd_rdy
   ) ;
   /* I/O Information */
   // System Input
   input          clk, rst_n;
   input          pin_l2_clr;
   input          pin_l2_loop;
   // RX FIFO Control
   input          rx_fifo_empty;
   input [31:0]   rx_fifo_dout;
   output         rx_fifo_rd;
   // L3 OP
   output [3:0]   l3_sel;
   output [3:0]   l3_id;
   output [7:0]   l3_op;
   output [15:0]  l3_size;
   output [15:0]  l3_extend;
   output         l3_en;
   // L3 Response
   input          l3_cmd_done;

   // WR CH DIO
   output [31:0]  l3_wd;
   output         l3_wd_vld;
   input          l3_wd_rdy;

   /* OUTPUT TYPE */
   reg [3:0]      l3_sel;
   reg [3:0]      l3_id;
   reg [7:0]      l3_op;
   reg [15:0]     l3_size;
   reg [15:0]     l3_extend;
   reg            l3_en;

   reg [31:0]     l3_wd;
   reg            l3_wd_vld;
   reg            rx_fifo_rd;

   /* L2 */
   reg            l2_init;
   reg [15:0]     l2_size;
   wire [15:0]    l2_sub, l2_nxt;
   assign         l2_sub  = l2_size - 16'd4;
   assign         l2_nxt  = (l2_size < 16'd4) ? 16'd0 : l2_sub;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         l2_size <= 16'd0;
      end else begin
         if(l2_init) begin
            l2_size <= rx_fifo_dout[31:16];
         end else if(rx_fifo_rd) begin
            l2_size <= l2_nxt;
         end
      end
   end

   wire           flg_l2_eq_0B;
   wire           flg_l2_lt_4B;
   wire           flg_l2_done;

   assign flg_l2_eq_0B  = (rx_fifo_dout[31:16] == 16'd0) ? 1'b1 : 1'b0;
   assign flg_l2_lt_4B  = (rx_fifo_dout[31:16] <  16'd4) ? 1'b1 : 1'b0;
   assign flg_l2_done   = (l2_size == 16'd0);


   /* L3 */
   reg            l3_init;
   wire [15:0]    l3_size_i;
   assign         l3_size_i = l2_size;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         l3_sel    <= 4'd0;
         l3_id     <= 4'd0;
         l3_op     <= 8'd0;
         l3_size   <= 16'd0;
         l3_extend <= 16'd0;
      end else begin
         if(l3_init) begin
            l3_sel    <= rx_fifo_dout[3:0];
            l3_id     <= rx_fifo_dout[7:4];
            l3_op     <= rx_fifo_dout[15:8];
            l3_extend <= rx_fifo_dout[31:16];
            l3_size   <= l3_size_i;
         end
      end
   end

   /* WR DATA */
   reg           wd_update;
   wire   [31:0] msk, msk_d, wd, wd_nxt;
   wire          flg_msk;
   assign wd       = {rx_fifo_dout[7:0], rx_fifo_dout[15:8], rx_fifo_dout[23:16], rx_fifo_dout[31:24]};
   assign flg_msk  = (flg_l2_done & (l3_size[1:0] != 2'b00)) ? 1'b1 : 1'b0;
   assign msk      = {32{1'b1}} >> {l3_size[1:0], 3'd0};
   assign msk_d    = wd & (~msk);
   assign wd_nxt   = flg_msk ? msk_d : wd;


   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         l3_wd <= 32'd0;
      end else begin
         if(wd_update) begin
            l3_wd <= wd_nxt;
         end
      end
   end

   localparam L2_IDLE     = 9'b000000001;
   localparam L2_HEAD     = 9'b000000010;
   localparam L3_IDLE     = 9'b000000100;
   localparam L3_CMD      = 9'b000001000;
   localparam L3_START    = 9'b000010000;
   localparam L3_RXD      = 9'b000100000;
   localparam L3_WRU      = 9'b001000000;
   localparam L3_WRD      = 9'b010000000;
   localparam L2_CLEAN    = 9'b100000000;

   reg [8:0]      state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state  <= L2_IDLE;
      end else begin
         if(pin_l2_clr) begin
            state  <= L2_IDLE;
         end else begin
            state  <= state_nxt;
         end
      end
   end

   always @ (*) begin
      state_nxt        = state;
      rx_fifo_rd       = 0;
      l2_init          = 0;
      l3_init          = 0;
      l3_en            = 0;
      l3_wd_vld        = 0;
      wd_update        = 0;
      case (state)
        L2_IDLE      : begin
           if((!rx_fifo_empty) & (!pin_l2_loop)) begin
              rx_fifo_rd  = 1;
              state_nxt   = L2_HEAD;
           end
        end
        L2_HEAD   : begin
           if(flg_l2_eq_0B) begin
              state_nxt   = L2_IDLE;
           end else if(flg_l2_lt_4B) begin
              if(!rx_fifo_empty) begin
                 rx_fifo_rd  = 1;
                 state_nxt   = L2_IDLE;
              end
           end else begin
              state_nxt   = L3_IDLE;
              l2_init     = 1;
           end
        end
        L3_IDLE   : begin
           if(!rx_fifo_empty) begin
              rx_fifo_rd  = 1;
              state_nxt   = L3_CMD;
           end
        end
        L3_CMD    : begin
           l3_init      = 1;
           state_nxt    = L3_START;
        end
        L3_START  : begin
           l3_en       = 1;
           state_nxt   = L3_RXD;
        end
        L3_RXD    : begin
           if(l3_cmd_done) begin
              state_nxt     = L2_CLEAN;
           end else if(!flg_l2_done & !rx_fifo_empty ) begin
              rx_fifo_rd    = 1;
              state_nxt     = L3_WRU;
           end
        end
        L3_WRU    : begin
           if(l3_cmd_done) begin
              state_nxt     = L2_CLEAN;
           end else begin
              wd_update     = 1;
              state_nxt     = L3_WRD;
           end
        end
        L3_WRD    : begin
           l3_wd_vld        = 1;
           if(l3_cmd_done) begin
              state_nxt     = L2_CLEAN;
           end else if(l3_wd_rdy) begin
              state_nxt     = L3_RXD;
           end
        end
        L2_CLEAN   : begin
           if(!flg_l2_done & !rx_fifo_empty) begin
              rx_fifo_rd    = 1;
           end else if(flg_l2_done) begin
              state_nxt     = L2_IDLE;
           end
        end
      endcase // case (state)
   end
endmodule // l2_rx
