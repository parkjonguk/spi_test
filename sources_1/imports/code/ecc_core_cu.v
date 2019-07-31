module ecc_core_cu (/*AUTOARG*/
   // Outputs
   cmd_rdy, resp_done, resp_veri, resp_err, rd_open, wr_open, load_hash,
   load_key, load_res, load_d, set_clr, ecdh_sk_update, load_rcv, ecc_clr,
   ecc_en,
   // Inputs
   clk, rst_n, clr_ecc, ss_expire, cmd_en, cmd_op, wr_size, cmd_extend,
   flg_d_zero, flg_k_zero, rcv_done, verify, ecc_rdy
   ) ;
   input           clk, rst_n;
   input           clr_ecc;
   input           ss_expire;
   // L3 Communication
   output          cmd_rdy;
   input           cmd_en;
   input [7:0]     cmd_op;
   input [15:0]    wr_size;
   input [15:0]    cmd_extend;

   input           flg_d_zero;
   input           flg_k_zero;

   output          resp_done;
   output          resp_veri;
   output [1:0]    resp_err;

   output          rd_open;
   output          wr_open;

   output          load_hash;
   output          load_key;
   output          load_res;
   output          load_d;
   output          set_clr;
   output          ecdh_sk_update;

   output          load_rcv;
   input           rcv_done;
   input           verify;

   input           ecc_rdy;
   output          ecc_clr;
   output          ecc_en;


   reg             cmd_rdy;
   reg             resp_done;
   reg             resp_veri;
   reg [1:0]       resp_err;
   reg             rd_open;
   reg             wr_open;
   reg             load_hash;
   reg             load_key;
   reg             load_res;
   reg             load_d;
   reg             load_rcv;
   reg             set_clr;
   reg             ecdh_sk_update;

   reg             ecc_clr, ecc_en;


   localparam ERR_CMD      = 2'b01;
   localparam ERR_SIZE     = 2'b10;
   localparam ERR_PRM      = 2'b11;


   localparam IDLE            = 19'b0000000000000000001;
   localparam CMD_ECDH_SK     = 19'b0000000000000000010;
   localparam CMD_ECDSA_SIGN  = 19'b0000000000000000100;
   localparam CMD_ECDSA_VERI  = 19'b0000000000000001000;
   localparam CMD_ECDH_PK     = 19'b0000000000000010000;
   localparam CMD_WR_D        = 19'b0000000000000100000;
   localparam CLEAR           = 19'b0000000000001000000;
   localparam HASH_SETUP      = 19'b0000000000010000000;
   localparam WAIT_WR         = 19'b0000000000100000000;
   localparam ECC_RUN         = 19'b0000000001000000000;
   localparam WAIT_ECC        = 19'b0000000010000000000;
   localparam ECDH_SK         = 19'b0000000100000000000;
   localparam ECDSA_SIGN      = 19'b0000001000000000000;
   localparam ECDSA_VERI      = 19'b0000010000000000000;
   localparam ECDH_PK         = 19'b0000100000000000000;
   localparam DONE            = 19'b0001000000000000000;
   localparam RESP_ERR_CMD    = 19'b0010000000000000000;
   localparam RESP_ERR_SIZE   = 19'b0100000000000000000;
   localparam RESP_ERR_PRM    = 19'b1000000000000000000;

   reg [18:0]      state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(clr_ecc | ss_expire) begin
            state <= CLEAR;
         end else begin
            state <= state_nxt;
         end
      end
   end

   always @ (*) begin
      state_nxt     = state;
      cmd_rdy       = 0;
      load_hash     = 0;
      load_key      = 0;
      load_res      = 0;
      load_d        = 0;
      set_clr       = 0;
      rd_open       = 0;
      wr_open       = 0;
      load_rcv      = 0;
      resp_veri     = 0;
      resp_done     = 0;
      resp_err      = 2'b00;
      ecc_en        = 0;
      ecc_clr       = 0;
      ecdh_sk_update = 0;
      case (state)
        IDLE : begin
           cmd_rdy    = 1;
           if(cmd_en) begin
              if(cmd_op < 8'd6) begin
                 state_nxt = CMD_ECDH_SK << cmd_op[2:0];
                 load_key  = 1;
              end else begin
                 state_nxt = RESP_ERR_CMD;
              end
           end
        end
        CMD_ECDH_SK : begin
           if((cmd_extend != 16'd0) | (wr_size != 16'd64)) begin
              state_nxt = RESP_ERR_SIZE;
           end else if(flg_k_zero)begin
              state_nxt = RESP_ERR_PRM;
           end else begin
              state_nxt = WAIT_WR;
              wr_open   = 1;
              load_rcv  = 1;
           end
        end
        CMD_ECDSA_SIGN : begin
           if(cmd_extend != 16'd64) begin
              state_nxt = RESP_ERR_SIZE;
           end else if(flg_k_zero)begin
              state_nxt = RESP_ERR_PRM;
           end else if(wr_size == 16'd0) begin // y
              state_nxt = HASH_SETUP;
              load_d    = 1;
           end else if(wr_size == 16'd32) begin ///D
              state_nxt = WAIT_WR;
              load_rcv  = 1;
              wr_open   = 1;
              load_hash = 1;
           end else if(wr_size == 16'd64) begin // D + HASH
              state_nxt = WAIT_WR;
              wr_open   = 1;
              load_rcv  = 1;
           end else begin
              state_nxt = RESP_ERR_SIZE;
           end
        end
        CMD_ECDSA_VERI : begin
           if(cmd_extend != 16'd0) begin
              state_nxt = RESP_ERR_SIZE;
           end else if(flg_k_zero)begin
              state_nxt = RESP_ERR_PRM;
           end else if(wr_size == 16'd128) begin  // Q + R + S
              state_nxt = WAIT_WR;
              load_hash = 1;
              wr_open   = 1;
              load_rcv  = 1;
           end else if(wr_size == 16'd160) begin // Q + R + S + HASH
              state_nxt = WAIT_WR;
              wr_open   = 1;
              load_rcv  = 1;
           end else begin
              state_nxt = RESP_ERR_SIZE;
           end
        end
        CMD_ECDH_PK : begin
           if((cmd_extend != 16'd64)|(wr_size != 16'd0)) begin
              state_nxt = RESP_ERR_SIZE;
           end else if(flg_k_zero)begin
              state_nxt = RESP_ERR_PRM;
           end else begin
              state_nxt = ECC_RUN;
           end
        end
        CMD_WR_D : begin
           if((cmd_extend != 16'd0)|(wr_size != 16'd32)) begin
              state_nxt = RESP_ERR_SIZE;
           end else begin
              state_nxt = WAIT_WR;
              wr_open   = 1;
              load_rcv  = 1;
           end
        end
        CLEAR : begin
           ecc_clr    = 1;
           set_clr    = 1;
           state_nxt  = DONE;
        end
        HASH_SETUP : begin
           wr_open    = 1;
           load_rcv   = 1;
           load_hash  = 1;
           state_nxt  = WAIT_WR;
        end
        WAIT_WR : begin
           if(rcv_done) begin
              if(cmd_op[2:0] == 3'b100) begin
                 state_nxt = DONE;
              end else begin
                 state_nxt = ECC_RUN;
              end
           end
        end
        ECC_RUN : begin
           if((cmd_op[1:0] == 2'b01) & flg_d_zero) begin
              state_nxt = RESP_ERR_PRM;
           end else if((cmd_op[1:0] == 2'b10) & flg_d_zero) begin
              state_nxt = RESP_ERR_PRM;
           end else begin
              state_nxt  = WAIT_ECC;
              ecc_en     = 1;
           end
        end
        WAIT_ECC : begin
           if(ecc_rdy) begin
              state_nxt = ECDH_SK << cmd_op[1:0];
              set_clr        = 1;
           end
        end
        ECDH_SK : begin
           ecdh_sk_update = 1;
           ecc_clr        = 1;
           state_nxt      = DONE;
        end
        ECDSA_SIGN : begin
           ecc_clr        = 1;
           load_res       = 1;
           rd_open        = 1;
           state_nxt      = DONE;
        end
        ECDSA_VERI : begin
           ecc_clr        = 1;
           resp_done      = 1;
           resp_veri      = verify;
           state_nxt      = IDLE;
        end
        ECDH_PK : begin
           load_res       = 1;
           ecc_clr        = 1;
           rd_open        = 1;
           state_nxt      = DONE;
        end
        DONE : begin
           state_nxt = IDLE;
           resp_done = 1;
        end
        RESP_ERR_CMD : begin
           state_nxt = IDLE;
           resp_done = 1;
           resp_err  = ERR_CMD;
        end
        RESP_ERR_PRM : begin
           state_nxt = IDLE;
           resp_done = 1;
           resp_err  = ERR_PRM;
        end
        RESP_ERR_SIZE : begin
           state_nxt = IDLE;
           resp_done = 1;
           resp_err  = ERR_SIZE;
        end
      endcase // case (state)
   end


endmodule // ecc_core_cu
