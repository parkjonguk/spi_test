module ecc_mem (/*AUTOARG*/
   // Outputs
   rd_d, flg_k_zero, flg_d_zero, Qx, Qy, in_ds, in_kr, hash_msg,
   // Inputs
   clk, rst_n, load_hash, load_key, load_res, load_d, set_clr, cmd_op, wr_addr,
   wr_d, wr_en, cert_msg, k, x, y, rd_addr
   ) ;
   input           clk, rst_n;

   input           load_hash;
   input           load_key;
   input           load_res;
   input           load_d;
   input           set_clr;

   input [1:0]     cmd_op;
   input [5:0]     wr_addr;
   input [31:0]    wr_d;
   input           wr_en;

   input [255:0]   cert_msg;
   input [255:0]   k, x, y;

   input [3:0]     rd_addr;
   output [31:0]   rd_d;

   output          flg_k_zero;
   output          flg_d_zero;

   output [255:0]  Qx, Qy, in_ds, in_kr, hash_msg;
   reg [31:0]      rd_d;

   wire [255:0]  Qx, Qy, in_ds, in_kr, hash_msg;

   wire [7:0]      waddr;
   assign waddr = {cmd_op, wr_addr};

   reg [31:0]      qx7, qx6, qx5, qx4, qx3, qx2, qx1, qx0;
   reg [31:0]      qy7, qy6, qy5, qy4, qy3, qy2, qy1, qy0;
   reg [31:0]      kr7, kr6, kr5, kr4, kr3, kr2, kr1, kr0;
   reg [31:0]      ds7, ds6, ds5, ds4, ds3, ds2, ds1, ds0;
   reg [31:0]      hs7, hs6, hs5, hs4, hs3, hs2, hs1, hs0;
   reg [31:0]      d7, d6, d5, d4, d3, d2, d1, d0;

   assign Qx       = {qx7, qx6, qx5, qx4, qx3, qx2, qx1, qx0};
   assign Qy       = {qy7, qy6, qy5, qy4, qy3, qy2, qy1, qy0};
   assign in_ds    = {ds7, ds6, ds5, ds4, ds3, ds2, ds1, ds0};
   assign in_kr    = {kr7, kr6, kr5, kr4, kr3, kr2, kr1, kr0};
   assign hash_msg = {hs7, hs6, hs5, hs4, hs3, hs2, hs1, hs0};

   wire            flg_k_zero;
   wire            flg_d_zero;

   assign flg_k_zero = (in_kr == 255'd0) ? 1 : 0;
   assign flg_d_zero = (in_ds == 255'd0) ? 1 : 0;



   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         {qx7, qx6, qx5, qx4, qx3, qx2, qx1, qx0} <= 256'd0;
         {qy7, qy6, qy5, qy4, qy3, qy2, qy1, qy0} <= 256'd0;
         {ds7, ds6, ds5, ds4, ds3, ds2, ds1, ds0} <= 256'd0;
         {kr7, kr6, kr5, kr4, kr3, kr2, kr1, kr0} <= 256'd0;
         {hs7, hs6, hs5, hs4, hs3, hs2, hs1, hs0} <= 256'd0;
         {d7, d6, d5, d4, d3, d2, d1, d0} <= 256'd0;
      end else begin
         if(set_clr) begin
            {qx7, qx6, qx5, qx4, qx3, qx2, qx1, qx0} <= 256'd0;
            {qy7, qy6, qy5, qy4, qy3, qy2, qy1, qy0} <= 256'd0;
            {ds7, ds6, ds5, ds4, ds3, ds2, ds1, ds0} <= 256'd0;
            {kr7, kr6, kr5, kr4, kr3, kr2, kr1, kr0} <= 256'd0;
            {hs7, hs6, hs5, hs4, hs3, hs2, hs1, hs0} <= 256'd0;
         end else if(wr_en) begin
            case (waddr)
              // ECDH SK
              8'h00 : qx7 <= wr_d;
              8'h01 : qx6 <= wr_d;
              8'h02 : qx5 <= wr_d;
              8'h03 : qx4 <= wr_d;
              8'h04 : qx3 <= wr_d;
              8'h05 : qx2 <= wr_d;
              8'h06 : qx1 <= wr_d;
              8'h07 : qx0 <= wr_d;
              8'h08 : qy7 <= wr_d;
              8'h09 : qy6 <= wr_d;
              8'h0A : qy5 <= wr_d;
              8'h0B : qy4 <= wr_d;
              8'h0C : qy3 <= wr_d;
              8'h0D : qy2 <= wr_d;
              8'h0E : qy1 <= wr_d;
              8'h0F : qy0 <= wr_d;
              // ECDSA SIGN
              8'h40 : ds7 <= wr_d;
              8'h41 : ds6 <= wr_d;
              8'h42 : ds5 <= wr_d;
              8'h43 : ds4 <= wr_d;
              8'h44 : ds3 <= wr_d;
              8'h45 : ds2 <= wr_d;
              8'h46 : ds1 <= wr_d;
              8'h47 : ds0 <= wr_d;
              8'h48 : hs7 <= wr_d;
              8'h49 : hs6 <= wr_d;
              8'h4A : hs5 <= wr_d;
              8'h4B : hs4 <= wr_d;
              8'h4C : hs3 <= wr_d;
              8'h4D : hs2 <= wr_d;
              8'h4E : hs1 <= wr_d;
              8'h4F : hs0 <= wr_d;
              // ECDSA VERIFICATION
              8'h80 : qx7 <= wr_d;
              8'h81 : qx6 <= wr_d;
              8'h82 : qx5 <= wr_d;
              8'h83 : qx4 <= wr_d;
              8'h84 : qx3 <= wr_d;
              8'h85 : qx2 <= wr_d;
              8'h86 : qx1 <= wr_d;
              8'h87 : qx0 <= wr_d;
              8'h88 : qy7 <= wr_d;
              8'h89 : qy6 <= wr_d;
              8'h8A : qy5 <= wr_d;
              8'h8B : qy4 <= wr_d;
              8'h8C : qy3 <= wr_d;
              8'h8D : qy2 <= wr_d;
              8'h8E : qy1 <= wr_d;
              8'h8F : qy0 <= wr_d;
              8'h90 : kr7 <= wr_d;
              8'h91 : kr6 <= wr_d;
              8'h92 : kr5 <= wr_d;
              8'h93 : kr4 <= wr_d;
              8'h94 : kr3 <= wr_d;
              8'h95 : kr2 <= wr_d;
              8'h96 : kr1 <= wr_d;
              8'h97 : kr0 <= wr_d;
              8'h98 : ds7 <= wr_d;
              8'h99 : ds6 <= wr_d;
              8'h9A : ds5 <= wr_d;
              8'h9B : ds4 <= wr_d;
              8'h9C : ds3 <= wr_d;
              8'h9D : ds2 <= wr_d;
              8'h9E : ds1 <= wr_d;
              8'h9F : ds0 <= wr_d;
              8'hA0 : hs7 <= wr_d;
              8'hA1 : hs6 <= wr_d;
              8'hA2 : hs5 <= wr_d;
              8'hA3 : hs4 <= wr_d;
              8'hA4 : hs3 <= wr_d;
              8'hA5 : hs2 <= wr_d;
              8'hA6 : hs1 <= wr_d;
              8'hA7 : hs0 <= wr_d;
              8'hC0 : d7  <= wr_d;
              8'hC1 : d6  <= wr_d;
              8'hC2 : d5  <= wr_d;
              8'hC3 : d4  <= wr_d;
              8'hC4 : d3  <= wr_d;
              8'hC5 : d2  <= wr_d;
              8'hC6 : d1  <= wr_d;
              8'hC7 : d0  <= wr_d;
              default : begin
              end
            endcase // case (addr)
         end else if (load_hash) begin
            {hs7, hs6, hs5, hs4, hs3, hs2, hs1, hs0} <= cert_msg;
         end else if (load_key) begin
            {kr7, kr6, kr5, kr4, kr3, kr2, kr1, kr0} <= k;
         end else if (load_res) begin
            {qx7, qx6, qx5, qx4, qx3, qx2, qx1, qx0} <= x;
            {qy7, qy6, qy5, qy4, qy3, qy2, qy1, qy0} <= y;
         end else if (load_d) begin
            ds7 <= d7;
            ds6 <= d6;
            ds5 <= d5;
            ds4 <= d4;
            ds3 <= d3;
            ds2 <= d2;
            ds1 <= d1;
            ds0 <= d0;
         end
      end
   end


   always @ (*) begin
      case (rd_addr)
        4'h0 : rd_d = qx7;
        4'h1 : rd_d = qx6;
        4'h2 : rd_d = qx5;
        4'h3 : rd_d = qx4;
        4'h4 : rd_d = qx3;
        4'h5 : rd_d = qx2;
        4'h6 : rd_d = qx1;
        4'h7 : rd_d = qx0;
        4'h8 : rd_d = qy7;
        4'h9 : rd_d = qy6;
        4'hA : rd_d = qy5;
        4'hB : rd_d = qy4;
        4'hC : rd_d = qy3;
        4'hD : rd_d = qy2;
        4'hE : rd_d = qy1;
        4'hF : rd_d = qy0;
      endcase // case (raddr)
   end

endmodule // ecc_mem
