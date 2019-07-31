`define IDX32(x) 32*(x+1)-1:32*(x)
module kreg (/*AUTOARG*/
   // Outputs
   rd_d, k, psk,
   // Inputs
   clk, rst_n, wr_en, wr_d, wrd_id, wrd_sk, wr_addr, rd_addr, ssid, ssid_vld,
   ecdh_sk_update, ecdh_sk
   ) ;
   // System Input
   input           clk, rst_n;
   // Kselect
   input           wr_en;
   input [31:0]    wr_d;

   input [2:0]     wrd_id;
   input           wrd_sk;

   input [2:0]     wr_addr;
   input [2:0]     rd_addr;

   output [31:0]   rd_d;

   input [2:0]     ssid;
   input           ssid_vld;

   input           ecdh_sk_update;
   input [255:0]   ecdh_sk;

   output [255:0]  k;
   output [255:0]  psk;

   /* Output Type*/
   reg [31:0]      rd_d;
   reg [255:0]     k;
   reg [255:0]     psk;

   reg [31:0]      mem[0:127];

   integer         i;

   wire [6:0]      waddr;
   wire [6:0]      raddr;
   wire [6:0]      ec0, ec1, ec2, ec3, ec4, ec5, ec6, ec7;

   assign waddr = {wrd_id, wrd_sk, wr_addr};
   assign raddr = {wrd_id, wrd_sk, rd_addr};

   assign ec0   = {ssid, 1'b1, 3'd0};
   assign ec1   = {ssid, 1'b1, 3'd1};
   assign ec2   = {ssid, 1'b1, 3'd2};
   assign ec3   = {ssid, 1'b1, 3'd3};
   assign ec4   = {ssid, 1'b1, 3'd4};
   assign ec5   = {ssid, 1'b1, 3'd5};
   assign ec6   = {ssid, 1'b1, 3'd6};
   assign ec7   = {ssid, 1'b1, 3'd7};

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         for(i = 0 ; i < 128 ; i = i + 1) begin
            mem[i] <= 32'd0;
         end
      end else begin
         if(wr_en) begin
            mem[waddr] <= wr_d;
         end else if (ecdh_sk_update & ssid_vld) begin
            mem[ec0]  <= ecdh_sk[255:224];
            mem[ec1]  <= ecdh_sk[223:192];
            mem[ec2]  <= ecdh_sk[191:160];
            mem[ec3]  <= ecdh_sk[159:128];
            mem[ec4]  <= ecdh_sk[127: 96];
            mem[ec5]  <= ecdh_sk[ 95: 64];
            mem[ec6]  <= ecdh_sk[ 63: 32];
            mem[ec7]  <= ecdh_sk[ 31:  0];
         end
      end
   end

   always @ (*) begin
      rd_d = mem[raddr];
   end

   always @ (*) begin
      if(ssid_vld) begin
         k[`IDX32(7)]   = mem[{ssid, 1'b0, 3'd0}];
         k[`IDX32(6)]   = mem[{ssid, 1'b0, 3'd1}];
         k[`IDX32(5)]   = mem[{ssid, 1'b0, 3'd2}];
         k[`IDX32(4)]   = mem[{ssid, 1'b0, 3'd3}];
         k[`IDX32(3)]   = mem[{ssid, 1'b0, 3'd4}];
         k[`IDX32(2)]   = mem[{ssid, 1'b0, 3'd5}];
         k[`IDX32(1)]   = mem[{ssid, 1'b0, 3'd6}];
         k[`IDX32(0)]   = mem[{ssid, 1'b0, 3'd7}];
         psk[`IDX32(7)] = mem[{ssid, 1'b1, 3'd0}];
         psk[`IDX32(6)] = mem[{ssid, 1'b1, 3'd1}];
         psk[`IDX32(5)] = mem[{ssid, 1'b1, 3'd2}];
         psk[`IDX32(4)] = mem[{ssid, 1'b1, 3'd3}];
         psk[`IDX32(3)] = mem[{ssid, 1'b1, 3'd4}];
         psk[`IDX32(2)] = mem[{ssid, 1'b1, 3'd5}];
         psk[`IDX32(1)] = mem[{ssid, 1'b1, 3'd6}];
         psk[`IDX32(0)] = mem[{ssid, 1'b1, 3'd7}];
      end else begin
         psk = 256'd0;
         k   = 256'd0;
      end
   end

endmodule // kreg
