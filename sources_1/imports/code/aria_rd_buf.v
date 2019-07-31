module aria_rd_buf (/*AUTOARG*/
   // Outputs
   rd_d, rb_d_rdy, rb_done, bc_enc_en, bc_enc,
   // Inputs
   clk, rst_n, clr_core, rd_en, cmd_extend, rb_op, rb_en, ecb_do, xfb_do,
   mac_do, rb_d_vld
   ) ;
   // System Area
   input           clk, rst_n;
   input           clr_core;
   // Output
   input           rd_en;
   output [31:0]   rd_d;
   // RD OP
   input [15:0]    cmd_extend;
   input [1:0]     rb_op; // ECB, XFB, CBC_ENC, MAC
   input           rb_en;
   // Buf Data In
   input [127:0]   ecb_do;
   input [127:0]   xfb_do;
   input [127:0]   mac_do;
   input           rb_d_vld;
   output          rb_d_rdy;
   output          rb_done;
   output          bc_enc_en;
   output [31:0]   bc_enc;

   /* Output Type */
   wire [31:0]     rd_d;
   wire [31:0]     bc_enc;
   reg             rb_d_rdy;
   reg             rb_done;

   /* Internal Register */
   reg             bc_enc_en;
   reg             rb_next;
   reg [128:0]     rb_buf;

   /* Input Selector */
   reg [1:0]       sel;
   reg [127:0]     do_sel;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         sel <= 2'd0;
      end else begin
         if(rb_en) begin
            sel <= rb_op;
         end
      end
   end

   always @ (*) begin
      case (sel)
        2'b00 : do_sel = ecb_do;
        2'b01 : do_sel = xfb_do;
        2'b10 : do_sel = ecb_do;
        2'b11 : do_sel = mac_do;
      endcase // case (sel)
   end

   /* Read Counter */
   reg    [15:0] cntr;
   wire   [15:0] cntr_nxt;
   wire   [15:0] cntr_sub;
   wire          cntr_lst;
   wire          cntr_fin;

   assign cntr_sub = cntr - 16'd4;
   assign cntr_lst = (cntr <  16'd5) ? 1'b1 : 1'b0;
   assign cntr_fin = (cntr == 16'd0) ? 1'b1 : 1'b0;
   assign cntr_nxt = cntr_lst ? 16'd0 : cntr_sub;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         cntr <= 16'd0;
      end else begin
         if(clr_core) begin
            cntr <= 16'd0;
         end else if(rb_en) begin
            cntr <= cmd_extend;
         end else if(rb_next) begin
            cntr <= cntr_nxt;
         end
      end
   end

   /* Read Buffer */
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         rb_buf <= 128'd0;
      end else begin
         if(clr_core) begin
            rb_buf <= 128'd0;
         end else if(rb_d_vld & rb_d_rdy) begin
            rb_buf <= do_sel;
         end else if(rb_next) begin
            rb_buf <= {rb_buf[95:0], 32'd0};
         end
      end
   end
   wire   [31:0] fifo_di;
   assign fifo_di = rb_buf[127:96];
   assign bc_enc  = rb_buf[127:96];

   // State Transition
   localparam IDLE  = 3'b001;
   localparam SEND  = 3'b010;
   localparam SLEEP = 3'b100;

   reg   [2:0] state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state  <= IDLE;
      end else begin
         if(clr_core | rb_en) begin
            state  <= IDLE;
         end else begin
            state  <= state_nxt;
         end
      end
   end

   reg   [1:0] loop;
   reg         loop_clr;
   wire [1:0]  loop_nxt;
   assign loop_nxt = loop + 2'd1;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         loop <= 2'd0;
      end else begin
         if(loop_clr) begin
            loop <= 2'd0;
         end else if(rb_next) begin
            loop <= loop_nxt;
         end
      end
   end

   always @ (*) begin
      state_nxt     = state;
      rb_d_rdy      = 0;
      rb_done       = 0;
      bc_enc_en     = 0;
      rb_next       = 0;
      loop_clr      = 0;
      case (state)
        IDLE     : begin
           rb_d_rdy  = 1;
           if(cntr_fin) begin
              rb_done   = 1;
           end else if(rb_d_vld) begin
              state_nxt = SEND;
              loop_clr  = 1;
           end
        end
        SEND    : begin
           rb_next   = 1;
           if(sel == 2'b10) begin
              bc_enc_en = 1;
           end
           if(loop == 2'b11) begin
              state_nxt = IDLE;
           end else begin
              state_nxt = SLEEP;
           end
        end
        SLEEP : begin
           if(cntr_fin) begin
              state_nxt = IDLE;
           end else begin
              state_nxt = SEND;
           end
        end
      endcase // case (state)
   end


   aria_rd_fifo RFF (/*AUTOINST*/
                     // Outputs
                     .rd_d              (rd_d[31:0]),
                     // Inputs
                     .clk               (clk),
                     .rst_n             (rst_n),
                     .clr_core          (clr_core),
                     .rb_en             (rb_en),
                     .rd_en             (rd_en),
                     .rb_next           (rb_next),
                     .fifo_di           (fifo_di[31:0]));

endmodule // aria_rd_buf

module aria_rd_fifo (/*AUTOARG*/
   // Outputs
   rd_d,
   // Inputs
   clk, rst_n, clr_core, rb_en, rd_en, rb_next, fifo_di
   ) ;
   input           clk, rst_n;
   input           clr_core;
   input           rb_en;

   output [31:0]   rd_d;
   input           rd_en;


   input           rb_next;
   input [31:0]    fifo_di;

   reg [31:0]      mem[0:255];
   reg [31:0]      rd_d;

   reg  [7:0]      wr_ptr;
   reg  [7:0]      rd_ptr;
   wire [7:0]      wr_ptr_nxt;
   wire [7:0]      rd_ptr_nxt;

   assign wr_ptr_nxt = wr_ptr + 8'd1;
   assign rd_ptr_nxt = rd_ptr + 8'd1;

   always @ (posedge clk) begin
      if(rb_next) begin
         mem[wr_ptr] <= fifo_di;
      end
   end

   always @ (posedge clk) begin
      if(!rst_n) begin
         wr_ptr <= 8'd0;
      end else begin
         if(rb_en | clr_core) begin
            wr_ptr  <= 8'd0;
         end else if(rb_next) begin
            wr_ptr  <= wr_ptr_nxt;
         end
      end
   end

   always @ (posedge clk) begin
      if(!rst_n) begin
         rd_ptr    <= 8'd0;
         rd_d      <= 32'd0;
      end else begin
         if(rb_en | clr_core) begin
            rd_ptr    <= 8'd0;
            rd_d      <= 32'd0;
         end else if(rd_en) begin
            rd_ptr    <= rd_ptr_nxt;
            rd_d      <= mem[rd_ptr];
         end
      end
   end
endmodule // aria_rd_fifo

