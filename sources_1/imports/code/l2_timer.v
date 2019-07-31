module l2_timer (/*AUTOARG*/
   // Outputs
   err_timeout,
   // Inputs
   clk, rst_n, pin_timer_disable, l3_en, l3_cmd_done, timer_stop
   ) ;
   /* I/O Information */
   // System Input
   input          clk, rst_n;
   input          pin_timer_disable;
   // RX FIFO Control
   input          l3_en;
   input          l3_cmd_done;
   input          timer_stop;
   output         err_timeout;

   reg [20:0]     counter;
   reg            timer_on;
   wire [20:0]    counter_nxt;
   wire           err_timeout;

   assign counter_nxt = counter + 21'd1;
   assign err_timeout = (!pin_timer_disable) & counter[20];

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         counter  <= 21'd0;
         timer_on <= 1'b0;
      end else begin
         if(l3_en) begin
            counter  <= 21'd0;
            timer_on <= 1'b1;
         end else if(l3_cmd_done | timer_stop | counter[20]) begin
            counter  <= 21'd0;
            timer_on <= 1'b0;
         end else if(timer_on) begin
            counter <= counter_nxt;
         end
      end
   end
endmodule // l2_timer
