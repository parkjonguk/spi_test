module l3_wr (/*AUTOARG*/
   // Outputs
   core_wd_rdy, wr_d, wr_addr, wr_en,
   // Inputs
   clk, rst_n, clr_core, cmd_en, wr_size, wr_open, l3_wd, l3_wd_vld
   ) ;
   input           clk, rst_n;
   input           clr_core;
   input           cmd_en;
   input  [15:0]   wr_size;
   input           wr_open;

   input [31:0]    l3_wd;
   input           l3_wd_vld;
   output          core_wd_rdy;

   output [31:0]   wr_d;
   output [13:0]   wr_addr;
   output          wr_en;

   reg             core_wd_rdy;
   reg             wr_en;
   reg [31:0]      wr_d;
   wire [13:0]     wr_addr;

   reg             i_clr;
   reg  [15:0]     cntr;
   wire [15:0]     cntr_nxt;
   wire            run;
   assign cntr_nxt = cntr + 16'd4;
   assign run      = (wr_size > cntr) ? 1'b1 : 1'b0;
   assign wr_addr  = cntr[15:2];

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         cntr <= 16'd0;
      end else begin
         if(clr_core | wr_open | i_clr) begin
            cntr <= 16'd0;
         end else if(wr_en) begin
            cntr <= cntr_nxt;
         end
      end
   end


   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         wr_d <= 32'd0;
      end else begin
         if(i_clr | clr_core | cmd_en) begin
            wr_d <= 32'd0;
         end else if(l3_wd_vld & core_wd_rdy) begin
            wr_d <= l3_wd;
         end
      end
   end


   localparam IDLE     = 4'b0001;
   localparam RX_DATA  = 4'b0010;
   localparam WR_DATA  = 4'b0100;
   localparam CLEAR    = 4'b1000;

   reg [3:0]       state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(clr_core | cmd_en) begin
            state <= IDLE;
         end else begin
            state <= state_nxt;
         end
      end
   end

   always @ (*) begin
      state_nxt    = state;
      core_wd_rdy  = 0;
      wr_en        = 0;
      i_clr        = 0;
      case (state)
        IDLE    : begin
           if(wr_open) begin
              state_nxt = RX_DATA;
           end
        end
        RX_DATA  : begin
           core_wd_rdy  = 1;
           if(!run) begin
              state_nxt = CLEAR;
           end else if(l3_wd_vld)begin
              state_nxt = WR_DATA;
           end
        end
        WR_DATA  : begin
           state_nxt  = RX_DATA;
           wr_en      = 1;
        end
        CLEAR    : begin
           i_clr      = 1;
           state_nxt  = IDLE;
        end
      endcase // case (state)
   end

endmodule // l3_wr
