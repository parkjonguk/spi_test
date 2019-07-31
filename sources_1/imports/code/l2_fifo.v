module l2_fifo (/*AUTOARG*/
   // Outputs
   empty, full, dout,
   // Inputs
   clk, rst_n, pin_l2_clr, wr, rd, din
   ) ;
   /* I/O Information */
   // system port
   input          clk, rst_n;
   // input port
   input          pin_l2_clr;
   input          wr;
   input          rd;
   input [31:0]   din;
   // output port
   output         empty;
   output         full;
   output [31:0]  dout;

   /* Output Type */
   wire           empty;
   wire           full;
   reg [31:0]     dout;

   /* Internal Register */
   reg [4:0]      rd_ptr;
   reg [4:0]      wr_ptr;
   reg [5:0]      st;
   reg [31:0]     mem[0:31];

   /* Internal Variable */

   /* Variable Assignment */
   assign empty   = (st == 6'd0)  ? 1 : 0;
   assign full    = (st == 6'd32) ? 1 : 0;

   /* Register Assignment */
   // read pointer
   wire [4:0]     rd_ptr_nxt;
   assign rd_ptr_nxt = rd_ptr + 5'd1;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         rd_ptr <= 5'd0;
      end else begin
         if(pin_l2_clr) begin
            rd_ptr <= 5'd0;
         end else if(rd & !empty) begin
            rd_ptr <= rd_ptr_nxt;
         end
      end
   end
   // write pointer
   wire [4:0]     wr_ptr_nxt;
   assign wr_ptr_nxt = wr_ptr + 5'd1;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         wr_ptr <= 5'd0;
      end else begin
         if(pin_l2_clr) begin
            wr_ptr <= 5'd0;
         end else if(wr & !full) begin
            wr_ptr <= wr_ptr_nxt;
         end
      end
   end
   //status counter
   wire [6:0]     st_add, st_sub;
   assign st_add = st + 6'd1;
   assign st_sub = st - 6'd1;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         st <= 6'd0;
      end else begin
         if(pin_l2_clr) begin
            st <= 6'd0;
         end else if((wr & !full) & !(rd & !empty)) begin
            st <= st_add;
         end else if(!(wr & !full) & (rd & !empty)) begin
            st <= st_sub;
         end
      end
   end
   //dout
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         dout <= 32'd0;
      end else begin
         if(pin_l2_clr) begin
            dout <= 32'd0;
         end else if(rd & !empty) begin
            dout <= mem[rd_ptr];
         end
      end
   end
   //mem
   always @ (posedge clk) begin
      if(wr & !full) begin
         mem[wr_ptr] <= din;
      end
   end
endmodule // l2_fifo
