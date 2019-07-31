module ssk_mem (/*AUTOARG*/
   // Outputs
   rd_d, cw_mac_k, sw_mac_k, cw_blk_k, sw_blk_k, cw_iv, sw_iv,
   // Inputs
   clk, rst_n, clr_ssk, ss_expire, wr_en, wr_d, cmd_op, wr_addr, rd_addr,
   ssk_wr, ssk_addr, mac
   ) ;
   // System Input
   input           clk, rst_n;
   input           clr_ssk;
   input           ss_expire;

   input           wr_en;
   input [31:0]    wr_d;

   input [2:0]     cmd_op;
   input [3:0]     wr_addr;
   input [3:0]     rd_addr;

   output [31:0]   rd_d;

   input           ssk_wr;
   input [3:0]     ssk_addr;
   input [383:0]   mac;

   output [383:0]  cw_mac_k;
   output [383:0]  sw_mac_k;
   output [255:0]  cw_blk_k;
   output [255:0]  sw_blk_k;
   output [127:0]  cw_iv;
   output [127:0]  sw_iv;

   reg [31:0]      rd_d;

   wire   [383:0]  cw_mac_k;
   wire   [383:0]  sw_mac_k;
   wire   [255:0]  cw_blk_k;
   wire   [255:0]  sw_blk_k;
   wire   [127:0]  cw_iv;
   wire   [127:0]  sw_iv;

   wire [7:0]      waddr, raddr;

   assign waddr = {1'b0, cmd_op, wr_addr};
   assign raddr = {1'b0, cmd_op, rd_addr};

   reg [31:0]      cwmb, cwma, cwm9, cwm8;
   reg [31:0]      cwm7, cwm6, cwm5, cwm4;
   reg [31:0]      cwm3, cwm2, cwm1, cwm0;
   reg [31:0]      swmb, swma, swm9, swm8;
   reg [31:0]      swm7, swm6, swm5, swm4;
   reg [31:0]      swm3, swm2, swm1, swm0;
   reg [31:0]      cwk7, cwk6, cwk5, cwk4;
   reg [31:0]      cwk3, cwk2, cwk1, cwk0;
   reg [31:0]      swk7, swk6, swk5, swk4;
   reg [31:0]      swk3, swk2, swk1, swk0;
   reg [31:0]      cwi3, cwi2, cwi1, cwi0;
   reg [31:0]      swi3, swi2, swi1, swi0;

   wire [127:0]    cm2, cm1, cm0;
   wire [127:0]    sm2, sm1, sm0;
   wire [127:0]    ck1, ck0;
   wire [127:0]    sk1, sk0;
   wire [127:0]    ci0, si0;

   assign cw_mac_k = {cm2, cm1, cm0};
   assign sw_mac_k = {sm2, sm1, sm0};
   assign cw_blk_k = {ck1, ck0};
   assign sw_blk_k = {sk1, sk0};
   assign cw_iv    = ci0;
   assign sw_iv    = si0;

   assign cm2 = {cwmb, cwma, cwm9, cwm8};
   assign cm1 = {cwm7, cwm6, cwm5, cwm4};
   assign cm0 = {cwm3, cwm2, cwm1, cwm0};
   assign sm2 = {swmb, swma, swm9, swm8};
   assign sm1 = {swm7, swm6, swm5, swm4};
   assign sm0 = {swm3, swm2, swm1, swm0};
   assign ck1 = {cwk7, cwk6, cwk5, cwk4};
   assign ck0 = {cwk3, cwk2, cwk1, cwk0};
   assign sk1 = {swk7, swk6, swk5, swk4};
   assign sk0 = {swk3, swk2, swk1, swk0};
   assign ci0 = {cwi3, cwi2, cwi1, cwi0};
   assign si0 = {swi3, swi2, swi1, swi0};

   always @ (*) begin
      case (raddr)
        8'h60 : rd_d = cwmb;
        8'h61 : rd_d = cwma;
        8'h62 : rd_d = cwm9;
        8'h63 : rd_d = cwm8;
        8'h64 : rd_d = cwm7;
        8'h65 : rd_d = cwm6;
        8'h66 : rd_d = cwm5;
        8'h67 : rd_d = cwm4;
        8'h68 : rd_d = cwm3;
        8'h69 : rd_d = cwm2;
        8'h6A : rd_d = cwm1;
        8'h6B : rd_d = cwm0;
        8'h70 : rd_d = swmb;
        8'h71 : rd_d = swma;
        8'h72 : rd_d = swm9;
        8'h73 : rd_d = swm8;
        8'h74 : rd_d = swm7;
        8'h75 : rd_d = swm6;
        8'h76 : rd_d = swm5;
        8'h77 : rd_d = swm4;
        8'h78 : rd_d = swm3;
        8'h79 : rd_d = swm2;
        8'h7A : rd_d = swm1;
        8'h7B : rd_d = swm0;
        8'h40 : rd_d = cwk7;
        8'h41 : rd_d = cwk6;
        8'h42 : rd_d = cwk5;
        8'h43 : rd_d = cwk4;
        8'h44 : rd_d = cwk3;
        8'h45 : rd_d = cwk2;
        8'h46 : rd_d = cwk1;
        8'h47 : rd_d = cwk0;
        8'h50 : rd_d = swk7;
        8'h51 : rd_d = swk6;
        8'h52 : rd_d = swk5;
        8'h53 : rd_d = swk4;
        8'h54 : rd_d = swk3;
        8'h55 : rd_d = swk2;
        8'h56 : rd_d = swk1;
        8'h57 : rd_d = swk0;
        8'h20 : rd_d = cwi3;
        8'h21 : rd_d = cwi2;
        8'h22 : rd_d = cwi1;
        8'h23 : rd_d = cwi0;
        8'h30 : rd_d = swi3;
        8'h31 : rd_d = swi2;
        8'h32 : rd_d = swi1;
        8'h33 : rd_d = swi0;
        default : rd_d = 32'd0;
      endcase // case (rd_addr)
   end


   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         {cwmb, cwma, cwm9, cwm8} <= 128'd0;
         {cwm7, cwm6, cwm5, cwm4} <= 128'd0;
         {cwm3, cwm2, cwm1, cwm0} <= 128'd0;
         {swmb, swma, swm9, swm8} <= 128'd0;
         {swm7, swm6, swm5, swm4} <= 128'd0;
         {swm3, swm2, swm1, swm0} <= 128'd0;
         {cwk7, cwk6, cwk5, cwk4} <= 128'd0;
         {cwk3, cwk2, cwk1, cwk0} <= 128'd0;
         {swk7, swk6, swk5, swk4} <= 128'd0;
         {swk3, swk2, swk1, swk0} <= 128'd0;
         {cwi3, cwi2, cwi1, cwi0} <= 128'd0;
         {swi3, swi2, swi1, swi0} <= 128'd0;
      end else begin
         if(ss_expire | clr_ssk) begin
            {cwmb, cwma, cwm9, cwm8} <= 128'd0;
            {cwm7, cwm6, cwm5, cwm4} <= 128'd0;
            {cwm3, cwm2, cwm1, cwm0} <= 128'd0;
            {swmb, swma, swm9, swm8} <= 128'd0;
            {swm7, swm6, swm5, swm4} <= 128'd0;
            {swm3, swm2, swm1, swm0} <= 128'd0;
            {cwk7, cwk6, cwk5, cwk4} <= 128'd0;
            {cwk3, cwk2, cwk1, cwk0} <= 128'd0;
            {swk7, swk6, swk5, swk4} <= 128'd0;
            {swk3, swk2, swk1, swk0} <= 128'd0;
            {cwi3, cwi2, cwi1, cwi0} <= 128'd0;
            {swi3, swi2, swi1, swi0} <= 128'd0;
         end else if(wr_en) begin
            case (waddr)
              8'h60 : begin
                 cwmb <= wr_d;
                 cwma <= 32'd0;
                 cwm9 <= 32'd0;
                 cwm8 <= 32'd0;
                 cwm7 <= 32'd0;
                 cwm6 <= 32'd0;
                 cwm5 <= 32'd0;
                 cwm4 <= 32'd0;
                 cwm3 <= 32'd0;
                 cwm2 <= 32'd0;
                 cwm1 <= 32'd0;
                 cwm0 <= 32'd0;
              end
              8'h61 : cwma <= wr_d;
              8'h62 : cwm9 <= wr_d;
              8'h63 : cwm8 <= wr_d;
              8'h64 : cwm7 <= wr_d;
              8'h65 : cwm6 <= wr_d;
              8'h66 : cwm5 <= wr_d;
              8'h67 : cwm4 <= wr_d;
              8'h68 : cwm3 <= wr_d;
              8'h69 : cwm2 <= wr_d;
              8'h6A : cwm1 <= wr_d;
              8'h6B : cwm0 <= wr_d;
              8'h70 : begin
                 swmb <= wr_d;
                 swma <= 32'd0;
                 swm9 <= 32'd0;
                 swm8 <= 32'd0;
                 swm7 <= 32'd0;
                 swm6 <= 32'd0;
                 swm5 <= 32'd0;
                 swm4 <= 32'd0;
                 swm3 <= 32'd0;
                 swm2 <= 32'd0;
                 swm1 <= 32'd0;
                 swm0 <= 32'd0;
              end
              8'h71 : swma <= wr_d;
              8'h72 : swm9 <= wr_d;
              8'h73 : swm8 <= wr_d;
              8'h74 : swm7 <= wr_d;
              8'h75 : swm6 <= wr_d;
              8'h76 : swm5 <= wr_d;
              8'h77 : swm4 <= wr_d;
              8'h78 : swm3 <= wr_d;
              8'h79 : swm2 <= wr_d;
              8'h7A : swm1 <= wr_d;
              8'h7B : swm0 <= wr_d;

              8'h40 : begin
                 cwk7 <= wr_d;
                 cwk6 <= 32'd0;
                 cwk5 <= 32'd0;
                 cwk4 <= 32'd0;
                 cwk3 <= 32'd0;
                 cwk2 <= 32'd0;
                 cwk1 <= 32'd0;
                 cwk0 <= 32'd0;
              end
              8'h41 : cwk6 <= wr_d;
              8'h42 : cwk5 <= wr_d;
              8'h43 : cwk4 <= wr_d;
              8'h44 : cwk3 <= wr_d;
              8'h45 : cwk2 <= wr_d;
              8'h46 : cwk1 <= wr_d;
              8'h47 : cwk0 <= wr_d;

              8'h50 : begin
                 swk7 <= wr_d;
                 swk6 <= 32'd0;
                 swk5 <= 32'd0;
                 swk4 <= 32'd0;
                 swk3 <= 32'd0;
                 swk2 <= 32'd0;
                 swk1 <= 32'd0;
                 swk0 <= 32'd0;
              end
              8'h51 : swk6 <= wr_d;
              8'h52 : swk5 <= wr_d;
              8'h53 : swk4 <= wr_d;
              8'h54 : swk3 <= wr_d;
              8'h55 : swk2 <= wr_d;
              8'h56 : swk1 <= wr_d;
              8'h57 : swk0 <= wr_d;

              8'h20 : begin
                 cwi3 <= wr_d;
                 cwi2 <= 32'd0;
                 cwi1 <= 32'd0;
                 cwi0 <= 32'd0;
              end
              8'h21 : cwi2 <= wr_d;
              8'h22 : cwi1 <= wr_d;
              8'h23 : cwi0 <= wr_d;

              8'h30 : begin
                 swi3 <= wr_d;
                 swi2 <= 32'd0;
                 swi1 <= 32'd0;
                 swi0 <= 32'd0;
              end
              8'h31 : swi2 <= wr_d;
              8'h32 : swi1 <= wr_d;
              8'h33 : swi0 <= wr_d;
              default : begin
              end
            endcase // case (waddr)
         end else if (ssk_wr) begin
            case (ssk_addr)
              4'b0000 : begin
                 {cwmb, cwma, cwm9, cwm8} <= mac[383:256];
                 {cwm7, cwm6, cwm5, cwm4} <= mac[255:128];
                 {cwm3, cwm2, cwm1, cwm0} <= 128'd0;
              end
              4'b0001 : begin
                 {swmb, swma, swm9, swm8} <= mac[383:256];
                 {swm7, swm6, swm5, swm4} <= mac[255:128];
                 {swm3, swm2, swm1, swm0} <= 128'd0;
              end
              4'b0010 : begin
                 {cwk7, cwk6, cwk5, cwk4} <= mac[383:256];
                 {cwk3, cwk2, cwk1, cwk0} <= 128'd0;
                 {swk7, swk6, swk5, swk4} <= mac[255:128];
                 {swk3, swk2, swk1, swk0} <= 128'd0;
              end
              4'b0011 : begin
                 {cwi3, cwi2, cwi1, cwi0} <= mac[383:256];
                 {swi3, swi2, swi1, swi0} <= mac[255:128];
              end
              4'b0100 : begin
                 {cwmb, cwma, cwm9, cwm8} <= mac[383:256];
                 {cwm7, cwm6, cwm5, cwm4} <= mac[255:128];
                 {cwm3, cwm2, cwm1, cwm0} <= mac[127:  0];
              end
              4'b0101 : begin
                 {swmb, swma, swm9, swm8} <= mac[383:256];
                 {swm7, swm6, swm5, swm4} <= mac[255:128];
                 {swm3, swm2, swm1, swm0} <= mac[127:  0];
              end
              4'b0110 : begin
                 {cwk7, cwk6, cwk5, cwk4} <= mac[383:256];
                 {cwk3, cwk2, cwk1, cwk0} <= mac[255:128];
                 {swk7, swk6, swk5, swk4} <= mac[127:  0];
              end
              4'b0111 : begin
                 {swk3, swk2, swk1, swk0} <= mac[383:256];
                 {cwi3, cwi2, cwi1, cwi0} <= mac[255:128];
                 {swi3, swi2, swi1, swi0} <= mac[127:  0];
              end
              4'b1000 : begin
                 {cwmb, cwma, cwm9, cwm8} <= 128'd0;
                 {cwm7, cwm6, cwm5, cwm4} <= 128'd0;
                 {cwm3, cwm2, cwm1, cwm0} <= 128'd0;
                 {swmb, swma, swm9, swm8} <= 128'd0;
                 {swm7, swm6, swm5, swm4} <= 128'd0;
                 {swm3, swm2, swm1, swm0} <= 128'd0;
                 {cwk7, cwk6, cwk5, cwk4} <= mac[383:256];
                 {cwk3, cwk2, cwk1, cwk0} <= 128'd0;
                 {swk7, swk6, swk5, swk4} <= mac[255:128];
                 {swk3, swk2, swk1, swk0} <= 128'd0;
              end
              4'b1001 : begin
                 {cwi3, swi3} <= mac[383:320];
                 {cwi2, cwi1, cwi0} <= 96'd0;
                 {swi2, swi1, swi0} <= 96'd0;
              end
              4'b1100 : begin
                 {cwmb, cwma, cwm9, cwm8} <= 128'd0;
                 {cwm7, cwm6, cwm5, cwm4} <= 128'd0;
                 {cwm3, cwm2, cwm1, cwm0} <= 128'd0;
                 {swmb, swma, swm9, swm8} <= 128'd0;
                 {swm7, swm6, swm5, swm4} <= 128'd0;
                 {swm3, swm2, swm1, swm0} <= 128'd0;
                 {cwk7, cwk6, cwk5, cwk4} <= mac[383:256];
                 {cwk3, cwk2, cwk1, cwk0} <= mac[255:128];
                 {swk7, swk6, swk5, swk4} <= mac[127:  0];
              end
              4'b1101 : begin
                 {swk3, swk2, swk1, swk0} <= mac[383:256];
                 {cwi3, swi3} <= mac[255:192];
                 {cwi2, cwi1, cwi0} <= 96'd0;
                 {swi2, swi1, swi0} <= 96'd0;
              end
              default : begin
              end
            endcase // case (ssk_addr)
         end
      end
   end
endmodule // ssk_mem
