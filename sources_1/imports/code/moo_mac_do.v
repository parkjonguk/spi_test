module moo_mac_do (/*AUTOARG*/
   // Outputs
   mac_do,
   // Inputs
   clk, rst_n, clr_core, mac_do_op, mac_do_en, mac_do_clr, ecb_do, ghash, size_msg
   ) ;
   input           clk, rst_n;
   input           clr_core;

   input [1:0]     mac_do_op;
   input           mac_do_en;
   input           mac_do_clr;

   input [127:0]   ecb_do;
   input [127:0]   ghash;
   input [3:0]     size_msg;

   output [127:0]  mac_do;

   reg [127:0]     mac_do;
   reg [127:0]     mac_i;

   localparam MAC_SET_ECB    = 2'b00;
   localparam MAC_SET_CMAC   = 2'b01;
   localparam MAC_SET_CCM    = 2'b10;
   localparam MAC_SET_GCM    = 2'b11;


   wire [127:0]    cmac_k1, cmac_k1_0, cmac_k1_1;
   wire [127:0]    cmac_k2, cmac_k2_0, cmac_k2_1;
   wire [127:0]    cmac_k;

   assign cmac_k1_0 = {ecb_do[126:0], 1'b0};
   assign cmac_k1_1 = {ecb_do[126:0], 1'b0} ^ {120'd0,8'b10000111};
   assign cmac_k1   = (ecb_do[127] == 1'b0) ? cmac_k1_0 : cmac_k1_1;

   assign cmac_k2_0 = {cmac_k1[126:0], 1'b0};
   assign cmac_k2_1 = {cmac_k1[126:0], 1'b0} ^ {120'd0,8'b10000111};
   assign cmac_k2   = (cmac_k1[127] == 1'b0) ? cmac_k2_0 : cmac_k2_1;

   assign cmac_k    = (size_msg == 4'd0) ? cmac_k1 : cmac_k2;


   always @ (*) begin
      case (mac_do_op)
        MAC_SET_ECB  : mac_i = ecb_do;
        MAC_SET_CMAC : mac_i = cmac_k;
        MAC_SET_CCM  : mac_i = mac_do ^ ecb_do;
        MAC_SET_GCM  : mac_i = mac_do ^ ghash;
      endcase // case (mac_do_op)
   end


   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         mac_do <= 128'd0;
      end else begin
         if(clr_core | mac_do_clr) begin
            mac_do <= 128'd0;
         end else if(mac_do_en) begin
            mac_do <= mac_i;
         end
      end
   end

endmodule // moo_mac_do
