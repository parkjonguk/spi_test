module key_buf (/*AUTOARG*/
   // Outputs
   rcv_nxtk, key,
   // Inputs
   clk, rst_n, k_buf_clr, k_buf_en, k_buf_op, wr_d, wr_en, k_buf_wr, psk, msk,
   sw_mac_k, cw_mac_k
   ) ;
   // System Input
   input           clk, rst_n;
   // FLAG
   input           k_buf_clr;
   input           k_buf_en;
   input [1:0]     k_buf_op;

   input [31:0]    wr_d;
   input           wr_en;
   input           k_buf_wr;
   output          rcv_nxtk;

   input [255:0]   psk;
   input [383:0]   msk;
   input [383:0]   sw_mac_k;
   input [383:0]   cw_mac_k;

   output [511:0]  key;
   wire   [511:0]  key;
   wire            rcv_nxtk;

   assign rcv_nxtk  = wr_en & k_buf_wr;

   reg [31:0]      mem[0:15];
   reg [3:0]       addr;

   wire [31:0]     psk_array[0:15];
   wire [31:0]     msk_array[0:15];
   wire [31:0]     sw_mac_k_array[0:15];
   wire [31:0]     cw_mac_k_array[0:15];

   wire [511:0]    psk_zp;
   wire [511:0]    msk_zp;
   wire [511:0]    sw_mac_k_zp;
   wire [511:0]    cw_mac_k_zp;

   integer         i;

   // Addr Counter
   wire [3:0]      addr_nxt;
   assign addr_nxt = addr + 4'd1;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         addr <= 4'd0;
      end else begin
         if(k_buf_clr) begin
            addr <= 4'd0;
         end else if(rcv_nxtk) begin
            addr <= addr_nxt;
         end
      end
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         for(i = 0; i < 16; i = i + 1) begin
            mem[i] <= 32'd0;
         end
      end else begin
         if(k_buf_clr) begin
            for(i = 0; i < 16; i = i + 1) begin
               mem[i] <= 32'd0;
            end
         end else if(rcv_nxtk) begin
            mem[addr] <= wr_d;
         end else if(k_buf_en) begin
            case (k_buf_op)
              2'b00 : begin
                 for(i = 0; i < 16; i = i + 1) begin
                    mem[i] <= psk_array[i];
                 end
              end
              2'b01 : begin
                 for(i = 0; i < 16; i = i + 1) begin
                    mem[i] <= msk_array[i];
                 end
              end
              2'b10 : begin
                 for(i = 0; i < 16; i = i + 1) begin
                    mem[i] <= sw_mac_k_array[i];
                 end
              end
              2'b11 : begin
                 for(i = 0; i < 16; i = i + 1) begin
                    mem[i] <= cw_mac_k_array[i];
                 end
              end
            endcase // case (k_buf_op)
         end
      end
   end

   assign psk_zp  = {psk, 256'd0};
   assign msk_zp  = {msk, 128'd0};
   assign sw_mac_k_zp  = {sw_mac_k, 128'd0};
   assign cw_mac_k_zp  = {cw_mac_k, 128'd0};

   genvar  g;
   generate
      for(g = 0; g < 16 ;g = g + 1) begin : key_array
         assign psk_array[g] = psk_zp[32*(16-g)-1 : 32*(15-g)];
         assign msk_array[g] = msk_zp[32*(16-g)-1 : 32*(15-g)];
         assign sw_mac_k_array[g] = sw_mac_k_zp[32*(16-g)-1 : 32*(15-g)];
         assign cw_mac_k_array[g] = cw_mac_k_zp[32*(16-g)-1 : 32*(15-g)];
         assign key[32*(16-g)-1 : 32*(15-g)] = mem[g];
      end
   endgenerate

endmodule // key_buf
