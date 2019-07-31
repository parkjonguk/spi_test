`define IDX32(x) 32*(x+1)-1:32*(x)
module rd_ctrl (/*AUTOARG*/
   // Outputs
   rd_d,
   // Inputs
   rd_addr, hash_f
   ) ;
   input  [3:0]   rd_addr;
   input  [511:128] hash_f;
   output [31:0]  rd_d;

   wire   [383:0] rdd;

   reg [31:0]     rd_d;

   assign rdd = hash_f[511:128];

   always @ (*) begin
      case (rd_addr)
        4'd0  : rd_d = rdd[`IDX32(11)];
        4'd1  : rd_d = rdd[`IDX32(10)];
        4'd2  : rd_d = rdd[`IDX32( 9)];
        4'd3  : rd_d = rdd[`IDX32( 8)];
        4'd4  : rd_d = rdd[`IDX32( 7)];
        4'd5  : rd_d = rdd[`IDX32( 6)];
        4'd6  : rd_d = rdd[`IDX32( 5)];
        4'd7  : rd_d = rdd[`IDX32( 4)];
        4'd8  : rd_d = rdd[`IDX32( 3)];
        4'd9  : rd_d = rdd[`IDX32( 2)];
        4'd10 : rd_d = rdd[`IDX32( 1)];
        4'd11 : rd_d = rdd[`IDX32( 0)];
        default : rd_d = 32'd0;
      endcase // case (rd_addr)
   end

endmodule // rd_ctrl
