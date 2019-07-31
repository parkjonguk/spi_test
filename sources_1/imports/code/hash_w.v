module hash_w (/*AUTOARG*/
   // Outputs
   w, h_flg_ovf,
   // Inputs
   w_op, w_en, rst_n, msg_size, msg, kw_nxt, kw_done, key, hash_op, hash_f,
   h_pad, h_flg_384, h_clr, clk
   ) ;
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                clk;                    // To MR of hash_w_reg.v, ...
   input                h_clr;                  // To MR of hash_w_reg.v, ...
   input                h_flg_384;              // To MR of hash_w_reg.v, ...
   input                h_pad;                  // To MR of hash_w_reg.v, ...
   input [511:0]        hash_f;                 // To MR of hash_w_reg.v
   input [3:2]          hash_op;                // To PR of hash_w_prm.v
   input [511:0]        key;                    // To MR of hash_w_reg.v
   input                kw_done;                // To MR of hash_w_reg.v
   input                kw_nxt;                 // To MR of hash_w_reg.v
   input [1023:0]       msg;                    // To MR of hash_w_reg.v
   input [31:0]         msg_size;               // To PR of hash_w_prm.v
   input                rst_n;                  // To MR of hash_w_reg.v, ...
   input                w_en;                   // To MR of hash_w_reg.v, ...
   input [1:0]          w_op;                   // To MR of hash_w_reg.v, ...
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output               h_flg_ovf;              // From PR of hash_w_prm.v
   output [63:0]        w;                      // From MR of hash_w_reg.v
   // End of automatics
   /*AUTOREG*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 h_flg_lst;              // From PR of hash_w_prm.v
   wire                 h_flg_one;              // From PR of hash_w_prm.v
   wire [32:0]          h_prm_lst;              // From PR of hash_w_prm.v
   wire [31:0]          w32_0;                  // From MR of hash_w_reg.v
   wire [31:0]          w32_1;                  // From MR of hash_w_reg.v
   wire [31:0]          w32_14;                 // From MR of hash_w_reg.v
   wire [31:0]          w32_9;                  // From MR of hash_w_reg.v
   wire [63:0]          w64_0;                  // From MR of hash_w_reg.v
   wire [63:0]          w64_1;                  // From MR of hash_w_reg.v
   wire [63:0]          w64_14;                 // From MR of hash_w_reg.v
   wire [63:0]          w64_9;                  // From MR of hash_w_reg.v
   wire [31:0]          wt32;                   // From W3 of hash_w_wt32.v
   wire [63:0]          wt64;                   // From W6 of hash_w_wt64.v
   // End of automatics

   hash_w_reg  MR (/*AUTOINST*/
                   // Outputs
                   .w                   (w[63:0]),
                   .w64_0               (w64_0[63:0]),
                   .w64_1               (w64_1[63:0]),
                   .w64_9               (w64_9[63:0]),
                   .w64_14              (w64_14[63:0]),
                   .w32_0               (w32_0[31:0]),
                   .w32_1               (w32_1[31:0]),
                   .w32_9               (w32_9[31:0]),
                   .w32_14              (w32_14[31:0]),
                   // Inputs
                   .clk                 (clk),
                   .rst_n               (rst_n),
                   .msg                 (msg[1023:0]),
                   .key                 (key[511:0]),
                   .hash_f              (hash_f[511:0]),
                   .h_flg_384           (h_flg_384),
                   .h_flg_lst           (h_flg_lst),
                   .h_flg_one           (h_flg_one),
                   .h_prm_lst           (h_prm_lst[31:0]),
                   .h_clr               (h_clr),
                   .h_pad               (h_pad),
                   .w_op                (w_op[1:0]),
                   .w_en                (w_en),
                   .kw_done             (kw_done),
                   .kw_nxt              (kw_nxt),
                   .wt32                (wt32[31:0]),
                   .wt64                (wt64[63:0]));
   hash_w_wt32 W3 (/*AUTOINST*/
                   // Outputs
                   .wt32                (wt32[31:0]),
                   // Inputs
                   .w32_0               (w32_0[31:0]),
                   .w32_1               (w32_1[31:0]),
                   .w32_9               (w32_9[31:0]),
                   .w32_14              (w32_14[31:0]));
   hash_w_wt64 W6 (/*AUTOINST*/
                   // Outputs
                   .wt64                (wt64[63:0]),
                   // Inputs
                   .w64_0               (w64_0[63:0]),
                   .w64_1               (w64_1[63:0]),
                   .w64_9               (w64_9[63:0]),
                   .w64_14              (w64_14[63:0]));
   hash_w_prm  PR (/*AUTOINST*/
                   // Outputs
                   .h_flg_lst           (h_flg_lst),
                   .h_flg_ovf           (h_flg_ovf),
                   .h_flg_one           (h_flg_one),
                   .h_prm_lst           (h_prm_lst[32:0]),
                   // Inputs
                   .clk                 (clk),
                   .rst_n               (rst_n),
                   .msg_size            (msg_size[31:0]),
                   .h_clr               (h_clr),
                   .h_pad               (h_pad),
                   .hash_op             (hash_op[3:2]),
                   .w_op                (w_op[1:0]),
                   .w_en                (w_en),
                   .h_flg_384           (h_flg_384));


