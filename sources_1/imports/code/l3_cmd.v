module l3_cmd (/*AUTOARG*/
   // Outputs
   err_if_rdy, err_if_id, cmd_en, cmd_op, cmd_extend, wr_size,
   // Inputs
   clk, rst_n, clr_core, core_sel, id_err, l3_en, l3_op, l3_extend, l3_size,
   cmd_rdy
   ) ;
   // System Input
   input           clk, rst_n;
   // Clear Core Signal
   input           clr_core;
   // Bridge Selector
   input           core_sel;
   // ID Error
   input           id_err;
   // L3 Command Input
   input           l3_en;
   input [7:0]     l3_op;
   input [15:0]    l3_extend;
   input [15:0]    l3_size;
   // Error Response
   output          err_if_rdy;
   output          err_if_id;
   // Core CMD Interface
   input           cmd_rdy;
   output          cmd_en;
   output [7:0]    cmd_op;
   output [15:0]   cmd_extend;
   output [15:0]   wr_size;

   reg             err_if_rdy;
   reg             err_if_id;
   reg             cmd_en;
   reg [7:0]       cmd_op;
   reg [15:0]      cmd_extend;
   reg [15:0]      wr_size;


   reg             l3_update;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         cmd_op     <= 8'd0;
         cmd_extend <= 16'd0;
         wr_size    <= 16'd0;
      end else begin
         if(clr_core) begin
            cmd_op     <= 8'd0;
            cmd_extend <= 16'd0;
            wr_size    <= 16'd0;
         end else if(l3_update) begin
            cmd_op     <= l3_op;
            cmd_extend <= l3_extend;
            wr_size    <= l3_size;
         end
      end
   end

   localparam IDLE    = 4'b0001;
   localparam L3_EN = 4'b0010;
   localparam ID_ERR  = 4'b0100;
   localparam RDY_ERR = 4'b1000;

   reg [3:0]       state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         state <= state_nxt;
      end
   end

   always @ (*) begin
      state_nxt    = state;
      l3_update    = 0;
      cmd_en       = 0;
      err_if_rdy   = 0;
      err_if_id    = 0;
      case (state)
        IDLE    : begin
           if(core_sel & l3_en) begin
              if(id_err) begin
                 state_nxt  = ID_ERR;
              end else if (!cmd_rdy) begin
                 state_nxt  = RDY_ERR;
              end else begin
                 state_nxt  = L3_EN;
                 l3_update  = 1;
              end
           end
        end
        L3_EN  : begin
           state_nxt  = IDLE;
           cmd_en     = 1;
        end
        ID_ERR   : begin
           state_nxt  = IDLE;
           err_if_id  = 1;
        end
        RDY_ERR  : begin
           state_nxt  = IDLE;
           err_if_rdy = 1;
        end
      endcase // case (state)
   end






endmodule // l3_cmd
