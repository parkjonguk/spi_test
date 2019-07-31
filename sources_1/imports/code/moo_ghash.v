module moo_ghash (/*AUTOARG*/
   // Outputs
   ghash_rdy, ghash,
   // Inputs
   clk, rst_n, clr_core, ghash_op, ghash_en, ghash_clr, ccm_d, wb_d, xfb_do,
   wr_size, size_add, size_msg, msg_done
   ) ;
   input           clk, rst_n;
   input           clr_core;
   input [1:0]     ghash_op;
   input           ghash_en;
   input           ghash_clr;
   output          ghash_rdy;
   output [127:0]  ghash;

   input [127:0]   ccm_d;
   input [127:0]   wb_d;
   input [127:0]   xfb_do;

   input [15:0]    wr_size;
   input [15:0]    size_add;
   input [31:0]    size_msg;
   input           msg_done;

   /* Output Signal */
   reg [127:0]     ghash;
   reg             ghash_rdy;

   /* Internal Register */
   reg [127:0]     ghash_i;
   reg [127:0]     v;
   reg [7:0]       h8;
   reg [3:0]       counter;
   reg             ghash_nxt;

   wire [127:0]    z_nxt, v_nxt;

   localparam GHASH_WRD    = 2'b00;
   localparam GHASH_ENC    = 2'b01;
   localparam GHASH_NNC_F  = 2'b10;
   localparam GHASH_GCM_F  = 2'b11;

   wire [127:0]    enc_i, enc_msk;
   wire            block_n;
   assign enc_msk = {128{1'b1}} >> {size_msg[3:0], 3'd0};
   assign block_n = (size_msg[3:0] == 4'd0) ? 0 : 1;
   assign enc_i   = (block_n & msg_done) ? (xfb_do & (~enc_msk)) : xfb_do;
   wire [15:0]     nnc_size;
   assign nnc_size = wr_size - 16'd4;

   always @ (*) begin
      case (ghash_op)
        GHASH_WRD   : ghash_i  = wb_d;
        GHASH_ENC   : ghash_i  = enc_i;
        GHASH_NNC_F : ghash_i  = {93'd0, nnc_size, 3'd0};
        GHASH_GCM_F : ghash_i  = {45'd0, size_add, 32'd0, size_msg, 3'd0};
      endcase // case (ghash_op)
   end

   /* H8 Next Value */
   reg   [7:0] h8_nxt;
   always @ (*) begin
      case (counter)
        4'd0  : h8_nxt = ccm_d[127:120];
        4'd1  : h8_nxt = ccm_d[119:112];
        4'd2  : h8_nxt = ccm_d[111:104];
        4'd3  : h8_nxt = ccm_d[103:096];
        4'd4  : h8_nxt = ccm_d[095:088];
        4'd5  : h8_nxt = ccm_d[087:080];
        4'd6  : h8_nxt = ccm_d[079:072];
        4'd7  : h8_nxt = ccm_d[071:064];
        4'd8  : h8_nxt = ccm_d[063:056];
        4'd9  : h8_nxt = ccm_d[055:048];
        4'd10 : h8_nxt = ccm_d[047:040];
        4'd11 : h8_nxt = ccm_d[039:032];
        4'd12 : h8_nxt = ccm_d[031:024];
        4'd13 : h8_nxt = ccm_d[023:016];
        4'd14 : h8_nxt = ccm_d[015:008];
        4'd15 : h8_nxt = ccm_d[007:000];
      endcase // case (counter)
   end

   /* Counter Register */
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         counter <= 4'd0;
      end else begin
         if(clr_core | ghash_clr) begin
            counter <= 4'd0;
         end else if (ghash_en) begin
            counter <= 4'd1;
         end else if (ghash_nxt) begin
            counter <= counter + 4'd1;
         end
      end
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         v     <= 128'd0;
         ghash <= 128'd0;
         h8    <= 8'd0;
      end else begin
         if(ghash_clr) begin
            v     <= 128'd0;
            ghash <= 128'd0;
            h8    <= 8'd0;
         end else if(ghash_en) begin
            v     <= ghash ^ ghash_i;
            ghash <= 128'd0;
            h8    <= ccm_d[127:120];
         end else if(ghash_nxt) begin
            v     <= v_nxt;
            ghash <= z_nxt;
            h8    <= h8_nxt;
         end
      end
   end


   /* State Register */
   localparam ST_IDLE = 2'b01;
   localparam ST_HASH = 2'b10;
   reg [1:0]      state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= ST_IDLE;
      end else begin
         if(ghash_clr | clr_core) begin
            state <= ST_IDLE;
         end else begin
            state <= state_nxt;
         end
      end
   end

   /* State Transition */
   always @ (*) begin
      state_nxt   = state;
      ghash_rdy   = 0;
      ghash_nxt   = 0;
      case (state)
        ST_IDLE : begin
           ghash_rdy   = 1;
           if(ghash_en) begin
              state_nxt  = ST_HASH;
           end
        end
        ST_HASH : begin
           ghash_nxt   = 1;
           if(counter == 4'd0) begin
              state_nxt   = ST_IDLE;
           end
        end
      endcase // case (state)
   end


   /* GFM Module */
   gfm128_8 GFM (
                 // Outputs
                 .vo                    (v_nxt[127:0]),
                 .zo                    (z_nxt[127:0]),
                 // Inputs
                 .vi                    (v[127:0]),
                 .zi                    (ghash[127:0]),
                 /*AUTOINST*/
                 // Inputs
                 .h8                    (h8[7:0]));

endmodule // moo_ghash
module gfm128_8 (/*AUTOARG*/
   // Outputs
   vo, zo,
   // Inputs
   vi, zi, h8
   ) ;
   input [127:0]  vi;
   input [127:0]  zi;
   input [7:0]    h8;

   output [127:0] vo;
   output [127:0] zo;


   wire [127:0]   vo;
   wire [127:0]   zo;


   wire   [7:0] t0, t1, t2, t3, t4, t5, t6, t7, t8;

   assign vo = {t8, t7[0], t6[0], t5[0], t4[0], t3[0], t2[0], t1[0], t0[0], vi[119:8]};

   assign t0 = {vi[127:120]};
   assign t1 = {vi[0], vi[0]^t0[7], vi[0]^t0[6], t0[5:2], vi[0]^t0[1]};
   assign t2 = {vi[1], vi[1]^t1[7], vi[1]^t1[6], t1[5:2], vi[1]^t1[1]};
   assign t3 = {vi[2], vi[2]^t2[7], vi[2]^t2[6], t2[5:2], vi[2]^t2[1]};
   assign t4 = {vi[3], vi[3]^t3[7], vi[3]^t3[6], t3[5:2], vi[3]^t3[1]};
   assign t5 = {vi[4], vi[4]^t4[7], vi[4]^t4[6], t4[5:2], vi[4]^t4[1]};
   assign t6 = {vi[5], vi[5]^t5[7], vi[5]^t5[6], t5[5:2], vi[5]^t5[1]};
   assign t7 = {vi[6], vi[6]^t6[7], vi[6]^t6[6], t6[5:2], vi[6]^t6[1]};
   assign t8 = {vi[7], vi[7]^t7[7], vi[7]^t7[6], t7[5:2], vi[7]^t7[1]};

   assign zo[127] = zi[127] ^ (^(h8 & {vi[127], t1[7], t2[7], t3[7], t4[7], t5[7], t6[7], t7[7]}));
   assign zo[126] = zi[126] ^ (^(h8 & {vi[126], t1[6], t2[6], t3[6], t4[6], t5[6], t6[6], t7[6]}));
   assign zo[125] = zi[125] ^ (^(h8 & {vi[125], t1[5], t2[5], t3[5], t4[5], t5[5], t6[5], t7[5]}));
   assign zo[124] = zi[124] ^ (^(h8 & {vi[124], t1[4], t2[4], t3[4], t4[4], t5[4], t6[4], t7[4]}));
   assign zo[123] = zi[123] ^ (^(h8 & {vi[123], t1[3], t2[3], t3[3], t4[3], t5[3], t6[3], t7[3]}));
   assign zo[122] = zi[122] ^ (^(h8 & {vi[122], t1[2], t2[2], t3[2], t4[2], t5[2], t6[2], t7[2]}));
   assign zo[121] = zi[121] ^ (^(h8 & {vi[121], t1[1], t2[1], t3[1], t4[1], t5[1], t6[1], t7[1]}));
   assign zo[120] = zi[120] ^ (^(h8 & {vi[120], t1[0], t2[0], t3[0], t4[0], t5[0], t6[0], t7[0]}));

   assign zo[119] = zi[119] ^ (^(h8 & {vi[119], vi[120], t1[0],   t2[0],   t3[0],   t4[0],   t5[0],   t6[0]}));
   assign zo[118] = zi[118] ^ (^(h8 & {vi[118], vi[119], vi[120], t1[0],   t2[0],   t3[0],   t4[0],   t5[0]}));
   assign zo[117] = zi[117] ^ (^(h8 & {vi[117], vi[118], vi[119], vi[120], t1[0],   t2[0],   t3[0],   t4[0]}));
   assign zo[116] = zi[116] ^ (^(h8 & {vi[116], vi[117], vi[118], vi[119], vi[120], t1[0],   t2[0],   t3[0]}));
   assign zo[115] = zi[115] ^ (^(h8 & {vi[115], vi[116], vi[117], vi[118], vi[119], vi[120], t1[0],   t2[0]}));
   assign zo[114] = zi[114] ^ (^(h8 & {vi[114], vi[115], vi[116], vi[117], vi[118], vi[119], vi[120], t1[0]}));

   genvar         i;
   generate
      for(i=0; i < 114 ; i = i + 1) begin : zo_loop
         assign zo[i] = zi[i] ^ (^(h8 & {vi[i], vi[i+1], vi[i+2], vi[i+3], vi[i+4], vi[i+5], vi[i+6], vi[i+7]}));
      end
   endgenerate

endmodule

