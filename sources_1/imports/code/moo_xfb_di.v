module moo_xfb_di (/*AUTOARG*/
   // Outputs
   xfb_di,
   // Inputs
   clk, rst_n, clr_core, xfb_di_op, xfb_di_en, xfb_di_clr, wb_d, ecb_di, ccm_d, mac_do
   ) ;
   input           clk, rst_n;
   input           clr_core;

   input [1:0]     xfb_di_op;
   input           xfb_di_en;
   input           xfb_di_clr;

   input [127:0]   wb_d;
   input [127:0]   ecb_di;
   input [127:0]   ccm_d;
   input [127:0]   mac_do;

   output [127:0]  xfb_di;
   reg    [127:0]  xfb_di;
   reg    [127:0]  xfb_i;

   localparam XFB_SET_WB   = 2'b00;
   localparam XFB_SET_ECB  = 2'b01;
   localparam XFB_SET_CCM  = 2'b10;
   localparam XFB_SET_MAC  = 2'b11;

   wire [127:0]    cmac_l;
   assign cmac_l   = mac_do ^ wb_d;

   always @ (*) begin
      case (xfb_di_op)
        XFB_SET_WB   : xfb_i = wb_d;
        XFB_SET_ECB  : xfb_i = ecb_di;
        XFB_SET_CCM  : xfb_i = ccm_d;
        XFB_SET_MAC  : xfb_i = cmac_l;
      endcase // case (xfb_di_op)
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         xfb_di <= 128'd0;
      end else begin
         if(xfb_di_clr | clr_core) begin
            xfb_di <= 128'd0;
         end else if(xfb_di_en) begin
            xfb_di <= xfb_i;
         end
      end
   end

endmodule // moo_xfb_di