endmodule // hash_w

module hash_w_reg (/*AUTOARG*/
   // Outputs
   w, w64_0, w64_1, w64_9, w64_14, w32_0, w32_1, w32_9, w32_14,
   // Inputs
   clk, rst_n, msg, key, hash_f, h_flg_384, h_flg_lst, h_flg_one, h_prm_lst,
   h_clr, h_pad, w_op, w_en, kw_done, kw_nxt, wt32, wt64
   ) ;
   // System Input
   input          clk, rst_n;
   // External Input Data
   input [1023:0] msg;
   input [511:0]  key;
   input [511:0]  hash_f;
   // Parameter Input
   input          h_flg_384;
   input          h_flg_lst;
   input          h_flg_one;
   input [31:0]   h_prm_lst;
   // Cu
   input          h_clr;
   input          h_pad;
   input [1:0]    w_op;
   input          w_en;
   // KW OP
   input          kw_done;
   input          kw_nxt;
   input [31:0]   wt32;
   input [63:0]   wt64;
   // W Out
   output [63:0]  w;
   output [63:0]  w64_0;
   output [63:0]  w64_1;
   output [63:0]  w64_9;
   output [63:0]  w64_14;
   output [31:0]  w32_0;
   output [31:0]  w32_1;
   output [31:0]  w32_9;
   output [31:0]  w32_14;

   wire [63:0]    w64_0;
   wire [63:0]    w64_1;
   wire [63:0]    w64_9;
   wire [63:0]    w64_14;
   wire [31:0]    w32_0;
   wire [31:0]    w32_1;
   wire [31:0]    w32_9;
   wire [31:0]    w32_14;

   reg [1023:0]   wr_nxt;
   reg [7:0]      wr[0:127];
   reg [63:0]     w;


   assign w64_0  = {wr[  0],wr[  1],wr[  2],wr[  3],wr[  4],wr[  5],wr[  6],wr[  7]};
   assign w64_1  = {wr[  8],wr[  9],wr[ 10],wr[ 11],wr[ 12],wr[ 13],wr[ 14],wr[ 15]};
   assign w64_9  = {wr[ 72],wr[ 73],wr[ 74],wr[ 75],wr[ 76],wr[ 77],wr[ 78],wr[ 79]};
   assign w64_14 = {wr[112],wr[113],wr[114],wr[115],wr[116],wr[117],wr[118],wr[119]};

   assign w32_0  = {wr[ 0],wr[ 1],wr[ 2],wr[ 3]};
   assign w32_1  = {wr[ 4],wr[ 5],wr[ 6],wr[ 7]};
   assign w32_9  = {wr[36],wr[37],wr[38],wr[39]};
   assign w32_14 = {wr[56],wr[57],wr[58],wr[59]};

   wire [6:0]     h_prm_one;

   assign h_prm_one  = h_flg_384 ? h_prm_lst[6:0] : {1'b0, h_prm_lst[5:0]};

   localparam I_KPAD = 8'h36;
   localparam O_KPAD = 8'h5C;

   wire   [1023:0] key_pad;
   assign key_pad = {key, 512'd0};

   always @ (*) begin
      case (w_op)
        2'b00 : wr_nxt = msg;
        2'b01 : wr_nxt = key_pad ^ {128{I_KPAD}};
        2'b10 : wr_nxt = key_pad ^ {128{O_KPAD}};
        2'b11 : wr_nxt = {hash_f, 512'd0};
      endcase // case (w_op)
   end

   wire [7:0]   wra [0:127];

   genvar       gv;
   generate
      for(gv = 0 ; gv < 128 ; gv = gv + 1) begin : msg_array
         assign wra[gv] = wr_nxt[8*(128-gv)-1:8*(127-gv)];
      end
   endgenerate

   integer      i;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         for(i = 0 ; i < 128 ; i = i + 1) begin
            wr[i] <= 32'd0;
         end
      end else begin
         if(h_clr | kw_done) begin
            for(i = 0 ; i < 128 ; i = i + 1) begin
               wr[i] <= 8'h00;
            end
         end else if(w_en) begin
            for(i = 0 ; i < 128 ; i = i + 1) begin
               wr[i] <= wra[i];
            end
         end else if(h_pad) begin
            if(h_flg_one) begin
               wr[h_prm_one] <= 8'h80;
            end
            if(h_flg_lst) begin
               if(h_flg_384) begin
                  {wr[123], wr[124], wr[125], wr[126], wr[127]} <= {4'd0, h_prm_lst, 3'd0};
               end else begin
                  {wr[59], wr[60], wr[61], wr[62], wr[63]} <= {4'd0, h_prm_lst, 3'd0};
               end
            end
         end else if(kw_nxt) begin
            if(h_flg_384) begin
               for(i = 0 ; i < 120 ; i = i + 1) begin
                  wr[i] <= wr[i+8];
               end
               {wr[120],wr[121],wr[122],wr[123],wr[124],wr[125],wr[126],wr[127]} <= wt64;
            end else begin
               for(i = 0 ; i < 60 ; i = i + 1) begin
                  wr[i] <= wr[i+4];
               end
               {wr[60], wr[61], wr[62], wr[63]} <= wt32;
            end
         end
      end
   end

   always @ (*) begin
      if(h_flg_384) begin
         w = {wr[0],wr[1],wr[2],wr[3],wr[4],wr[5],wr[6],wr[7]};
      end else begin
         w = {wr[0],wr[1],wr[2],wr[3],32'd0};
      end
   end

endmodule // hash_w_reg

module hash_w_wt32 (/*AUTOARG*/
   // Outputs
   wt32,
   // Inputs
   w32_0, w32_1, w32_9, w32_14
   );
   input  [31:0]   w32_0;
   input  [31:0]   w32_1;
   input  [31:0]   w32_9;
   input  [31:0]   w32_14;
   output [31:0]   wt32;

   wire [31:0]     w32_1_ror7;
   wire [31:0]     w32_1_ror18;
   wire [31:0]     w32_1_rsh3;
   wire [31:0]     s32_0;
   wire [31:0]     w32_14_ror17;
   wire [31:0]     w32_14_ror19;
   wire [31:0]     w32_14_rsh10;
   wire [31:0]     s32_1;
   wire [31:0]     wt32;

   assign w32_1_ror7    = {w32_1[6:0] , w32_1[31:7]};
   assign w32_1_ror18   = {w32_1[17:0], w32_1[31:18]};
   assign w32_1_rsh3    = {3'b000  , w32_1[31:3]};
   assign s32_0         = w32_1_ror7 ^ w32_1_ror18 ^ w32_1_rsh3;
   assign w32_14_ror17  = {w32_14[16:0], w32_14[31:17]};
   assign w32_14_ror19  = {w32_14[18:0], w32_14[31:19]};
   assign w32_14_rsh10  = {10'd0, w32_14[31:10]};
   assign s32_1         = w32_14_ror17 ^ w32_14_ror19 ^ w32_14_rsh10;
   assign wt32          = w32_0 + s32_0 + w32_9 + s32_1;
endmodule // hash_w_wt32

module hash_w_wt64 (/*AUTOARG*/
   // Outputs
   wt64,
   // Inputs
   w64_0, w64_1, w64_9, w64_14
   );
   input  [63:0]   w64_0;
   input  [63:0]   w64_1;
   input  [63:0]   w64_9;
   input  [63:0]   w64_14;
   output [63:0]   wt64;

   wire [63:0]     w64_1_ror1;
   wire [63:0]     w64_1_ror8;
   wire [63:0]     w64_1_rsh7;
   wire [63:0]     s64_0;
   wire [63:0]     w64_14_ror19;
   wire [63:0]     w64_14_ror61;
   wire [63:0]     w64_14_rsh6;
   wire [63:0]     s64_1;
   wire [63:0]     wt64;

   assign w64_1_ror1    = {w64_1[0]   , w64_1[63:1]};
   assign w64_1_ror8    = {w64_1[7:0] , w64_1[63:8]};
   assign w64_1_rsh7    = {6'd0       , w64_1[63:7]};
   assign s64_0         = w64_1_ror1 ^ w64_1_ror8 ^ w64_1_rsh7;
   assign w64_14_ror19  = {w64_14[18:0], w64_14[63:19]};
   assign w64_14_ror61  = {w64_14[60:0], w64_14[63:61]};
   assign w64_14_rsh6   = {6'd0,         w64_14[63:6] };
   assign s64_1         = w64_14_ror19 ^ w64_14_ror61 ^ w64_14_rsh6;
   assign wt64          = w64_0 + s64_0 + w64_9 + s64_1;
endmodule // hash_w_wt64

module hash_w_prm (/*AUTOARG*/
   // Outputs
   h_flg_lst, h_flg_ovf, h_flg_one, h_prm_lst,
   // Inputs
   clk, rst_n, msg_size, h_clr, h_pad, hash_op, w_op, w_en, h_flg_384
   ) ;
   // System Input
   input          clk, rst_n;
   // External Input Data
   input [31:0]   msg_size;
   // Cu
   input          h_clr;
   input          h_pad;
   // W
   input [3:2]    hash_op;
   input [1:0]    w_op;
   input          w_en;

   input          h_flg_384;

   output         h_flg_lst;
   output         h_flg_ovf;
   output         h_flg_one;

   output [32:0]  h_prm_lst;

   /* Output Type */
   wire           h_flg_lst;
   wire           h_flg_one;
   wire           h_flg_ovf;

   reg [32:0]     h_prm_lst;


   /* Pad Flag Variable Assignment */
   // MSG SIZE PADDING Occure Overflow Flag
   reg            flg_ovf;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_ovf <= 1'b0;
      end else begin
         if(w_en) begin
            flg_ovf <= 1'b0;
         end else if (h_pad & !flg_ovf) begin
            flg_ovf <= 1'b1;
         end else if (h_pad & flg_ovf) begin
            flg_ovf <= 1'b0;
         end
      end
   end

   assign h_flg_ovf = flg_ovf & h_flg_lst;

   // Pad Flag Variable
   wire       pad_lst_384;
   wire       pad_lst_256;
   wire [6:0] h_prm_one;

   assign h_prm_one  = h_flg_384 ? h_prm_lst[6:0] : {1'b0, h_prm_lst[5:0]};
   assign pad_lst_384 = (h_prm_one < 7'd112) ? !flg_ovf : flg_ovf;
   assign pad_lst_256 = (h_prm_one < 7'd56 ) ? !flg_ovf : flg_ovf;

   // Output Assignment
   assign h_flg_lst   = h_flg_384 ? pad_lst_384 : pad_lst_256;
   assign h_flg_one   = !flg_ovf;

   // Output Assignment
   reg  [32:0]  lst_nxt;
   wire [32:0]  hmsg_384_size;
   wire [32:0]  hmsg_256_size;
   wire [32:0]  hmsg_size;
   wire [32:0]  msg_size_i;
   wire [32:0]  hmac_size;

   assign hmsg_384_size = msg_size + 32'd128;
   assign hmsg_256_size = msg_size + 32'd64;
   assign hmsg_size     = hash_op[2] ? hmsg_384_size : hmsg_256_size;
   assign msg_size_i    = hash_op[3] ? hmsg_size : msg_size;
   assign hmac_size     = h_flg_384 ? 33'd176 : 33'd96;

   always @ (*) begin
      case (w_op)
        2'b00 : lst_nxt = msg_size_i;
        2'b01 : lst_nxt = 33'd0;
        2'b10 : lst_nxt = 33'd0;
        2'b11 : lst_nxt = hmac_size;
      endcase // case (w_op)
   end

   /* Internal PRM Register */
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         h_prm_lst <= 32'd0;
      end else begin
         if(h_clr) begin
            h_prm_lst <= 32'd0;
         end else if(w_en) begin
            h_prm_lst <= lst_nxt;
         end
      end
   end
endmodule // hash_w_prm

