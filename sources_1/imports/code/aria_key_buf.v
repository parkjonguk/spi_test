module aria_key_buf (/*AUTOARG*/
   // Outputs
   kb_d_rdy, key,
   // Inputs
   clk, rst_n, clr_core, kb_op, kb_en, kb_clr, wb_d, kb_d_vld, sw_blk_k,
   cw_blk_k
   ) ;
   // System Area
   input           clk, rst_n;
   input           clr_core;
   // Key Buffer OP
   input [1:0]     kb_op; // 128, 256, SW, CW
   input           kb_en;
   input           kb_clr;
   // IO
   input [127:0]   wb_d;
   input           kb_d_vld;
   output          kb_d_rdy;
   // SSK
   input [255:0]   sw_blk_k;
   input [255:0]   cw_blk_k;
   output [255:0]  key;

   reg [255:0]     key;
   reg             kb_d_rdy;

   reg [255:0]     k_nxt;
   reg [1:0]       sel;
   always @ (*) begin
      case (sel)
        2'b00 : k_nxt = {wb_d, 128'd0};
        2'b01 : k_nxt = {key[255:128], wb_d};
        2'b10 : k_nxt = sw_blk_k;
        2'b11 : k_nxt = cw_blk_k;
      endcase // case (sel)
   end

   reg           new_k;
   reg           clr_k;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         key <= 256'd0;
      end else begin
         if(clr_core | kb_clr | clr_k) begin
            key <= 256'd0;
         end else if(new_k) begin
            key <= k_nxt;
         end
      end
   end

   localparam   IDLE    = 6'b000001;
   localparam   CMD_K0  = 6'b000010;
   localparam   CMD_K1  = 6'b000100;
   localparam   CMD_SK  = 6'b001000;
   localparam   CMD_CK  = 6'b010000;
   localparam   CMD_K2  = 6'b100000;

   reg   [5:0] state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(kb_clr | clr_core) begin
            state <= IDLE;
         end else begin
            state <= state_nxt;
         end
      end
   end

   always @ (*) begin
      state_nxt    = state;
      sel          = 2'b00;
      new_k        = 0;
      clr_k        = 0;
      kb_d_rdy     = 0;
      case (state)
        IDLE       : begin
           if(kb_en) begin
              clr_k     = 1;
              state_nxt = CMD_K0 << kb_op;
           end
        end
        CMD_K0     : begin
           sel          = 2'b00;
           kb_d_rdy     = 1;
           if(kb_d_vld) begin
              new_k     = 1;
              state_nxt = IDLE;
           end
        end
        CMD_K1     : begin
           sel          = 2'b00;
           kb_d_rdy     = 1;
           if(kb_d_vld) begin
              new_k     = 1;
              state_nxt = CMD_K2;
           end
        end
        CMD_SK     : begin
           sel       = 2'b10;
           new_k     = 1;
           state_nxt = IDLE;
        end
        CMD_CK     : begin
           sel       = 2'b11;
           new_k     = 1;
           state_nxt = IDLE;
        end
        CMD_K2     : begin
           sel       = 2'b01;
           kb_d_rdy     = 1;
           if(kb_d_vld) begin
              new_k     = 1;
              state_nxt = IDLE;
           end
        end
      endcase // case (state)
   end




endmodule // aria_key_buf
