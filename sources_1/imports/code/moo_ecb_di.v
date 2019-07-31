module moo_ecb_di (/*AUTOARG*/
   // Outputs
   ecb_di,
   // Inputs
   clk, rst_n, clr_core, ecb_di_en, ecb_iv_en, ecb_di_clr, ctr_4b, ctr_4w, wb_d,
   iv
   ) ;
   input           clk, rst_n;
   input           clr_core;
   // ECB OP
   input           ecb_di_en;
   input           ecb_iv_en;
   input           ecb_di_clr;
   // CTR OP
   input           ctr_4b;
   input           ctr_4w;
   // BLK Input
   input [127:0]   wb_d;
   input [127:0]   iv;
   // Output Port
   output [127:0]  ecb_di;

   reg [127:0]     ecb_di;

   reg           c0;
   reg           ctr_loop;
   wire [31:0]   sum_4b;
   wire [31:0]   sum_4w;
   wire          carry;
   assign sum_4b          = ecb_di[31:0] + 32'd1;
   assign {carry, sum_4w} = ecb_di[31:0] + c0;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         ecb_di <= 128'd0;
      end else begin
         if(clr_core | ecb_di_clr) begin
            ecb_di <= 128'd0;
         end else if(ecb_iv_en) begin
            ecb_di <= iv;
         end else if(ecb_di_en) begin
            ecb_di <= wb_d;
         end else if(ctr_4b) begin
            ecb_di <= {ecb_di[127:32], sum_4b};
         end else if(ctr_loop) begin
            ecb_di <= {sum_4w, ecb_di[127:32]};
         end
      end
   end

   reg   [3:0] cntr;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         cntr <= 4'b0000;
      end else begin
         if(ctr_4w) begin
            cntr <= 4'b0001;
         end else if(ctr_loop) begin
            cntr <= {cntr[2:0],1'b0};
         end
      end
   end


   localparam IDLE  = 3'b001;
   localparam SUM   = 3'b010;
   localparam LOOP  = 3'b100;

   reg   [2:0] state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(clr_core | ecb_di_clr) begin
            state <= IDLE;
         end else begin
            state <= state_nxt;
         end
      end
   end


   always @ (*) begin
      state_nxt  = state;
      ctr_loop   = 0;
      c0         = 0;
      case (state)
        IDLE : begin
           if(ctr_4w) begin
              state_nxt = SUM;
           end
        end
        SUM  : begin
           ctr_loop = 1;
           c0       = 1;
           if(cntr[3]) begin
              state_nxt = IDLE;
           end else if(!carry) begin
              state_nxt = LOOP;
           end
        end
        LOOP : begin
           ctr_loop = 1;
           if(cntr[3]) begin
              state_nxt = IDLE;
           end
        end
      endcase // case (state)
   end

endmodule // moo_ecb_di
