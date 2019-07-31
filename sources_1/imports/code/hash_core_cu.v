module hash_core_cu (/*AUTOARG*/
   // Outputs
   cmd_rdy, wr_open, rd_open, resp_done, resp_err, hash_finish, msg_sel,
   h_buf_clr, h_buf_en, h_buf_wrm, m_buf_op, m_buf_en, m_buf_clr, m_prf_i,
   m_prf_u, k_buf_clr, k_buf_en, k_buf_op, k_buf_wr, msk_clr, msk_en0, msk_en1,
   s0_prm_set, s0_prm_clr, s1_prm_set, s1_prm_clr, rcv_wr_d, rcv_bc_d, rcv_clr,
   size0_clr, size0_add, size1_en, size1_clr, size1_op, ssk_wr, ssk_addr,
   hash_op, hash_en, hash_clr, msg_size,
   // Inputs
   clk, rst_n, clr_hash, ss_expire, cmd_en, cmd_op, cmd_extend, wr_size,
   hash_update, msg_update, h_buf_rdy, m_buf_rdy, s0_prm_vld, s0_flg_384,
   s1_prm_vld, s1_flg_384, rcv_done, size0, size1, hash_rdy, hash_done
   ) ;
   input           clk, rst_n;
   input           clr_hash;
   input           ss_expire;

   // L3 Communication
   output          cmd_rdy;
   input           cmd_en;
   input [7:0]     cmd_op;
   input [15:0]    cmd_extend;

   input [15:0]    wr_size;
   output          wr_open;
   output          rd_open;

   output          resp_done;
   output [1:0]    resp_err;

   // HASH Start Signal
   input           hash_update;
   input           msg_update;
   output          hash_finish;
   output [1:0]    msg_sel;
   // HASH Buffer
   input           h_buf_rdy;
   output          h_buf_clr;
   output          h_buf_en;
   output          h_buf_wrm;
   // MSG Buffer
   input           m_buf_rdy;
   output [1:0]    m_buf_op;
   output          m_buf_en;
   output          m_buf_clr;
   output          m_prf_i;
   output          m_prf_u;
   // KEY Buffer
   output          k_buf_clr;
   output          k_buf_en;
   output [1:0]    k_buf_op;
   output          k_buf_wr;
   // Master Secret Key Buffer
   output          msk_clr;
   output          msk_en0;
   output          msk_en1;
   // S0 Parameter
   output          s0_prm_set;
   output          s0_prm_clr;
   input           s0_prm_vld;
   input           s0_flg_384;
   // S1 Parameter
   output          s1_prm_set;
   output          s1_prm_clr;
   input           s1_prm_vld;
   input           s1_flg_384;
   // RCV CTRL
   output          rcv_wr_d;
   output          rcv_bc_d;
   output          rcv_clr;
   input           rcv_done;
   // Size Parameter
   input  [31:0]   size0;
   input  [31:0]   size1;
   output          size0_clr;
   output          size0_add;
   output          size1_en;
   output          size1_clr;
   output [1:0]    size1_op;
   // Session Key
   output          ssk_wr;
   output [3:0]    ssk_addr;
   // HASH Control
   input           hash_rdy;
   input           hash_done;
   output [4:0]    hash_op;
   output          hash_en;
   output          hash_clr;
   output [31:0]   msg_size;

   reg [4:0]       hash_op;
   reg             hash_en;
   reg [31:0]      msg_size;
   reg             hash_clr;

   reg             cmd_rdy;
   reg             h_buf_en;
   reg             h_buf_clr;
   reg             h_buf_wrm;
   wire            msk_en0;
   wire            msk_en1;
   wire            ssk_wr;
   wire [3:0]      ssk_addr;
   reg             wr_open;
   reg             rd_open;
   reg             resp_done;
   reg [1:0]       resp_err;
   reg             hash_finish;
   reg [1:0]       msg_sel;
   reg [1:0]       m_buf_op;
   reg             m_buf_en;
   reg             m_buf_clr;
   reg             m_prf_i;
   reg             m_prf_u;
   reg             k_buf_clr;
   reg             k_buf_en;
   reg [1:0]       k_buf_op;
   reg             k_buf_wr;
   reg             msk_clr;
   reg             s0_prm_set;
   reg             s0_prm_clr;
   reg             s1_prm_set;
   reg             s1_prm_clr;
   reg             rcv_wr_d;
   reg             rcv_bc_d;
   reg             rcv_clr;
   reg             size0_clr;
   reg             size0_add;
   reg             size1_en;
   reg             size1_clr;
   reg [1:0]       size1_op;


   /* PRF FLAG */
   reg             flg_prf;
   reg             prf_down;
   reg             prf_up;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_prf <= 1'b0;
      end else begin
         if(prf_down) begin
            flg_prf <= 1'b0;
         end else if(prf_up) begin
            flg_prf <= 1'b1;
         end
      end
   end

   /* PRF COUNTER */
   reg [1:0]       counter;
   wire            prf_vld;
   wire [1:0]      counter_nxt;
   assign counter_nxt = counter + 2'd1;
   assign prf_vld  = prf_up & flg_prf;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         counter <= 2'd0;
      end else begin
         if(prf_down) begin
            counter <= 2'd0;
         end else if(prf_vld) begin
            counter <= counter_nxt;
         end
      end
   end

   /* SSK Output */
   assign ssk_wr        = (cmd_op[1] ^ cmd_op[0]) & prf_vld;
   assign ssk_addr[1:0] = counter;
   assign ssk_addr[3]   = cmd_op[1];
   assign ssk_addr[2]   = s1_flg_384;

   /* PRF Finish Signal */
   wire            prf_clr;
   wire            prf_done;
   wire            finm_d, msk_d, aead_d, cbck_d;

   assign msk_en0  = (cmd_op[1:0] == 2'd0) & (counter == 2'd0) & prf_vld;
   assign msk_en1  = (cmd_op[1:0] == 2'd0) & (counter == 2'd1) & prf_vld;
   assign finm_d   = (cmd_op[1:0] == 2'd3) & flg_prf;
   assign msk_d    = (cmd_op[1:0] == 2'd0) & (counter[0] ^ s1_flg_384) & flg_prf;
   assign aead_d   = (cmd_op[1:0] == 2'd2) & (counter == 2'd1);
   assign cbck_d   = (cmd_op[1:0] == 2'd1) & (counter == 2'd3);
   assign prf_clr  = msk_d | aead_d | cbck_d;
   assign prf_done = finm_d;

   localparam ERR_CMD      = 2'b01;
   localparam ERR_SIZE     = 2'b10;
   localparam ERR_PRM      = 2'b10;

   localparam IDLE          = 41'b00000000000000000000000000000000000000001;
   localparam RESP_ERR_CMD  = 41'b00000000000000000000000000000000000000010;
   localparam RESP_ERR_PRM  = 41'b00000000000000000000000000000000000000100;
   localparam RESP_ERR_SIZE = 41'b00000000000000000000000000000000000001000;
   localparam CMD_RD        = 41'b00000000000000000000000000000000000010000;
   localparam CMD_CLEAR     = 41'b00000000000000000000000000000000000100000;
   localparam CMD_S0_INIT   = 41'b00000000000000000000000000000000001000000;
   localparam CMD_S0_RECV   = 41'b00000000000000000000000000000000010000000;
   localparam CMD_S0_FINL   = 41'b00000000000000000000000000000000100000000;
   localparam CMD_S1_CERT   = 41'b00000000000000000000000000000001000000000;
   localparam CMD_S1_LDSK   = 41'b00000000000000000000000000000010000000000;
   localparam CMD_S1_LDCK   = 41'b00000000000000000000000000000100000000000;
   localparam CMD_S1_INIT   = 41'b00000000000000000000000000001000000000000;
   localparam CMD_S1_HWRD   = 41'b00000000000000000000000000010000000000000;
   localparam CMD_S1_HBCD   = 41'b00000000000000000000000000100000000000000;
   localparam CMD_S1_HFIN   = 41'b00000000000000000000000001000000000000000;
   localparam CMD_S1_WRK    = 41'b00000000000000000000000010000000000000000;
   localparam CMD_S1_MSK    = 41'b00000000000000000000000100000000000000000;
   localparam CMD_S1_CBCK   = 41'b00000000000000000000001000000000000000000;
   localparam CMD_S1_AEAD   = 41'b00000000000000000000010000000000000000000;
   localparam CMD_S1_FINM   = 41'b00000000000000000000100000000000000000000;
   localparam S0_HASH_WRD   = 41'b00000000000000000001000000000000000000000;
   localparam S0_HASH_FIN   = 41'b00000000000000000010000000000000000000000;
   localparam S0_WAIT_DONE  = 41'b00000000000000000100000000000000000000000;
   localparam S1_HASH_CERT  = 41'b00000000000000001000000000000000000000000;
   localparam S1_HASH_FINAL = 41'b00000000000000010000000000000000000000000;
   localparam S1_HMAC_RXD   = 41'b00000000000000100000000000000000000000000;
   localparam S1_HMAC_BCD   = 41'b00000000000001000000000000000000000000000;
   localparam S1_PRF_WA     = 41'b00000000000010000000000000000000000000000;
   localparam S1_PRF_WD     = 41'b00000000000100000000000000000000000000000;
   localparam S1_PRF_INIT   = 41'b00000000001000000000000000000000000000000;
   localparam S1_PRF_R0     = 41'b00000000010000000000000000000000000000000;
   localparam S1_PRF_R1     = 41'b00000000100000000000000000000000000000000;
   localparam S1_PRF_N      = 41'b00000001000000000000000000000000000000000;
   localparam S1_PRF_EXTD   = 41'b00000010000000000000000000000000000000000;
   localparam S1_SUCCESS    = 41'b00000100000000000000000000000000000000000;
   localparam S0_SUCCESS    = 41'b00001000000000000000000000000000000000000;
   localparam S1_WR_KEY     = 41'b00010000000000000000000000000000000000000;
   localparam S1_PRF_SD_I   = 41'b00100000000000000000000000000000000000000;
   localparam S1_PRF_SD_R   = 41'b01000000000000000000000000000000000000000;
   localparam S1_PRF_SD_F   = 41'b10000000000000000000000000000000000000000;

   reg [40:0]      state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(clr_hash | ss_expire) begin
            state <= CMD_CLEAR;
         end else begin
            state <= state_nxt;
         end
      end
   end

   always @ (*) begin
      state_nxt      = state;
      // L3 Communication Response
      wr_open        = 0;
      rd_open        = 0;
      resp_done      = 0;
      resp_err       = 2'b00;
      // HASH Operation
      hash_finish    = 0;
      msg_sel        = 2'b00;
      hash_op        = 5'b00000;
      hash_en        = 0;
      hash_clr       = 0;
      msg_size       = 32'd0;
      // HASH Buffer Control
      h_buf_en       = 0;
      h_buf_clr      = 0;
      h_buf_wrm      = 0;
      // MSG Buffer Control
      m_buf_op       = 2'b00;
      m_buf_en       = 0;
      m_buf_clr      = 0;
      m_prf_i        = 0;
      m_prf_u        = 0;
      // Key Buffer Control
      k_buf_clr      = 0;
      k_buf_wr       = 0;
      k_buf_en       = 0;
      k_buf_op       = 2'b00;
      // Master Secret Control
      msk_clr        = 0;
      // Parameter
      s0_prm_set     = 0;
      s0_prm_clr     = 0;
      s1_prm_set     = 0;
      s1_prm_clr     = 0;
      // RCV Control
      rcv_wr_d       = 0;
      rcv_bc_d       = 0;
      rcv_clr        = 0;
      // Size Control
      size0_clr      = 0;
      size0_add      = 0;
      size1_en       = 0;
      size1_op       = 2'b00;
      size1_clr      = 0;
      // PRF Control
      prf_down       = 0;
      prf_up         = 0;
      cmd_rdy = 0;
      case (state)
        IDLE         : begin
           cmd_rdy = 1;
           if(cmd_en) begin
              if(cmd_op == 8'b10000000) begin
                 state_nxt = CMD_RD;
              end else if(cmd_op[7:5] == 3'd0) begin
                 state_nxt = (CMD_CLEAR << cmd_op[3:0]);
                 rcv_wr_d  = 1;
              end else begin
                 state_nxt = RESP_ERR_CMD;
              end
           end
        end
        RESP_ERR_CMD  : begin
           rcv_clr     = 1;
           resp_done   = 1;
           resp_err    = ERR_CMD;
           state_nxt   = IDLE;
        end
        RESP_ERR_SIZE : begin
           rcv_clr     = 1;
           resp_done   = 1;
           resp_err    = ERR_SIZE;
           state_nxt   = IDLE;
        end
        RESP_ERR_PRM  : begin
           rcv_clr     = 1;
           resp_done   = 1;
           resp_err    = ERR_PRM;
           state_nxt   = IDLE;
        end
        CMD_RD       : begin
           if((wr_size != 16'd0) | (cmd_extend > 16'd48) | (cmd_extend == 16'd0)) begin
              // Size PRM Check
              state_nxt   = RESP_ERR_SIZE;
           end else begin
              rd_open     = 1;
              state_nxt   = IDLE;
           end
        end
        CMD_CLEAR    : begin
           resp_done      = 1;
           hash_clr       = 1;
           h_buf_clr      = 1;
           m_buf_clr      = 1;
           k_buf_clr      = 1;
           msk_clr        = 1;
           s0_prm_clr     = 1;
           s1_prm_clr     = 1;
           rcv_clr        = 1;
           size0_clr      = 1;
           size1_clr      = 1;
           prf_down       = 1;
           state_nxt      = IDLE;
        end
        CMD_S0_INIT  : begin
           if(s1_prm_vld) begin
              // S1 Have Priority
              state_nxt   = RESP_ERR_PRM;
           end else if(wr_size != 16'd0) begin
              // Hash Init Cannot have Write Data
              state_nxt   = RESP_ERR_SIZE;
           end else begin
              // Internal Buffer Clear
              h_buf_clr   = 1;
              s0_prm_set  = 1;
              size0_clr   = 1;
              // REQ INIT VALUE
              hash_op     = {2'b10, cmd_op[4], 2'b00};
              hash_en     = 1;
              // WAIT INIT VALUE
              state_nxt   = S0_HASH_WRD;
           end
        end
        CMD_S0_RECV  : begin
           if((!s0_prm_vld) | s1_prm_vld)begin
              // S0 is not Setup or S1 Occupy Then PRM ERR
              state_nxt   = RESP_ERR_PRM;
           end else if(wr_size == 16'd0) begin
              // Write Size Need to gt 0
              state_nxt   = RESP_ERR_SIZE;
           end else begin
              // S0 Size = S0 Size + RCV Size
              size0_add = 1;
              // WR Channel Open WRD -> H_BUF
              h_buf_en  = 1;
              wr_open   = 1;
              // HASH(WRD)
              state_nxt = S0_HASH_WRD;
           end
        end
        CMD_S0_FINL  : begin
           if((!s0_prm_vld) | s1_prm_vld)begin
              // S0 is not Setup or S1 Occupy Then PRM ERR
              state_nxt   = RESP_ERR_PRM;
           end else if(wr_size != 16'd0) begin
              // Write Size Need to eq 0
              state_nxt   = RESP_ERR_SIZE;
           end else begin
              hash_finish  = 1;
              state_nxt    = S0_HASH_FIN;
           end
        end
        CMD_S1_CERT  : begin
           if(s1_prm_vld) begin
              // S1 Already Occupied
              state_nxt   = RESP_ERR_PRM;
           end else begin
              // S1 Occupy
              s1_prm_set  = 1;
              // Size Set From RCV SIZE
              size1_op    = 2'b00;
              size1_en    = 1;
              // WR Channel Open WRD -> M_BUF
              wr_open     = 1;
              m_buf_op    = 2'b00;
              m_buf_en    = 1;
              // HASH INIT
              hash_op     = {2'b00, cmd_op[4], 2'b00};
              hash_en     = 1;
              state_nxt   = S1_HASH_CERT;
           end
        end
        CMD_S1_LDSK  : begin
           if(s1_prm_vld) begin
              // S1 Already Occupied
              state_nxt   = RESP_ERR_PRM;
           end else if(wr_size != 16'd0)begin
              // HMAC Init(ServerKey) Wr size eq 0
              state_nxt   = RESP_ERR_SIZE;
           end else begin
              // Load Key
              k_buf_op    = 2'b10;
              k_buf_en    = 1;
              // Real Init Sequence Start
              state_nxt   = CMD_S1_INIT;
           end
        end
        CMD_S1_LDCK  : begin
           if(s1_prm_vld) begin
              // S1 Already Occupied
              state_nxt   = RESP_ERR_PRM;
           end else if(wr_size != 16'd0)begin
              // HMAC Init(ClientKey) Wr size eq 0
              state_nxt   = RESP_ERR_SIZE;
           end else begin
              // Load Key
              k_buf_op    = 2'b11;
              k_buf_en    = 1;
              // Real Init Sequence Start
              state_nxt   = CMD_S1_INIT;
           end
        end
        CMD_S1_INIT  : begin
           if(s1_prm_vld) begin
              // S1 Already Occupied
              state_nxt   = RESP_ERR_PRM;
           end else if(wr_size != 16'd0)begin
              // HMAC Init(ClientKey) Wr size eq 0
              state_nxt   = RESP_ERR_SIZE;
           end else begin
              // S1 Occupy
              s1_prm_set  = 1;
              // Clear Internal Buffer
              m_buf_clr   = 1;
              size1_clr   = 1;
              // Real Init Sequence Start
              state_nxt   = S1_SUCCESS;
              hash_op     = {2'b01, cmd_op[4], 2'b00};
              hash_en     = 1;
           end
        end
        CMD_S1_HWRD  : begin
           if(!s1_prm_vld) begin
              // S1 Is Did Not Init
              state_nxt   = RESP_ERR_PRM;
           end else if(wr_size == 16'd0) begin
              // Write Size need to gt 0
              state_nxt   = RESP_ERR_SIZE;
           end else begin
              // WR Channel Open
              m_buf_op    = 2'b00;
              m_buf_en    = 1;
              wr_open     = 1;
              // Size = Size1 + RCV Size
              size1_op    = 2'b01;
              size1_en    = 1;
              // S1_HMAC_RXD
              state_nxt    = S1_HMAC_RXD;
           end
        end
        CMD_S1_HBCD  : begin
           if(!s1_prm_vld) begin
              // S1 Is Did Not Init
              state_nxt   = RESP_ERR_PRM;
           end else if(wr_size != 16'd0) begin
              // Write Size need to eq 0
              state_nxt   = RESP_ERR_SIZE;
           end else begin
              resp_done  = 1;
              // WR Channel Open
              m_buf_op    = 2'b01;
              m_buf_en    = 1;
              rcv_bc_d    = 1;
              // Size = Size1 + EXTEND Size
              size1_op    = 2'b10;
              size1_en    = 1;
              // S1_HMAC_RXD
              state_nxt    = S1_HMAC_BCD;
           end
        end
        CMD_S1_HFIN  : begin
           hash_op      = {2'b01, s1_flg_384, 2'b10};
           msg_size     = size1;
           if(!s1_prm_vld) begin
              // S1 Is Did Not Init
              state_nxt   = RESP_ERR_PRM;
           end else if(wr_size != 16'd0) begin
              // Write Size need to eq 0
              state_nxt   = RESP_ERR_SIZE;
           end else begin
              hash_en      = 1;
              state_nxt    = S0_SUCCESS;
           end
        end
        CMD_S1_WRK   : begin
           if(s1_prm_vld) begin
              // S1 Already Occupied
              state_nxt   = RESP_ERR_PRM;
           end else if ((wr_size > 16'd64) | (wr_size == 16'd0)) begin
              state_nxt   = RESP_ERR_SIZE;
           end else begin
              state_nxt   = S1_WR_KEY;
              k_buf_clr   = 1;
              wr_open     = 1;
           end
        end
        CMD_S1_MSK   : begin
           if(s1_prm_vld) begin
              state_nxt   = RESP_ERR_PRM;
           end else if((wr_size > 16'd79) | (wr_size == 16'd0)) begin
              state_nxt   = RESP_ERR_SIZE;
           end else begin
              // S1 Occupy
              s1_prm_set   = 1;
              // Size Set From RCV SIZE
              size1_op     = 2'b00;
              size1_en     = 1;
              // MSG BUFFER SET
              m_buf_op     = 2'b11;
              m_buf_en     = 1;
              wr_open      = 1;
              // PRF Loop Size
              prf_down     = 1;
              // Load Key
              k_buf_en     = 1;
              k_buf_op     = 2'b00;
              // NXT State
              state_nxt    = S1_PRF_WD;
           end
        end
        CMD_S1_CBCK   : begin
           if(s1_prm_vld) begin
              state_nxt   = RESP_ERR_PRM;
           end else if((wr_size > 16'd79) | (wr_size == 16'd0)) begin
              state_nxt   = RESP_ERR_SIZE;
           end else begin
              // S1 Occupy
              s1_prm_set   = 1;
              // Size Set From RCV SIZE
              size1_op     = 2'b00;
              size1_en     = 1;
              // MSG BUFFER SET
              m_buf_op     = 2'b11;
              m_buf_en     = 1;
              wr_open      = 1;
              // PRF Loop Size
              prf_down     = 1;
              // Load Key
              k_buf_en     = 1;
              k_buf_op     = 2'b01;
              // NXT State
              state_nxt    = S1_PRF_WD;
           end
        end
        CMD_S1_AEAD   : begin
           if(s1_prm_vld) begin
              state_nxt   = RESP_ERR_PRM;
           end else if((wr_size > 16'd79) | (wr_size == 16'd0)) begin
              state_nxt   = RESP_ERR_SIZE;
           end else begin
              // S1 Occupy
              s1_prm_set   = 1;
              // Size Set From RCV SIZE
              size1_op     = 2'b00;
              size1_en     = 1;
              // MSG BUFFER SET
              m_buf_op     = 2'b11;
              m_buf_en     = 1;
              wr_open      = 1;
              // PRF Loop Size
              prf_down     = 1;
              // Load Key
              k_buf_en     = 1;
              k_buf_op     = 2'b01;
              // NXT State
              state_nxt    = S1_PRF_WD;
           end
        end
        CMD_S1_FINM   : begin
           if(s1_prm_vld) begin
              state_nxt   = RESP_ERR_PRM;
           end else if((wr_size > 16'd47) | (wr_size == 16'd0)) begin
              state_nxt   = RESP_ERR_SIZE;
           end else begin
              // S1 Occupy
              s1_prm_set   = 1;
              // Size Set From RCV SIZE
              size1_op     = 2'b00;
              size1_en     = 1;
              // MSG BUFFER SET
              m_buf_op     = 2'b11;
              m_buf_en     = 1;
              wr_open      = 1;
              // PRF Loop Size
              prf_down     = 1;
              // Load Key
              k_buf_en     = 1;
              k_buf_op     = 2'b01;
              // NXT State
              state_nxt    = S1_PRF_WA;
           end
        end
        // S0 Hash Channel
        S0_HASH_WRD  : begin
           // Hash Operation Code
           hash_op         = {2'b10, s0_flg_384, 2'b01};
           // Update Temporary HASH Value
           h_buf_wrm       = hash_done;
           // Hash MSG Size
           if(hash_update) begin
              hash_en      = 1;
           end else if(h_buf_rdy & hash_rdy) begin
              state_nxt    = S0_SUCCESS;
           end
        end
        S0_HASH_FIN  : begin
           // HASH FINAL MSG SIZE
           msg_size     = size0;
           // Hash Operation Code
           hash_op      = {2'b10, s0_flg_384, 2'b10};
           hash_en      = 1;
           // Wait Hash Done
           state_nxt    = S0_SUCCESS;
        end
        S0_SUCCESS   : begin
           if(hash_rdy) begin
              state_nxt    = IDLE;
              // S0 SUCCESS RESPONSE
              resp_done    = 1;
              // S1 PRM CLEAR
              k_buf_clr    = 1;
              m_buf_clr    = 1;
              s1_prm_clr   = 1;
              size1_clr    = 1;
           end
        end
        // S1 Hash Channel
        S1_HASH_CERT : begin
           // Hash Operation Code
           hash_op = {2'b00, s1_flg_384, 2'b01};
           if(msg_update) begin
              hash_en    = 1;
           end else if(m_buf_rdy & hash_rdy) begin
              // HASH(WRD) Done Then Go to HASH FINAL
              state_nxt  = S1_HASH_FINAL;
           end
        end
        S1_HASH_FINAL : begin
           // Hash Operation Code
           hash_op   = {2'b00, s1_flg_384, 2'b10};
           msg_size  = size1;
           if(hash_rdy) begin
              hash_en   = 1;
              // Wait Hash Final Done and Clear S1 PRM
              state_nxt = S0_SUCCESS;
           end
        end
        // HMAC Data Channel
        S1_HMAC_RXD  : begin
           hash_op = {2'b01, s1_flg_384, 2'b01};
           if(msg_update) begin
              hash_en    = 1;
           end else if(m_buf_rdy & hash_rdy) begin
              // Send Success Code
              state_nxt  = S1_SUCCESS;
           end
        end
        S1_HMAC_BCD  : begin
           cmd_rdy       = 1;
           hash_op       = {2'b01, s1_flg_384, 2'b01};
           if(cmd_en) begin
              state_nxt = RESP_ERR_PRM;
           end else if(msg_update) begin
              hash_en    = 1;
           end else if(m_buf_rdy & hash_rdy) begin
              // Done Then Go to IDLE
              state_nxt  = IDLE;
           end
        end
        S1_WR_KEY   : begin
           k_buf_wr      = 1;
           if(rcv_done) begin
              state_nxt   = S1_SUCCESS;
           end
        end
        S1_PRF_WA    : begin
           if(m_buf_rdy) begin
              m_buf_op  = 2'b01;
              m_buf_en  = 1;
              size1_op  = 2'b11;
              size1_en  = 1;
              state_nxt = S1_PRF_WD;
           end
        end
        S1_PRF_WD    : begin
           if(m_buf_rdy) begin
              state_nxt = S1_PRF_INIT;
           end
        end
        S1_PRF_INIT  : begin
           hash_op   = {2'b01, s1_flg_384, 2'b00};
           if(hash_rdy) begin
              hash_en   = 1;
              state_nxt = S1_PRF_R0;
           end
        end
        S1_PRF_R0    : begin
           msg_size  = size1;
           if(s1_flg_384 | size1 < 32'd32) begin
              hash_op   = {2'b01, s1_flg_384, 2'b10};
           end else begin
              hash_op   = {2'b01, s1_flg_384, 2'b01};
           end
           if(hash_rdy) begin
              hash_en   = 1;
              if(s1_flg_384 | size1 < 32'd32) begin
                 state_nxt = S1_PRF_N;
              end else begin
                 state_nxt = S1_PRF_R1;
              end
           end
        end
        S1_PRF_R1    : begin
           msg_size  = size1;
           msg_sel   = 2'b01;
           hash_op   = {2'b01, s1_flg_384, 2'b10};
           if(hash_rdy) begin
              hash_en   = 1;
              state_nxt = S1_PRF_N;
           end
        end
        S1_PRF_N     : begin
           if(hash_rdy) begin
              prf_up    = 1;
              if(!flg_prf) begin
                 state_nxt  = S1_PRF_EXTD;
                 size1_op   = 2'b11;
                 size1_en   = 1;
                 m_prf_i    = 1;
              end else if(prf_clr)begin
                 hash_clr  = 1;
                 state_nxt = S0_SUCCESS;
              end else if(prf_done) begin
                 state_nxt = S0_SUCCESS;
              end else begin
                 state_nxt = S1_PRF_SD_I;
              end
           end
        end
        S1_PRF_EXTD  : begin
           m_prf_u   = 1;
           state_nxt = S1_PRF_INIT;
        end
        S1_PRF_SD_I  : begin
           hash_op   = {2'b01, s1_flg_384, 2'b00};
           if(hash_rdy) begin
              hash_en   = 1;
              state_nxt = S1_PRF_SD_R;
           end
        end
        S1_PRF_SD_R  : begin
           hash_op   = {2'b01, s1_flg_384, 2'b10};
           msg_sel   = {1'b1, s1_flg_384};
           if(s1_flg_384) begin
              msg_size = 32'd48;
           end else begin
              msg_size = 32'd32;
           end
           if(hash_rdy) begin
              hash_en   = 1;
              state_nxt = S1_PRF_SD_F;
           end
        end
        S1_PRF_SD_F : begin
           if(hash_rdy) begin
              m_prf_u   = 1;
              state_nxt = S1_PRF_INIT;
           end
        end
        S1_SUCCESS : begin
           if(hash_rdy) begin
              resp_done    = 1;
              state_nxt    = IDLE;
           end
        end
      endcase // case (state)
   end
endmodule // hash_core_cu
