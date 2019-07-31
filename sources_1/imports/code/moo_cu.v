module moo_cu (/*AUTOARG*/
   // Outputs
   aria_op, aria_en, aria_clr, xfb_clr, xfb_en, ecb_clr, ecb_en, ecb_di_clr,
   ecb_di_en, ecb_iv_en, ctr_4w, ctr_4b, xfb_di_clr, xfb_di_en, xfb_di_op,
   mac_do_clr, mac_do_en, mac_do_op, ccm_d_clr, ccm_d_en, ccm_d_op, moo_key_rdy,
   moo_di_rdy, moo_do_vld, moo_add_rdy, moo_done, moo_rdy,
   // Inputs
   clk, rst_n, clr_core, key_size, moo_op, moo_en, moo_add, moo_clr, r_ready,
   k_ready, msg_done, moo_di_vld, moo_di_lst, moo_do_rdy, moo_add_vld,
   moo_add_lst, gcm_mac_final
   ) ;
   input           clk, rst_n;
   input           clr_core;

   input [1:0]     key_size;
   input [3:0]     moo_op;
   input           moo_en;
   input           moo_add;
   input           moo_clr;

   output [2:0]    aria_op;
   output          aria_en;
   output          aria_clr;
   input           r_ready;
   input           k_ready;
   output          xfb_clr;
   output          xfb_en;
   output          ecb_clr;
   output          ecb_en;

   output          ecb_di_clr;
   output          ecb_di_en;
   output          ecb_iv_en;
   output          ctr_4w;
   output          ctr_4b;

   output          xfb_di_clr;
   output          xfb_di_en;
   output [1:0]    xfb_di_op;

   output          mac_do_clr;
   output          mac_do_en;
   output [1:0]    mac_do_op;

   output          ccm_d_clr;
   output          ccm_d_en;
   output [1:0]    ccm_d_op;

   output          moo_key_rdy;
   input           msg_done;
   input           moo_di_vld;
   input           moo_di_lst;
   output          moo_di_rdy;

   input           moo_do_rdy;
   output          moo_do_vld;
   input           moo_add_vld;
   input           moo_add_lst;
   output          moo_add_rdy;
   output          moo_done;
   output          moo_rdy;
   input           gcm_mac_final;







   reg          moo_rdy;
   reg [2:0]    aria_op;
   reg          aria_en;
   reg          aria_clr;
   reg          xfb_clr;
   reg          xfb_en;
   reg          ecb_clr;
   reg          ecb_en;
   reg          ecb_di_clr;
   reg          ecb_di_en;
   reg          ecb_iv_en;
   reg          ctr_4w;
   reg          ctr_4b;
   reg          xfb_di_clr;
   reg          xfb_di_en;
   reg [1:0]    xfb_di_op;
   reg          mac_do_clr;
   reg          mac_do_en;
   reg [1:0]    mac_do_op;
   reg          ccm_d_clr;
   reg          ccm_d_en;
   reg [1:0]    ccm_d_op;
   reg          moo_key_rdy;
   reg          moo_di_rdy;
   reg          moo_do_vld;
   reg          moo_add_rdy;
   reg          moo_done;

























   
   reg [2:0]       moo_mode;
   reg             moo_dec;
   reg             flg_add, flg_add_down;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         moo_mode <= 3'd0;
         moo_dec  <= 1'b0;
         flg_add  <= 1'b0;
      end else begin
         if(moo_clr | clr_core) begin
            moo_mode <= 3'd0;
            moo_dec  <= 1'b0;
            flg_add  <= 1'b0;
         end else if(moo_en) begin
            moo_mode <= moo_op[2:0];
            moo_dec  <= moo_op[3];
            flg_add  <= moo_add;
         end else if(flg_add_down) begin
            flg_add <= 1'b0;
         end
      end
   end


   localparam IDLE           = 22'b0000000000000000000001;
   localparam RKEY           = 22'b0000000000000000000010;
   localparam MOO_RDY        = 22'b0000000000000000000100;
   localparam MOO_INIT       = 22'b0000000000000000001000;
   localparam ENC_MOO        = 22'b0000000000000000010000;
   localparam DI_RDY         = 22'b0000000000000000100000;
   localparam SET_DI         = 22'b0000000000000001000000;
   localparam XFB_DO_RDY     = 22'b0000000000000010000000;
   localparam ECB_ENC        = 22'b0000000000000100000000;
   localparam ECB_SET_TX     = 22'b0000000000001000000000;
   localparam ECB_TX         = 22'b0000000000010000000000;
   localparam XFB_ENC        = 22'b0000000000100000000000;
   localparam CCM_MAC_I      = 22'b0000000001000000000000;
   localparam ENC_MAC_INIT   = 22'b0000000010000000000000;
   localparam SET_MAC_INIT   = 22'b0000000100000000000000;
   localparam SET_CCM_B0     = 22'b0000001000000000000000;
   localparam ENC_CCM_B0     = 22'b0000010000000000000000;
   localparam SET_CCM_B1     = 22'b0000100000000000000000;
   localparam CCM_ADD        = 22'b0001000000000000000000;
   localparam SET_CCM_BK     = 22'b0010000000000000000000;
   localparam ENC_CCM_BK     = 22'b0100000000000000000000;
   localparam DONE           = 22'b1000000000000000000000;

   reg [21:0]      state, state_nxt;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(clr_core | moo_clr) begin
            state <= IDLE;
         end else begin
            state <= state_nxt;
         end
      end
   end
   /* ARIA */

   always @ (*) begin
      state_nxt      = state;
      moo_key_rdy    = 0;
      moo_di_rdy     = 0;
      moo_do_vld     = 0;
      moo_add_rdy    = 0;
      moo_done       = 0;
      aria_op        = 3'b000;
      aria_en        = 0;
      aria_clr       = 0;
      ecb_clr        = 0;
      ecb_en         = 0;
      xfb_clr        = 0;
      xfb_en         = 0;
      ecb_di_clr     = 0;
      ecb_di_en      = 0;
      ecb_iv_en      = 0;
      ctr_4w         = 0;
      ctr_4b         = 0;
      xfb_di_clr     = 0;
      xfb_di_en      = 0;
      xfb_di_op      = 2'b00;
      mac_do_clr     = 0;
      mac_do_en      = 0;
      mac_do_op      = 2'b00;
      ccm_d_en       = 0;
      ccm_d_clr      = 0;
      ccm_d_op       = 2'b00;
      flg_add_down   = 0;
      moo_rdy        = 0;
      case (state)
        IDLE : begin
           moo_key_rdy = k_ready;
           moo_rdy     = 1;
           if(moo_en) begin
              xfb_di_clr = 1;
              mac_do_clr = 1;
              ccm_d_clr  = 1;
              ecb_di_clr = 1;
              if(key_size == 2'd00) begin
                 aria_clr  = 1;
              end else begin
                 aria_op   = {1'b0, key_size};
                 aria_en   = 1;
                 state_nxt = RKEY;
              end
           end
        end
        RKEY : begin
           if(r_ready) begin
              state_nxt = MOO_RDY;
              ecb_clr   = 1;
              xfb_clr   = 1;
           end
        end
        MOO_RDY : begin
           ecb_iv_en  = 1;
           xfb_di_clr = 1;
           mac_do_clr = 1;
           if(moo_mode == 3'b110) begin
              ccm_d_en = 1;
           end else begin
              ccm_d_clr = 1;
           end
           if(moo_mode == 3'b001) begin
              state_nxt = DI_RDY;
           end else begin
              state_nxt = MOO_INIT;
           end
        end
        MOO_INIT : begin
           ecb_en  = 1;
           if(moo_mode == 3'b010) begin
              state_nxt = DI_RDY;
           end else if((moo_mode == 3'b000) | (moo_mode[2:1] == 2'b11))begin
              state_nxt = ENC_MAC_INIT;
           end else begin
              state_nxt = ENC_MOO;
           end
        end
        ENC_MOO : begin
           aria_op = 3'b100;
           aria_en = 1;
           if(moo_mode == 3'b101) begin
              ctr_4w  = 1;
           end else if (moo_mode[2:1] == 2'b11) begin
              ctr_4b  = 1;
           end
           state_nxt = DI_RDY;
        end
        DI_RDY : begin
           if(r_ready) begin
              moo_di_rdy = 1;
              if(msg_done) begin
                 state_nxt = DONE;
              end else if(moo_di_vld) begin
                 state_nxt = SET_DI;
                 xfb_di_en = 1;
                 if((moo_mode == 3'd0) & moo_di_lst) begin
                    xfb_di_op = 2'b11;
                 end if(moo_mode  == 3'd1) begin
                    ecb_di_en = 1;
                 end else if(moo_mode == 3'd2) begin
                    if(moo_dec) begin
                       ecb_di_en = 1;
                       xfb_di_op = 2'b01;
                    end
                 end else if(moo_mode == 3'b100) begin
                    ecb_di_en = 1;
                 end else if((moo_mode == 3'b110) & (!moo_dec)) begin
                    ccm_d_op = 2'b11;
                    ccm_d_en = 1;
                 end
              end
           end
        end
        SET_DI : begin
           xfb_en = 1;
           if(moo_mode == 3'b011) begin
              ecb_en = 0;
           end else begin
              ecb_en = 1;
           end

           if(moo_mode == 3'b000) begin
              state_nxt = XFB_ENC;
           end else if(moo_mode == 3'b001) begin
              state_nxt = ECB_ENC;
           end else if(moo_mode == 3'b010) begin
              state_nxt = ECB_ENC;
           end else begin
              state_nxt = XFB_DO_RDY;
           end
        end
        XFB_DO_RDY : begin
           moo_do_vld = 1;
           if(moo_do_rdy) begin
              if(moo_mode == 3'b110) begin
                 ecb_clr   = 1;
                 state_nxt = CCM_MAC_I;
                 if(moo_dec) begin
                    ccm_d_op = 2'b10;
                    ccm_d_en = 1;
                 end
              end else if(msg_done) begin
                 state_nxt = DONE;
              end else if((moo_mode == 3'b100) & (!moo_dec)) begin
                 state_nxt = XFB_ENC;
              end else begin
                 state_nxt = ENC_MOO;
              end
           end
        end
        ECB_ENC : begin
           aria_en   = 1;
           state_nxt = ECB_SET_TX;
           if(moo_mode == 3'b001) begin
              if(moo_dec) begin
                 aria_op = 3'b110;
              end else begin
                 aria_op = 3'b100;
              end
           end else begin
              if(moo_dec) begin
                 aria_op = 3'b110;
              end else begin
                 aria_op = 3'b101;
              end
           end
        end
        ECB_SET_TX : begin
           if(r_ready) begin
              if((moo_mode == 3'b010) & moo_dec) begin
                 xfb_en = 1;
              end
              state_nxt = ECB_TX;
           end
        end
        ECB_TX : begin
           moo_do_vld = 1;
           if(moo_do_rdy) begin
              if(msg_done) begin
                 state_nxt = DONE;
              end else begin
                 state_nxt = DI_RDY;
              end
           end
        end
        XFB_ENC : begin
           aria_op   = 3'b101;
           aria_en   = 1;
           state_nxt = DI_RDY;
        end
        CCM_MAC_I : begin
           xfb_di_op    = 2'b10;
           xfb_di_en    = 1;
           state_nxt    = SET_CCM_B0;
        end
        ENC_MAC_INIT : begin
           aria_op = 3'b100;
           aria_en = 1;
           ctr_4b  = 1;
           state_nxt = SET_MAC_INIT;
        end
        SET_MAC_INIT : begin
           if(r_ready) begin
              mac_do_en = 1;
              ecb_clr   = 1;
              xfb_clr   = 1;
              if(moo_mode == 3'b000) begin
                 if(moo_dec) begin
                    ccm_d_op  = 2'b01;
                    ccm_d_en  = 1;
                    state_nxt = IDLE;
                 end else begin
                    mac_do_op = 2'b01;
                    state_nxt = DI_RDY;
                 end
              end else begin
                 xfb_di_op = 2'b10;
                 xfb_di_en = 1;
                 state_nxt = SET_CCM_B0;
              end
           end
        end
        SET_CCM_B0 : begin
           xfb_en    = 1;
           state_nxt = ENC_CCM_B0;
        end
        ENC_CCM_B0 : begin
           aria_op = 3'b101;
           aria_en = 1;
           state_nxt = SET_CCM_B1;
        end
        SET_CCM_B1 : begin
           if(r_ready) begin
              ccm_d_op = 2'b01;
              ccm_d_en = 1;
              if((moo_mode == 3'b111) | !flg_add) begin
                 if(msg_done) begin
                    mac_do_op = 2'b10;
                    mac_do_en = 1;
                    state_nxt = DONE;
                 end else begin
                    ecb_en    = 1;
                    state_nxt = ENC_MOO;
                 end
              end else begin
                 state_nxt = CCM_ADD;
              end
           end
        end
        CCM_ADD : begin
           if(r_ready) begin
              moo_add_rdy = 1;
              if(moo_add_vld) begin
                 xfb_di_en   = 1;
                 state_nxt   = SET_CCM_BK;
                 if(moo_add_lst) begin
                    flg_add_down = 1;
                 end
              end
           end
        end
        SET_CCM_BK : begin
           xfb_en    = 1;
           state_nxt = ENC_CCM_BK;
        end
        ENC_CCM_BK : begin
           aria_op = 3'b101;
           aria_en = 1;
           if(flg_add) begin
              state_nxt = CCM_ADD;
           end else begin
              state_nxt = SET_CCM_B1;
           end
        end
        DONE : begin
           moo_done = 1;
           if(gcm_mac_final) begin
              mac_do_op = 2'b11;
              mac_do_en = 1;
           end
        end
      endcase // case (state)
   end
endmodule // moo_cu
