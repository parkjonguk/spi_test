module ss_mngr (/*AUTOARG*/
   // Outputs
   ssid, ssid_vld, err_id,
   // Inputs
   clk, rst_n, clr_mk, ss_set, ss_clr, l3_id
   ) ;
   input           clk, rst_n;
   input           clr_mk;

   input           ss_set;
   input           ss_clr;

   input [3:0]     l3_id;
   output [2:0]    ssid;
   output          ssid_vld;
   output          err_id;


   reg [2:0]       ssid;
   reg             ssid_vld;

   wire            err_id;

   assign err_id = (l3_id != {1'b0, ssid}) ? 1 : 0;


   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         ssid_vld <= 1'b0;
         ssid     <= 3'd0;
      end else begin
         if(ss_clr | clr_mk) begin
            ssid_vld <= 1'b0;
            ssid     <= 3'd0;
         end else if(ss_set) begin
            ssid_vld <= 1'b1;
            ssid     <= l3_id[2:0];
         end
      end
   end







endmodule // ss_mngr
