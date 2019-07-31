module size_ctrl (/*AUTOARG*/
   // Outputs
   size0, size1,
   // Inputs
   clk, rst_n, s1_flg_384, wr_size, cmd_extend, size0_clr, size0_add, size1_clr,
   size1_en, size1_op
   ) ;
   input           clk, rst_n;

   input           s1_flg_384;
   input [15:0]    wr_size;
   input [15:0]    cmd_extend;

   input           size0_clr;
   input           size0_add;
   output [31:0]   size0;

   // SIZE ADDING FUNCTION
   input           size1_clr;
   input           size1_en;
   input  [1:0]    size1_op;
   output [31:0]   size1;

   reg [31:0]      size0, size1;

   wire [31:0]     size0_nxt;
   assign size0_nxt = size0 + wr_size;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         size0 <= 32'd0;
      end else begin
         if(size0_clr) begin
            size0 <= 32'd0;
         end else if (size0_add) begin
            size0 <= size0_nxt;
         end
      end
   end

   reg   [31:0] size1_nxt;
   wire  [31:0] size1_add;
   wire [31:0]  size1_add2;
   wire  [31:0] size1_a32;
   wire  [31:0] size1_a48;
   wire  [31:0] size1_ahs;

   assign size1_add  = size1 + wr_size;
   assign size1_a32  = size1 + 16'd32;
   assign size1_a48  = size1 + 16'd48;
   assign size1_ahs  = s1_flg_384 ? size1_a48 : size1_a32;
   assign size1_add2 = size1 + cmd_extend;

   always @ (*) begin
      case (size1_op)
        2'b00 : size1_nxt = {16'd0, wr_size};
        2'b01 : size1_nxt = size1_add;
        2'b10 : size1_nxt = size1_add2;
        2'b11 : size1_nxt = size1_ahs;
      endcase // case (size1_op)
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         size1 <= 32'd0;
      end else begin
         if (size1_clr) begin
            size1 <= 32'd0;
         end else if(size1_en)begin
            size1 <= size1_nxt;
         end
      end
   end


endmodule // size_ctrl
