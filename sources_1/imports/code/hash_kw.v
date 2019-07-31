module hash_kw (/*AUTOARG*/
   // Outputs
   kw_vld, kw_nxt, kw_flg0, kw_done, round, kw,
   // Inputs
   clk, rst_n, h_clr, h_run, h_flg_384, w, k
   ) ;
   // System Input
   input          clk, rst_n;
   // CU
   input          h_clr;
   input          h_run;
   input          h_flg_384;
   // KW
   output         kw_vld;
   output         kw_nxt;
   output         kw_flg0;
   output         kw_done;
   output [6:0]   round;
   output [63:0]  kw;
   // W
   input [63:0]   w;
   input [63:0]   k;

   reg            kw_vld;
   reg            kw_nxt;
   reg            kw_lst;
   reg            kw_flg0;
   reg            kw_done;
   reg [63:0]     kw;

   reg [6:0]      round;

   wire [6:0]     rnxt;
   assign         rnxt = round + 7'd1;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         round <= 7'd0;
         kw_nxt   <= 1'b0;
         kw_lst   <= 1'b0;
         kw_flg0  <= 1'b0;
      end else begin
         if(h_clr) begin
            round <= 7'd0;
            kw_nxt   <= 1'b0;
            kw_lst   <= 1'b0;
            kw_flg0  <= 1'b0;
         end else if(h_run) begin
            round    <= 7'd0;
            kw_nxt   <= 1'b1;
            kw_lst   <= 1'b0;
            kw_flg0  <= 1'b0;
         end else if(kw_nxt) begin
            round <= rnxt;
            // END SIGNAL
            if((!h_flg_384) & (round == 7'd63)) begin
               kw_lst   <= 1'b1;
               kw_nxt   <= 1'b0;
               round <= 7'd0;
            end else if (h_flg_384 & (round == 7'd79)) begin
               kw_lst   <= 1'b1;
               kw_nxt   <= 1'b0;
               round <= 7'd0;
            end
            // FIRST KW FLAG
            if(round == 7'd0)  begin
               kw_flg0 <= 1'b1;
            end else if (kw_flg0) begin
               kw_flg0 <= 1'b0;
            end
         end else if(kw_lst) begin
            kw_lst  <= 1'b0;
         end
      end
   end

   wire [63:0]   kw_add;
   wire [63:0]   kw_sel;

   assign kw_add = k + w;
   assign kw_sel = h_flg_384 ? kw_add : {kw_add[63:32], 32'd0};

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         kw      <= 64'd0;
         kw_done <= 1'b0;
         kw_vld  <= 1'b0;
      end else begin
         if(h_clr) begin
            kw      <= 64'd0;
            kw_done <= 1'b0;
            kw_vld  <= 1'b0;
         end else if(h_run) begin
            kw      <= 64'd0;
            kw_done <= 1'b0;
         end else if(kw_lst) begin
            kw      <= 64'd0;
            kw_done <= 1'b1;
            kw_vld  <= 1'b1;
         end else if(kw_nxt) begin
            kw      <= kw_sel;
            kw_vld  <= 1'b1;
         end else if (kw_done) begin
            kw_done <= 1'b0;
            kw_vld  <= 1'b0;
         end
      end
   end
endmodule // hash_kw
