module msg_buf (/*AUTOARG*/
   // Outputs
   m_buf_rdy, msg_update, rcv_nxt1, msg,
   // Inputs
   clk, rst_n, s1_flg_384, m_buf_op, m_buf_en, m_buf_clr, m_prf_i, m_prf_u,
   wr_d, wr_en, bc_d, bc_en, rcv_size, rcv_last, hash_update, hash_finish,
   hash_nxt, hash_f, msg_sel
   ) ;
   // System Input
   input           clk, rst_n;
   // FLAG
   input           s1_flg_384;

   output          m_buf_rdy;
   input [1:0]     m_buf_op;  // WR_D, BC_D, RES, RES+
   input           m_buf_en;
   input           m_buf_clr;
   output          msg_update;

   input           m_prf_i;
   input           m_prf_u;

   input [31:0]    wr_d;
   input           wr_en;
   input [31:0]    bc_d;
   input           bc_en;

   input [1:0]     rcv_size;
   input           rcv_last;
   output          rcv_nxt1;

   input           hash_update;
   input           hash_finish;
   input [1023:0]  hash_nxt;

   input [511:0]   hash_f;

   input  [1:0]    msg_sel;
   output [1023:0] msg;

   /* Output Type */
   reg  [1023:0]   msg;
   reg             rcv_nxt1;
   reg             msg_update;
   reg             m_buf_rdy;

   /* Internal Register */
   reg [31:0]      mem[0:31];
   reg [31:0]      ovfd;

   reg [6:0]       mem_cntr;
   reg [6:0]       mem_t;
   /* Address and Round Next Value */
   // Input Address
   wire [4:0]      c_addr, n_addr;

   assign c_addr = mem_cntr[6:2];
   assign n_addr = mem_cntr[6:2] + 5'd1;

   // Address Next
   reg             sig_wr_msg;
   reg             sig_wr_seed;

   wire            carry;
   wire [6:0]      sum;
   wire [2:0]      add;
   wire            c_256, c_384;
   wire [5:0]      s_256;
   wire [6:0]      s_384;
   wire [6:0]      add_hash;
   wire [6:0]      add_256;
   wire [6:0]      add_384;

   genvar          g;
   integer         i;

   assign add            = (rcv_last & (rcv_size != 2'b00)) ? {1'b0, rcv_size} : 3'd4;
   assign {c_256, s_256} = mem_cntr[5:0] + add;
   assign {c_384, s_384} = mem_cntr[6:0] + add;
   assign carry          = s1_flg_384 ? c_384 : c_256;
   assign sum            = s1_flg_384 ? s_384 : {1'b0, s_256};

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         mem_cntr       <= 7'd0;
         msg_update     <= 1'b0;
      end else begin
         if(m_buf_clr) begin
            mem_cntr       <= 7'd0;
            msg_update     <= 1'b0;
         end else if(msg_update) begin
            msg_update     <= 1'b0;
         end else if(sig_wr_msg) begin
            mem_cntr       <= sum;
            msg_update     <= carry;
         end else if(sig_wr_seed) begin
            mem_cntr       <= s_384;
         end
      end
   end
   // Counter
   reg             cntr_clr;
   reg  [3:0]      cntr;
   wire [3:0]      cntr_nxt;
   wire            cntr_lst;
   wire            cntr_eq_8;
   wire            cntr_eq_12;

   assign cntr_nxt   = cntr + 4'd1;
   assign cntr_eq_8  = (cntr == 4'd7) ? 1'b1 : 1'b0;
   assign cntr_eq_12 = (cntr == 4'd11) ? 1'b1 : 1'b0;
   assign cntr_lst   = s1_flg_384 ? cntr_eq_12 : cntr_eq_8;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         cntr <= 4'd0;
      end else begin
         if(cntr_clr | m_buf_clr) begin
            cntr <= 4'd0;
         end else if(sig_wr_seed) begin
            cntr <= cntr_nxt;
         end
      end
   end

   // Hash Selector
   reg  [31:0]     h32;
   wire [31:0]     hash_array[0:15];

   always @ (*) begin
      h32 = hash_array[cntr];
   end

   generate
      for(g = 0; g < 16 ;g = g + 1) begin : h32_array
         assign hash_array[g] = hash_f[32*(16-g)-1 : 32*(15-g)];
      end
   endgenerate

   // Input Selector
   reg [31:0]      di;
   reg [1:0]       di_sel;

   always @ (*) begin
      case (di_sel)
        2'b00 : di = wr_d;
        2'b01 : di = bc_d;
        2'b10 : di = h32;
        2'b11 : di = 32'd0;
      endcase // case (1)
   end

   // Round Next Input Value
   reg  [31:0]     rd_data;
   wire [31:0]     msk;
   wire [31:0]     msk2;
   wire [31:0]     di_msk;
   wire [63:0]     di_rsh;
   wire [31:0]     wr_d_c, wr_d_n;

   assign msk            = {32{1'b1}} >> {rcv_size, 3'd0};
   assign msk2           = {32{1'b1}} >> {mem_cntr[1:0], 3'd0};

   assign di_msk         = (rcv_last & (rcv_size != 2'b00)) ? (di & (~msk)) : di;
   assign di_rsh         = {di_msk, 32'd0} >> {mem_cntr[1:0], 3'd0};
   assign {wr_d_c, wr_d_n} = {(rd_data & (~msk2)), 32'd0} | di_rsh;

   always @ (*) begin
      rd_data = mem[c_addr];
   end

   // Round Memory
   wire   [31:0] hna[0:31];
   generate
      for(g = 0; g < 32 ;g = g + 1) begin : hna_array
         assign hna[g] = hash_nxt[32*(32-g)-1 : 32*(31-g)];
      end
   endgenerate

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         for(i = 0; i < 32; i = i + 1) begin
            mem[i] <= 32'd0;
            ovfd   <= 32'd0;
         end
      end else begin
         if(m_buf_clr) begin
            for(i = 0; i < 32; i = i + 1) begin
               mem[i] <= 32'd0;
               ovfd   <= 32'd0;
            end
         end else if(sig_wr_msg | sig_wr_seed) begin
            if(carry) begin
               mem[c_addr] <= wr_d_c;
               ovfd        <= wr_d_n;
            end else begin
               mem[c_addr] <= wr_d_c;
               mem[n_addr] <= wr_d_n;
            end
         end else if (msg_update) begin
            mem[0]  <= ovfd;
            ovfd    <= 32'd0;
            for(i = 1; i < 32; i = i + 1) begin
               mem[i] <= 32'd0;
            end
         end else if (hash_update | hash_finish) begin
            for(i = 0; i < 32; i = i + 1) begin
               mem[i] <= hna[i];
            end
         end else if (m_prf_i) begin
            mem[0]  <= 32'd0;
            mem[1]  <= 32'd0;
            mem[2]  <= 32'd0;
            mem[3]  <= 32'd0;
            mem[4]  <= 32'd0;
            mem[5]  <= 32'd0;
            mem[6]  <= 32'd0;
            mem[7]  <= 32'd0;
            if(s1_flg_384) begin
               mem[8]  <= 32'd0;
               mem[9]  <= 32'd0;
               mem[10] <= 32'd0;
               mem[11] <= 32'd0;
               for(i = 0 ; i < 20; i = i + 1) begin
                  mem[i+12] <= mem[i];
               end
            end else begin
               for(i = 0 ; i < 24; i = i + 1) begin
                  mem[i+8] <= mem[i];
               end
            end
         end else if (m_prf_u) begin
            for(i = 0 ; i < 8; i = i + 1) begin
               mem[i]  <= hash_array[i];
            end
            if(s1_flg_384) begin
               mem[8]  <= hash_array[8];
               mem[9]  <= hash_array[9];
               mem[10] <= hash_array[10];
               mem[11] <= hash_array[11];
            end
         end
      end
   end


   localparam IDLE      = 6'b000001;
   localparam WR_DI     = 6'b000010;
   localparam BC_DI     = 6'b000100;
   localparam HSHI      = 6'b001000;
   localparam PRFI      = 6'b010000;
   localparam HSHU      = 6'b100000;

   reg   [5:0] state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(m_buf_clr) begin
            state <= IDLE;
         end else begin
            state <= state_nxt;
         end
      end
   end

   always @ (*) begin
      state_nxt     = state;
      m_buf_rdy     = 0;
      cntr_clr      = 0;
      di_sel        = 2'b00;
      rcv_nxt1      = 0;
      sig_wr_msg    = 0;
      sig_wr_seed   = 0;
      case (state)
        IDLE : begin
           m_buf_rdy     = 1;
           if(m_buf_en) begin
              state_nxt = WR_DI << m_buf_op;
           end
        end
        WR_DI : begin
           if(rcv_last & wr_en) begin
              state_nxt = IDLE;
           end
           sig_wr_msg   = wr_en;
           rcv_nxt1     = wr_en;
        end
        BC_DI : begin
           if(rcv_last & bc_en) begin
              state_nxt = IDLE;
           end
           di_sel       = 2'b01;
           sig_wr_msg   = bc_en;
           rcv_nxt1     = bc_en;
        end
        HSHI : begin
           cntr_clr  = 1;
           state_nxt = HSHU;
        end
        PRFI : begin
           if(rcv_last & wr_en) begin
              state_nxt = IDLE;
           end
           rcv_nxt1    = wr_en;
           sig_wr_seed = wr_en;
        end
        HSHU : begin
           di_sel       = 2'b10;
           sig_wr_seed  = 1;
           if(cntr_lst) begin
              cntr_clr  = 1;
              state_nxt = IDLE;
           end
        end
      endcase // case (state)
   end

   // Output
   wire   [1023:0] msg_t;
   generate
      for(g = 0; g < 32 ;g = g + 1) begin : n_msg
         assign msg_t[32*(32-g)-1 : 32*(31-g)] = mem[g];
      end
   endgenerate


   always @ (*) begin
      case (msg_sel)
        2'b00 : msg = msg_t;
        2'b01 : msg = {msg_t[511:0], 512'd0};
        2'b10 : msg = {msg_t[1023:768], 768'd0};
        2'b11 : msg = {msg_t[1023:640], 640'd0};
      endcase // case (msg_sel)
   end

endmodule // msg_buf
