module prm_ctrl (/*AUTOARG*/
   // Outputs
   s0_prm_vld, s0_flg_384, s1_prm_vld, s1_flg_384,
   // Inputs
   clk, rst_n, clr_hash, hflg, s0_prm_set, s0_prm_clr, s1_prm_set, s1_prm_clr
   ) ;
   input           clk, rst_n;
   input           clr_hash;
   input           hflg;

   input           s0_prm_set;
   input           s0_prm_clr;
   output          s0_prm_vld;
   output          s0_flg_384;

   input           s1_prm_set;
   input           s1_prm_clr;
   output          s1_prm_vld;
   output          s1_flg_384;

   reg             s0_prm_vld;
   reg             s0_flg_384;
   reg             s1_prm_vld;
   reg             s1_flg_384;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         s0_flg_384 <= 1'b0;
         s0_prm_vld <= 1'b0;
      end else begin
         if(s0_prm_clr | clr_hash) begin
            s0_flg_384 <= 1'b0;
            s0_prm_vld <= 1'b0;
         end else if(s0_prm_set) begin
            s0_flg_384 <= hflg;
            s0_prm_vld <= 1'b1;
         end
      end
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         s1_flg_384 <= 1'b0;
         s1_prm_vld <= 1'b0;
      end else begin
         if(s1_prm_clr | clr_hash) begin
            s1_flg_384 <= 1'b0;
            s1_prm_vld <= 1'b0;
         end else if(s1_prm_set) begin
            s1_flg_384 <= hflg;
            s1_prm_vld <= 1'b1;
         end
      end
   end

endmodule // prm_ctrl
