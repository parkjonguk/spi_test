module moo_size_buf (/*AUTOARG*/
   // Outputs
   msg_done, msg_lst, remain_size, size_add,
   // Inputs
   clk, rst_n, clr_core, size_msg, remain_nxt, remain_up, add_size_en, wr_size
   ) ;
   input  clk, rst_n;
   input  clr_core;

   input  [31:0] size_msg;
   output        msg_done;
   output        msg_lst;

   input         remain_nxt;
   input         remain_up;
   output [31:0] remain_size;

   input         add_size_en;
   input  [15:0] wr_size;
   output [15:0] size_add;


   wire          msg_done;
   wire          msg_lst;
   reg [31:0]    remain_size;
   reg [15:0]    size_add;



   wire [31:0]   remain_sub;
   wire [31:0]   remain_size_nxt;

   assign remain_sub      = remain_size - 32'd16;
   assign msg_lst         = (remain_size < 32'd17) ? 1'b1 : 1'b0;
   assign msg_done        = (remain_size == 32'd0) ? 1'b1 : 1'b0;
   assign remain_size_nxt = msg_lst ? 32'd0 : remain_sub;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         remain_size <= 32'd0;
      end else begin
         if(remain_up) begin
            remain_size <= size_msg;
         end else if(remain_nxt) begin
            remain_size <= remain_size_nxt;
         end
      end
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         size_add <= 16'd0;
      end else begin
         if(clr_core) begin
            size_add <= 16'd0;
         end else if(add_size_en) begin
            size_add <= wr_size;
         end
      end
   end

endmodule // moo_size_buf
