//localparam MOO_CMAC     = 4'h0; // CLEAR
//localparam MOO_ECB      = 4'h1;
//localparam MOO_CBC      = 4'h2; // WB_D
//localparam MOO_OFB      = 4'h3;
//localparam MOO_CFB      = 4'h4;
//localparam MOO_CTR      = 4'h5;
//localparam MOO_CCM_A0   = 4'h6; // CCM
//localparam MOO_CCM_AK   = 4'h7; // CCM
//localparam MOO_GCM_N16  = 4'h8; // WB_D + 1
//localparam MOO_GCM_GHS  = 4'h9; // GHASH
//localparam TLS_CBC_SW   = 4'hA; // SW_IV
//localparam TLS_CBC_CW   = 4'hB; // CW_IV
//localparam TLS_CCM_SW   = 4'hC; // HD + CCM
//localparam TLS_CCM_CW   = 4'hD; // CCM
//localparam TLS_GCM_SW   = 4'hE; // SW_IV + WB_D + 32'd1
//localparam TLS_GCM_CW   = 4'hF; // CW_IV + WB_D + 32'd1
module moo_iv_buf (/*AUTOARG*/
   // Outputs
   init_size, moo_op, moo_add, flg_hmac_dec, flg_hmac_enc, flg_rb_xfb, iv,
   ccm_b0,
   // Inputs
   clk, rst_n, clr_core, wb_d, sw_iv, cw_iv, ghash, cmd_op, wr_size, iv_en,
   iv_clr, iv_gnc
   ) ;
   input           clk, rst_n;
   input           clr_core;

   input [127:0]   wb_d;
   input [127:0]   sw_iv;
   input [127:0]   cw_iv;
   input [127:0]   ghash;

   input [4:0]     cmd_op;
   input [15:0]    wr_size;

   input           iv_en;
   input           iv_clr;
   input           iv_gnc;
   // NEW ADDED
   output [15:0]   init_size;

   output [3:0]    moo_op;
   output          moo_add;

   output          flg_hmac_dec, flg_hmac_enc;
   output          flg_rb_xfb;

   output [127:0]  iv;
   output [7:0]    ccm_b0;

   reg [127:0]     iv;
   reg [7:0]       ccm_b0;
   reg [3:0]       moo_op;
   reg             moo_add;
   reg             flg_hmac_dec;
   reg             flg_hmac_enc;
   reg             flg_rb_xfb;
   reg [15:0]      init_size;

   wire            ccm_err; // N SIZE OVER
   wire [15:0]     ccm_size;
   assign ccm_err  = (wr_size > 16'd17) ? 1'b1 : 1'b0;
   assign ccm_size = ccm_err ? 16'd0 : wr_size;

   always @ (*) begin
      case (cmd_op[3:0])
        4'h0 : init_size = 16'd4;
        4'h1 : init_size = 16'd4;
        4'h2 : init_size = 16'd20;
        4'h3 : init_size = 16'd20;
        4'h4 : init_size = 16'd20;
        4'h5 : init_size = 16'd20;
        4'h6 : init_size = wr_size;
        4'h7 : init_size = wr_size;
        4'h8 : init_size = 16'd16;
        4'h9 : init_size = wr_size;
        4'hA : init_size = 16'd4;
        4'hB : init_size = 16'd4;
        4'hC : init_size = 16'd12;
        4'hD : init_size = 16'd12;
        4'hE : init_size = 16'd12;
        4'hF : init_size = 16'd12;
      endcase // case (iv_di_op)
   end



   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_hmac_dec <= 1'b0;
         flg_hmac_enc <= 1'b0;
      end else begin
         if(iv_clr | clr_core) begin
            flg_hmac_dec <= 1'b0;
            flg_hmac_enc <= 1'b0;
         end else if(iv_en & (cmd_op[3:1] == 3'b101)) begin
            flg_hmac_dec <= cmd_op[4];
            flg_hmac_enc <= !cmd_op[4];
         end
      end
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_rb_xfb <= 1'b0;
      end else begin
         if(iv_clr | clr_core) begin
            flg_rb_xfb <= 1'b0;
         end else if(iv_en) begin
            if(cmd_op[3:0] == 4'h1) begin
               flg_rb_xfb <= 1'b0;
            end else if (cmd_op[4:0] == 5'b00010) begin
               flg_rb_xfb <= 1'b0;
            end else if (cmd_op[4:1] == 4'b0101) begin
               flg_rb_xfb <= 1'b0;
            end else begin
               flg_rb_xfb <= 1'b1;
            end
         end
      end
   end


   wire [4:0]      size_n;
   wire [3:0]      ccm_q;
   wire            flg_add;

   assign size_n   = wr_size[4:0] - 5'd4;
   assign ccm_q    = 4'd14 - size_n[3:0];
   assign flg_add  = (cmd_op[3:0] == 4'h7) ? 1'b1 : 1'b0;


   wire [7:0]      moo_fb;
   wire [7:0]      tls_fb;
   wire [7:0]      ccm_fb;
   assign moo_fb   = {1'b0, flg_add, 3'b111, ccm_q[2:0]};
   assign tls_fb   = 8'b01111010;
   assign ccm_fb   = cmd_op[3] ? tls_fb : moo_fb;


   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         ccm_b0 <= 8'd0;
      end else begin
         if(clr_core | iv_clr) begin
            ccm_b0 <= 8'd0;
         end else if(iv_en) begin
            ccm_b0 <= ccm_fb;
         end
      end
   end

   wire [127:0]    ccm_n;
   assign ccm_n    = {5'd0, ccm_q[2:0], wb_d[127:8]};


   reg [127:0]     iv_i;
   always @ (*) begin
      case (cmd_op[3:0])
        4'h0 : iv_i = 128'd0;
        4'h1 : iv_i = 128'd0;
        4'h2 : iv_i = wb_d;
        4'h3 : iv_i = wb_d;
        4'h4 : iv_i = wb_d;
        4'h5 : iv_i = wb_d;
        4'h6 : iv_i = ccm_n;
        4'h7 : iv_i = ccm_n;
        4'h8 : iv_i = {wb_d[127:32], 32'd1};
        4'h9 : iv_i = ghash;
        4'hA : iv_i = sw_iv;
        4'hB : iv_i = cw_iv;
        4'hC : iv_i = {8'd2, sw_iv[127:96], wb_d[127:64], 24'd0};
        4'hD : iv_i = {8'd2, cw_iv[127:96], wb_d[127:64], 24'd0};
        4'hE : iv_i = {sw_iv[127:96], wb_d[127:64], 32'd1};
        4'hF : iv_i = {cw_iv[127:96], wb_d[127:64], 32'd1};
      endcase // case (iv_di_op)
   end

   reg   add_i;
   always @ (*) begin
      case (cmd_op[3:0])
        4'h7, 4'hC, 4'hD : add_i = 1;
        default : add_i = 0;
      endcase // case (cmd_op[3:0])
   end

   reg   [2:0] mode;
   always @ (*) begin
      case (cmd_op[3:0])
        4'h0 : mode = 3'b000;
        4'h1 : mode = 3'b001;
        4'h2 : mode = 3'b010;
        4'h3 : mode = 3'b011;
        4'h4 : mode = 3'b100;
        4'h5 : mode = 3'b101;
        4'h6 : mode = 3'b110;
        4'h7 : mode = 3'b110;
        4'h8 : mode = 3'b111;
        4'h9 : mode = 3'b111;
        4'hA : mode = 3'b010;
        4'hB : mode = 3'b010;
        4'hC : mode = 3'b110;
        4'hD : mode = 3'b110;
        4'hE : mode = 3'b111;
        4'hF : mode = 3'b111;
      endcase // case (cmd_op[3:0])
   end

   wire   [3:0] moo_i;
   assign moo_i = {cmd_op[4], mode};

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         moo_op   <= 4'd0;
         moo_add  <= 1'b0;
      end else begin
         if(clr_core | iv_clr) begin
            moo_op   <= 4'd0;
            moo_add  <= 1'b0;
         end else if(iv_gnc) begin
            moo_op   <= 4'b1000;
            moo_add  <= 1'b0;
         end else if(iv_en) begin
            moo_op   <= moo_i;
            moo_add  <= add_i;
         end
      end
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         iv <= 128'd0;
      end else begin
         if(clr_core | iv_clr | iv_gnc) begin
            iv <= 128'd0;
         end else if(iv_en) begin
            iv <= iv_i;
         end
      end
   end

endmodule // moo_iv_buf
