module moo_ccm_d (/*AUTOARG*/
   // Outputs
   ccm_d,
   // Inputs
   clk, rst_n, clr_core, ccm_d_op, ccm_d_en, ccm_d_clr, ccm_b0, iv, ecb_do,
   xfb_do, wb_d, size_msg, msg_done
   ) ;
   input           clk, rst_n;
   input           clr_core;

   input [1:0]     ccm_d_op;
   input           ccm_d_en;
   input           ccm_d_clr;

   input [7:0]     ccm_b0;
   input [119:0]   iv;

   input [127:0]   ecb_do;
   input [127:0]   xfb_do;
   input [127:0]   wb_d;

   output [127:0]  ccm_d;

   reg [127:0]     ccm_d;
   reg [127:0]     ccm_i;

   input [31:0]    size_msg;
   input           msg_done;

   wire [127:0]    dec_msk;
   wire [127:0]    dec_sel;
   wire            block_n;

   wire [127:0]    dec_i;
   wire [127:0]    enc_i;

   assign dec_msk = {128{1'b1}} >> {size_msg[3:0], 3'd0};
   assign block_n = (size_msg[3:0] == 4'd0) ? 0 : 1;
   assign dec_sel = (block_n & msg_done) ? (xfb_do & (~dec_msk)) : xfb_do;
   assign dec_i   = ccm_d ^ dec_sel;
   assign enc_i   = ccm_d ^ wb_d;


   localparam CCM_SET_B0  = 2'b00;
   localparam CCM_SET_ECB = 2'b01;
   localparam CCM_SET_DEC = 2'b10;
   localparam CCM_SET_ENC = 2'b11;

   always @ (*) begin
      case (ccm_d_op)
        CCM_SET_B0  : ccm_i = {ccm_b0, iv[119:32], (iv[31:0] | size_msg)};
        CCM_SET_ECB : ccm_i = ecb_do;
        CCM_SET_DEC : ccm_i = dec_i;
        CCM_SET_ENC : ccm_i = enc_i;
      endcase // case (ccm_d_op)
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         ccm_d <= 128'd0;
      end else begin
         if(clr_core | ccm_d_clr) begin
            ccm_d <= 128'd0;
         end else if(ccm_d_en) begin
            ccm_d <= ccm_i;
         end
      end
   end

endmodule // moo_ccm_d
