module aria_core_cu (/*AUTOARG*/
   // Outputs
   cmd_rdy, rd_open, resp_done, resp_err, iv_en, iv_clr, iv_gnc, wb_op, wb_en,
   wb_one, wb_d_rdy, rb_op, rb_en, rb_d_vld, kb_op, kb_en, kb_clr, kb_d_vld,
   moo_en, moo_clr, moo_di_vld, moo_di_lst, moo_do_rdy, moo_add_vld,
   moo_add_lst, gcm_mac_final, add_size_en, remain_nxt, remain_up, ghash_op,
   ghash_en, ghash_clr,
   // Inputs
   clk, rst_n, clr_core, flg_hmac_dec, flg_hmac_enc, flg_rb_xfb, ghash_rdy,
   cmd_en, cmd_op, cmd_extend, wr_size, init_size, moo_op, wb_op_rdy, wb_d_vld,
   wb_d_lst, rb_d_rdy, rb_done, kb_d_rdy, moo_done, moo_di_rdy, moo_do_vld,
   moo_add_rdy, moo_rdy, remain_size, msg_lst
   ) ;
   input  clk, rst_n;
   input  clr_core;
   input  flg_hmac_dec;
   input  flg_hmac_enc;
   input  flg_rb_xfb;
   input  ghash_rdy;
   output              cmd_rdy;
   input               cmd_en;
   input [7:0]         cmd_op;
   input [15:0]        cmd_extend;
   input [15:0]        wr_size;
   output              rd_open;
   output              resp_done;
   output [1:0]        resp_err;
   output              iv_en;
   output              iv_clr;
   output              iv_gnc;
   input  [15:0]       init_size;
   input  [3:0]        moo_op;
   input               wb_op_rdy;
   output [1:0]        wb_op;
   output              wb_en;
   output              wb_one;
   output              wb_d_rdy;
   input               wb_d_vld;
   input               wb_d_lst;
   output [1:0]        rb_op;
   output              rb_en;
   output              rb_d_vld;
   input               rb_d_rdy;
   input               rb_done;
   output [1:0]        kb_op;
   output              kb_en;
   output              kb_clr;
   output              kb_d_vld;
   input               kb_d_rdy;
   input               moo_done;
   output              moo_en;
   output              moo_clr;
   output              moo_di_vld;
   output              moo_di_lst;
   input               moo_di_rdy;
   output              moo_do_rdy;
   input               moo_do_vld;
   output              moo_add_vld;
   output              moo_add_lst;
   input               moo_add_rdy;
   input               moo_rdy;
   output              gcm_mac_final;
   output              add_size_en;
   input [31:0]        remain_size;
   input               msg_lst;
   output              remain_nxt;
   output              remain_up;
   output [1:0]        ghash_op;
   output              ghash_en;
   output              ghash_clr;

   localparam MAX_SIZE = 16'd1024;

   reg                 ghash_clr;
   reg                 ghash_en;
   reg [1:0]           ghash_op;
   reg                 cmd_rdy;
   reg                 rd_open;
   reg                 resp_done;
   reg [1:0]           resp_err;
   reg                 iv_en;
   reg                 iv_clr;
   reg                 iv_gnc;
   reg [1:0]           wb_op;
   reg                 wb_en;
   reg                 wb_one;
   reg                 wb_d_rdy;
   reg [1:0]           rb_op;
   reg                 rb_en;
   reg                 rb_d_vld;
   reg [1:0]           kb_op;
   reg                 kb_en;
   reg                 kb_clr;
   reg                 kb_d_vld;
   reg                 moo_en;
   reg                 moo_clr;
   reg                 moo_di_vld;
   reg                 moo_di_lst;
   reg                 moo_do_rdy;
   reg                 moo_add_vld;
   reg                 moo_add_lst;
   reg                 gcm_mac_final;
   reg                 add_size_en;
   reg                 remain_nxt;
   reg                 remain_up;


   localparam IDLE           = 32'b00000000000000000000000000000001;
   localparam CMD_INIT       = 32'b00000000000000000000000000000010; // 1xxxxxxx
   localparam CMD_WRKEY      = 32'b00000000000000000000000000000100; // 0x01
   localparam CMD_RTX        = 32'b00000000000000000000000000001000; // 0x02
   localparam CMD_CCM_ADD    = 32'b00000000000000000000000000010000; // 0x03
   localparam CMD_GCM_ADD    = 32'b00000000000000000000000000100000; // 0x04
   localparam CMD_MAC        = 32'b00000000000000000000000001000000; // 0x05
   localparam CMD_CMAC       = 32'b00000000000000000000000010000000; // 0x06
   localparam CMD_CLEAR      = 32'b00000000000000000000000100000000; // 0x07
   localparam WRKEY          = 32'b00000000000000000000001000000000;
   localparam RTX_OPEN       = 32'b00000000000000000000010000000000;
   localparam MOO_DIO        = 32'b00000000000000000000100000000000;
   localparam RD_DONE        = 32'b00000000000000000001000000000000;
   localparam MOO_CMAC       = 32'b00000000000000000010000000000000;
   localparam CCM_MAC        = 32'b00000000000000000100000000000000;
   localparam GCM_MAC        = 32'b00000000000000001000000000000000;
   localparam GCM_UPDATE     = 32'b00000000000000010000000000000000;
   localparam MOO_CHECK      = 32'b00000000000000100000000000000000;
   localparam IV_WAIT        = 32'b00000000000001000000000000000000;
   localparam GHASH_N16N     = 32'b00000000000010000000000000000000;
   localparam GHASH_ND       = 32'b00000000000100000000000000000000;
   localparam GHASH_NS       = 32'b00000000001000000000000000000000;
   localparam IV_SET_GHASH   = 32'b00000000010000000000000000000000;
   localparam MOO_OP         = 32'b00000000100000000000000000000000;
   localparam MOO_INIT       = 32'b00000001000000000000000000000000;
   localparam WAIT_INIT      = 32'b00000010000000000000000000000000;
   localparam CCM_ADD        = 32'b00000100000000000000000000000000;
   localparam GCM_ADD        = 32'b00001000000000000000000000000000;
   localparam DONE           = 32'b00010000000000000000000000000000;
   localparam RESP_ERR_CMD   = 32'b00100000000000000000000000000000;
   localparam RESP_ERR_PRM   = 32'b01000000000000000000000000000000;
   localparam RESP_ERR_SIZE  = 32'b10000000000000000000000000000000;

   localparam ERR_CMD      = 2'b01;
   localparam ERR_SIZE     = 2'b10;
   localparam ERR_PRM      = 2'b11;

   reg [31:0]          state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(clr_core) begin
            state <= IDLE;
         end else begin
            state <= state_nxt;
         end
      end
   end



   reg   flg_gcm, flg_gcm_up, flg_gcm_down;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_gcm <= 1'b0;
      end else begin
         if(flg_gcm_down | clr_core) begin
            flg_gcm <= 1'b0;
         end else if(flg_gcm_up) begin
            flg_gcm <= 1'b1;
         end
      end
   end


   always @ (*) begin
      state_nxt      = state;
      cmd_rdy        = 0;
      rd_open        = 0;
      resp_done      = 0;
      resp_err       = 2'b00;
      iv_en          = 0;
      iv_clr         = 0;
      iv_gnc         = 0;
      wb_op          = 2'b00;
      wb_en          = 0;
      wb_one         = 0;
      wb_d_rdy       = 0;
      rb_op          = 2'b00;
      rb_en          = 0;
      rb_d_vld       = 0;
      kb_op          = 2'b00;
      kb_en          = 0;
      kb_clr         = 0;
      kb_d_vld       = 0;
      gcm_mac_final  = 0;
      moo_add_lst    = 0;
      moo_add_vld    = 0;
      moo_do_rdy     = 0;
      moo_di_vld     = 0;
      moo_di_lst     = 0;
      moo_en         = 0;
      moo_clr        = 0;
      ghash_op       = 2'b00;
      ghash_en       = 0;
      ghash_clr      = 0;
      flg_gcm_up     = 0;
      flg_gcm_down   = 0;
      add_size_en    = 0;
      remain_nxt     = 0;
      remain_up      = 0;
      case (state)
        IDLE : begin
           cmd_rdy   = 1;
           if(cmd_en) begin
              if(cmd_op[7]) begin
                 state_nxt = CMD_INIT;
              end else if(cmd_op[7:3] == 5'd0) begin
                 if(cmd_op[2:0] == 5'd0) begin
                    state_nxt = RESP_ERR_CMD;
                 end else begin
                    state_nxt = CMD_INIT  << cmd_op[2:0];
                 end
              end else begin
                 state_nxt = RESP_ERR_CMD;
              end
           end
        end
        CMD_INIT : begin
           if((wr_size != init_size) | (cmd_extend != 16'd0)) begin
              state_nxt = RESP_ERR_SIZE;
           end else if(cmd_op[6:5] == 2'b00) begin
              state_nxt = RESP_ERR_PRM;
           end else if(wb_op_rdy)begin
              wb_one    = 1;
              moo_clr   = 1;
              state_nxt = MOO_CHECK;
           end
        end
        CMD_WRKEY : begin
           if((wr_size > 16'd32) | (cmd_extend != 16'd0)) begin
              state_nxt = RESP_ERR_SIZE;
           end else begin
              wb_en  = 1;
              kb_en  = 1;
              if(wr_size > 16'd16) begin
                 kb_op = 2'b01;
              end
              state_nxt = WRKEY;
           end
        end
        CMD_RTX : begin
           if((!moo_di_rdy) | (moo_op == 4'b0000)) begin
              state_nxt = RESP_ERR_PRM;
           end else if((cmd_extend != wr_size) | (wr_size == 16'd0)) begin
              state_nxt = RESP_ERR_SIZE;
           end else if({16'd0, wr_size} > remain_size) begin
              state_nxt = RESP_ERR_SIZE;
           end else if(wr_size > MAX_SIZE) begin
              state_nxt = RESP_ERR_SIZE;
           end else if({16'd0, wr_size} == remain_size) begin
              state_nxt = RTX_OPEN;
           end else if(wr_size[3:0] == 4'd0) begin
              state_nxt = RTX_OPEN;
           end else begin
              state_nxt = RESP_ERR_SIZE;
           end
        end
        CMD_CCM_ADD : begin
           if((moo_op[2:0] != 3'b110) | (!moo_add_rdy)) begin
              state_nxt = RESP_ERR_PRM;
           end else if((cmd_extend != 16'd0) | (wr_size == 16'd0)) begin
              state_nxt = RESP_ERR_SIZE;
           end else begin
              state_nxt    = CCM_ADD;
              wb_en        = 1;
              wb_op        = 2'b01;
              add_size_en  = 1;
           end
        end
        CMD_GCM_ADD : begin
           if((moo_op[2:0] != 3'b111) | flg_gcm) begin
              state_nxt = RESP_ERR_PRM;
           end else if((cmd_extend != 16'd0) | (wr_size == 16'd0)) begin
              state_nxt = RESP_ERR_SIZE;
           end else begin
              state_nxt    = GCM_ADD;
              wb_en        = 1;
              flg_gcm_up   = 1;
              add_size_en  = 1;
           end
        end
        CMD_MAC : begin
           if((!moo_done) | (moo_op[2:1] != 2'b11)) begin
              state_nxt = RESP_ERR_PRM;
           end else if(wr_size != 16'd0) begin
              state_nxt = RESP_ERR_SIZE;
           end else if(cmd_extend > 16'd16) begin
              state_nxt = RESP_ERR_SIZE;
           end else begin
              rb_op = 2'b11;
              rb_en = 1;
              if(moo_op[0]) begin
                 state_nxt = GCM_MAC;
              end else begin
                 state_nxt = CCM_MAC;
              end
           end
        end
        CMD_CMAC : begin
           if((!moo_di_rdy) | (moo_op != 4'd0)) begin
              state_nxt = RESP_ERR_PRM;
           end else if(cmd_extend > 16'd16) begin
              state_nxt = RESP_ERR_SIZE;
           end else if({16'd0, wr_size} != remain_size)begin
              state_nxt = RESP_ERR_SIZE;
           end else begin
              wb_op = 2'b11;
              wb_en = 1;
              rb_en = 1;
              state_nxt = MOO_CMAC;
           end
        end
        CMD_CLEAR : begin
           kb_clr    = 1;
           moo_clr   = 1;
           ghash_clr = 1;
           state_nxt = DONE;
        end
        WRKEY : begin
           wb_d_rdy = kb_d_rdy;
           kb_d_vld = wb_d_vld;
           if(wb_op_rdy) begin
              state_nxt = DONE;
           end
        end
        RTX_OPEN : begin
           wb_en  = 1;
           rb_en  = 1;
           if(flg_hmac_dec) begin
              wb_op = 2'b10;
           end
           if(flg_hmac_enc) begin
              rb_op = 2'b10;
           end else if (flg_rb_xfb) begin
              rb_op = 2'b01;
           end
           state_nxt = MOO_DIO;
        end
        MOO_DIO : begin
           wb_d_rdy   = moo_di_rdy;
           moo_di_vld = wb_d_vld;
           moo_di_lst = wb_d_lst & msg_lst;
           rb_d_vld   = moo_do_vld;
           moo_do_rdy = rb_d_rdy;
           remain_nxt = moo_di_rdy & moo_di_vld;
           if(rb_done) begin
              state_nxt = RD_DONE;
           end
           if(moo_op == 4'b1111) begin
              ghash_en = moo_di_rdy & moo_di_vld;
           end else if(moo_op == 4'b0111) begin
              ghash_op = 2'b01;
              ghash_en = moo_do_rdy & moo_do_vld;
           end
        end
        RD_DONE : begin
           if(rb_done) begin
              rd_open   = 1;
              state_nxt = IDLE;
           end
        end
        MOO_CMAC : begin
           wb_d_rdy   = moo_di_rdy;
           moo_di_vld = wb_d_vld;
           moo_di_lst = wb_d_lst;
           remain_nxt = moo_di_rdy & moo_di_vld;
           if(moo_done & rb_d_rdy) begin
              rb_d_vld  = 1;
              state_nxt = RD_DONE;
           end
        end
        CCM_MAC : begin
           if(rb_d_rdy) begin
              rb_d_vld  = 1;
              state_nxt = RD_DONE;
           end
        end
        GCM_MAC : begin
           ghash_op  = 2'b11;
           ghash_en  = 1;
           state_nxt = GCM_UPDATE;
        end
        GCM_UPDATE : begin
           if(ghash_rdy) begin
              state_nxt     = CCM_MAC;
              gcm_mac_final = 1;
           end
        end
        MOO_CHECK : begin
           if(wb_op_rdy) begin
              remain_up = 1;
              if(cmd_op[3:0] == 4'h9) begin
                 iv_gnc      = 1;
                 state_nxt   = GHASH_N16N;
              end else begin
                 if(wr_size == 16'd4) begin
                    state_nxt   = MOO_OP;
                 end else begin
                    wb_en  = 1;
                    state_nxt   = IV_WAIT;
                 end
              end
              if(cmd_op[3:0] > 4'h9) begin
                 kb_op = {1'b1, cmd_op[0]};
                 kb_en = 1;
              end
           end
        end
        IV_WAIT : begin
           if(wb_d_vld) begin
              state_nxt   = MOO_OP;
           end
        end
        GHASH_N16N : begin
           moo_en    = 1;
           state_nxt = GHASH_ND;
        end
        GHASH_ND : begin
           if(moo_rdy & ghash_rdy) begin
              wb_d_rdy   = 1;
              if(wb_d_vld) begin
                 ghash_op  = 2'b00;
                 ghash_en  = 1;
                 if(wb_d_lst) begin
                    state_nxt = GHASH_NS;
                 end
              end
           end
        end
        GHASH_NS : begin
           if(ghash_rdy) begin
              ghash_op = 2'b10;
              ghash_en = 1;
              state_nxt = IV_SET_GHASH;
           end
        end
        IV_SET_GHASH : begin
           if(ghash_rdy) begin
              state_nxt   = MOO_OP;
           end
        end
        MOO_OP : begin
           ghash_clr   = 1;
           moo_clr     = 1;
           iv_en       = 1;
           wb_d_rdy    = 1;
           state_nxt   = MOO_INIT;
        end
        MOO_INIT : begin
           moo_en    = 1;
           state_nxt = WAIT_INIT;
        end
        WAIT_INIT : begin
           if(moo_di_rdy | moo_add_rdy) begin
              state_nxt    = DONE;
              flg_gcm_down = 1;
           end
        end
        CCM_ADD : begin
           moo_add_lst    = wb_d_lst;
           moo_add_vld    = wb_d_vld;
           wb_d_rdy       = moo_add_rdy;
           if(moo_di_rdy) begin
              state_nxt = DONE;
           end
        end
        GCM_ADD : begin
           if(wb_op_rdy & ghash_rdy) begin
              state_nxt = DONE;
           end else if(ghash_rdy & wb_d_vld) begin
              wb_d_rdy = 1;
              ghash_en = 1;
           end
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


endmodule // aria_core_cu
