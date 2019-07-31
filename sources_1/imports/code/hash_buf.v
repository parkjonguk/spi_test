module hash_buf (/*AUTOARG*/
   // Outputs
   h_buf_rdy, rcv_nxt0, hash_m, hash_nxt, hash_update,
   // Inputs
   clk, rst_n, s0_flg_384, h_buf_en, h_buf_clr, h_buf_wrm, wr_d, wr_en,
   rcv_size, rcv_last, hash_o
   ) ;
   // System Input
   input           clk, rst_n;
   // FLAG
   input           s0_flg_384;
   // CU
   output          h_buf_rdy;
   input           h_buf_en;
   input           h_buf_clr;
   input           h_buf_wrm;

   input [31:0]    wr_d;
   input           wr_en;

   input [1:0]     rcv_size;
   input           rcv_last;
   output          rcv_nxt0;

   input [511:0]   hash_o;
   output [511:0]  hash_m;

   output [1023:0] hash_nxt;
   output          hash_update;

   /* Output Type */
   reg             h_buf_rdy;
   wire [1023:0]   hash_nxt;
   reg             hash_update;
   reg             rcv_nxt0;
   reg [511:0]     hash_m;

   /* Internal Register */
   reg [31:0]      mem[0:31];
   reg [31:0]      ovfd;
   reg [6:0]       mem_cntr;

   /* Address and Round Next Value */
   // Input Address
   wire [4:0]      c_addr, n_addr;

   assign c_addr = mem_cntr[6:2];
   assign n_addr = mem_cntr[6:2] + 5'd1;

   // Address Next
   wire            carry;
   wire [6:0]      sum;
   wire [2:0]      add;
   wire            c_256, c_384;
   wire [5:0]      s_256;
   wire [6:0]      s_384;

   assign add            = (rcv_last & (rcv_size != 2'b00)) ? {1'b0, rcv_size} : 3'd4;
   assign {c_256, s_256} = mem_cntr[5:0] + add;
   assign {c_384, s_384} = mem_cntr[6:0] + add;
   assign carry          = s0_flg_384 ? c_384 : c_256;
   assign sum            = s0_flg_384 ? s_384 : {1'b0, s_256};

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         mem_cntr    <= 7'd0;
         hash_update <= 1'b0;
      end else begin
         if(h_buf_clr) begin
            mem_cntr    <= 7'd0;
            hash_update <= 1'b0;
         end else if(hash_update) begin
            hash_update <= 1'b0;
         end else if(rcv_nxt0) begin
            mem_cntr    <= sum;
            hash_update <= carry;
         end
      end
   end

   // Round Next Input Value
   reg  [31:0]     rd_data;
   wire [63:0]     di;
   wire [31:0]     wr_d_c, wr_d_n;
   wire [31:0]     msk, wr_ds;
   assign msk  = {32{1'b1}} >> {rcv_size, 3'd0};
   assign wr_ds = (rcv_last & (rcv_size != 2'b00)) ? (wr_d & (~msk)) : wr_d;

   always @ (*) begin
      rd_data = mem[c_addr];
   end
   assign di = {wr_ds, 32'd0} >> {mem_cntr[1:0], 3'd0};
   assign {wr_d_c, wr_d_n} = {rd_data, 32'd0} | di;

   // Round Memory
   integer       i;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         for(i = 0; i < 32; i = i + 1) begin
            mem[i] <= 32'd0;
            ovfd   <= 32'd0;
         end
      end else begin
         if(h_buf_clr) begin
            for(i = 0; i < 32; i = i + 1) begin
               mem[i] <= 32'd0;
               ovfd   <= 32'd0;
            end
         end else if(rcv_nxt0) begin
            if(carry) begin
               mem[c_addr] <= wr_d_c;
               ovfd        <= wr_d_n;
            end else begin
               mem[c_addr] <= wr_d_c;
               mem[n_addr] <= wr_d_n;
            end
         end else if (hash_update) begin
            mem[0]  <= ovfd;
            ovfd    <= 32'd0;
            for(i = 1; i < 32; i = i + 1) begin
               mem[i] <= 32'd0;
            end
         end
      end
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         hash_m <= 512'd0;
      end else begin
         if(h_buf_clr) begin
            hash_m <= 512'd0;
         end else if (h_buf_wrm) begin
            hash_m <= hash_o;
         end
      end
   end

   localparam IDLE = 2'b01;
   localparam RECV = 2'b10;


   reg   [1:0] state, state_nxt;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(h_buf_clr) begin
            state <= IDLE;
         end else begin
            state <= state_nxt;
         end
      end
   end

   always @ (*) begin
      state_nxt     = state;
      rcv_nxt0      = 0;
      h_buf_rdy     = 0;
      case (state)
        IDLE   : begin
           h_buf_rdy     = 1;
           if(h_buf_en) begin
              state_nxt = RECV;
           end
        end
        RECV   : begin
           if(wr_en) begin
              rcv_nxt0   = 1'b1;
              if(rcv_last) begin
                 state_nxt   = IDLE;
              end
           end
        end
      endcase // case (state)
   end


   // Output
   genvar  g;
   generate
      for(g = 0; g < 32 ;g = g + 1) begin : h_nxt
         assign hash_nxt[32*(32-g)-1 : 32*(31-g)] = mem[g];
      end
   endgenerate
endmodule // hash_buf
