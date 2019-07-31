module fifo_32x16 (/*AUTOARG*/
   // Outputs
   full, empty, dout,
   // Inputs
   clk, reset, wr_en, rd_en, din
   ) ;
   input         clk;
   input         reset;
   input         wr_en;
   input         rd_en;
   input  [31:0] din;

   output        full;
   output        empty;
   output [31:0] dout;


   reg [3 :0]     wr_point, rd_point;
   reg [31:0]     mem[0:15];
   reg [31:0]    dout;

   wire          full, empty;
   wire [3:0]   wr_next;
   wire [3:0]   rd_next;

   assign wr_next = wr_point + 1;
   assign rd_next = rd_point + 1;

   assign empty = (wr_point == rd_point) ? 1 : 0;
   assign full  = (wr_next  == rd_point) ? 1 : 0;

   always @ (posedge clk or posedge reset) begin
      if(reset) begin
         wr_point <= {4{1'b0}};
      end else begin
         if(!full && wr_en) begin
            wr_point <= wr_next;
         end
      end
   end

   always @ (posedge clk or posedge reset) begin
      if(reset) begin
         rd_point <= {4{1'b0}};
      end else begin
         if(!empty && rd_en) begin
            rd_point <= rd_next;
         end
      end
   end

   integer i;

   always @ (posedge clk or posedge reset) begin
      if(reset) begin
         for(i = 0; i < 16; i = i + 1) begin
            mem[i] <= 32'd0;
         end
      end else begin
         if(!full && wr_en) begin
            mem[wr_point] <= din;
         end
      end
   end

   always @ (posedge clk or posedge reset) begin
      if(reset) begin
         dout <= 32'd0;
      end else begin
         if(!empty & rd_en) begin
            dout <= mem[rd_point];
         end
      end
   end

endmodule // fifo_32x16
