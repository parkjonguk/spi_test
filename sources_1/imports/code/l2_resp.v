module l2_resp (/*AUTOARG*/
   // Outputs
   resp_err, resp_done, sw0, sw1, resp_rdy,
   // Inputs
   clk, rst_n, pin_l2_clr, l3_en, l3_cmd_done, err_timeout, resp, resp_vld
   ) ;
   /* I/O Information */
   // System Input
   input          clk, rst_n;
   input          pin_l2_clr;

   input          l3_en;
   input          l3_cmd_done;
   input          err_timeout;

   output         resp_err;
   output         resp_done;

   output [7:0]   sw0, sw1;

   input  [7:0]   resp;
   input          resp_vld;
   output         resp_rdy;

   wire [7:0]     sw0, sw1;

   reg            resp_rdy;
   reg            resp_done;
   reg            resp_err;

   reg [3:0]      cntr;
   reg [7:0]      sw1_r;
   reg            cntr_up;
   wire [3:0]     cntr_nxt;
   assign cntr_nxt = cntr + 4'd1;


   assign sw0 = 8'd0;
   assign sw1 = {sw1_r[7:6], (sw1_r[5:4]) | {resp_err, resp_err}, sw1_r[3:0]};

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         cntr      <= 4'd0;
         sw1_r     <= 8'd0;
         cntr_up   <= 1'b0;
      end else begin
         if(l3_en) begin
            cntr      <= 4'd0;
            sw1_r     <= 8'd0;
            cntr_up   <= 1'b0;
         end else if(resp_vld & resp_rdy) begin
            sw1_r     <= resp;
            cntr      <= 4'd0;
            cntr_up   <= 1'b1;
         end else if(cntr[3])begin
            cntr      <= 4'd0;
            cntr_up   <= 1'b0;
         end else if(cntr_up)begin
            cntr      <= cntr_nxt;
         end
      end
   end

   localparam IDLE     = 7'b0000001;
   localparam W0       = 7'b0000010;
   localparam W1       = 7'b0000100;
   localparam RDY      = 7'b0001000;
   localparam W8       = 7'b0010000;
   localparam DONE     = 7'b0100000;
   localparam ERR      = 7'b1000000;

   reg   [6:0] state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(pin_l2_clr) begin
            state <= IDLE;
         end else begin
            state <= state_nxt;
         end
      end
   end


   always @ (*) begin
      state_nxt    = state;
      resp_rdy     = 0;
      resp_done    = 0;
      resp_err     = 0;
      case (state)
        IDLE   : begin
           if(l3_en) begin
              state_nxt   = W0;
           end
        end
        W0     : begin
           state_nxt   = W1;
        end
        W1     : begin
           state_nxt   = RDY;
        end
        RDY    : begin
           resp_rdy     = 1;
           if(resp_vld) begin
              state_nxt = W8;
           end else if(err_timeout) begin
              state_nxt = ERR;
           end
        end
        W8     : begin
           if(cntr[3]) begin
              state_nxt = DONE;
           end
        end
        DONE   : begin
           resp_done    = 1;
           if(l3_cmd_done) begin
              state_nxt  = IDLE;
           end
        end
        ERR    : begin
           resp_err     = 1;
           if(l3_cmd_done) begin
              state_nxt  = IDLE;
           end
        end
      endcase // case (state)
   end

endmodule // l2_resp
