module hash_cu (/*AUTOARG*/
   // Outputs
   hash_rdy, hash_done, h_clr, h_pad, h_run, w_op, w_en, fn_op, fn_en, lst_op,
   lst_en, h_flg_384,
   // Inputs
   clk, rst_n, hash_op, hash_en, hash_clr, kw_done, h_flg_ovf
   ) ;
   // System Input
   input          clk, rst_n;
   // CU
   input [3:0]    hash_op;
   input          hash_en;
   input          hash_clr;
   output         hash_rdy;
   output         hash_done;

   input          kw_done;
   input          h_flg_ovf;

   output         h_clr;
   output         h_pad;
   output         h_run;

   output [1:0]   w_op;
   output         w_en;
   output [1:0]   fn_op;
   output         fn_en;
   output [1:0]   lst_op;
   output         lst_en;

   output         h_flg_384;

   /* OUTPUT Type */
   reg            hash_rdy;
   reg            h_clr;
   reg            h_pad;
   reg            h_run;
   reg [1:0]      w_op, fn_op, lst_op;
   reg            w_en, fn_en, lst_en;
   reg            h_flg_384;
   reg            h_flg_mac;
   reg            h_flg_lst;
   reg            hash_done;

   /* Internal Register */
   // Operation Flag
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         h_flg_mac <= 1'b0;
         h_flg_384 <= 1'b0;
         h_flg_lst <= 1'b0;
      end else begin
         if(h_clr) begin
            h_flg_mac <= 1'b0;
            h_flg_384 <= 1'b0;
            h_flg_lst <= 1'b0;
         end else if (hash_en) begin
            h_flg_mac <= hash_op[3];
            h_flg_384 <= hash_op[2];
            h_flg_lst <= hash_op[1];
         end
      end
   end

   // Last Flag
   reg            flg_lst;
   reg            flg_lst_up;
   reg            flg_lst_down;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_lst <= 1'b0;
      end else begin
         if(hash_en | flg_lst_down) begin
            flg_lst <= 1'b0;
         end else if(flg_lst_up) begin
            flg_lst <= 1'b1;
         end
      end
   end

   // Opad Flag
   reg   flg_opad;
   reg   flg_opad_up;
   reg   flg_opad_down;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_opad <= 1'b0;
      end else begin
         if(hash_en | flg_opad_down) begin
            flg_opad <= 1'b0;
         end else if(flg_opad_up) begin
            flg_opad <= 1'b1;
         end
      end
   end

   localparam IDLE     = 11'b00000000001;
   localparam INIT     = 11'b00000000010;
   localparam RUN      = 11'b00000000100;
   localparam PAD      = 11'b00000001000;
   localparam CLR      = 11'b00000010000;
   localparam BUSY     = 11'b00000100000;
   localparam HNXT     = 11'b00001000000;
   localparam RCHK     = 11'b00010000000;
   localparam OPAD     = 11'b00100000000;
   localparam HOUT     = 11'b01000000000;
   localparam DONE     = 11'b10000000000;



   /* State Transition */
   reg   [10:0] state, state_nxt;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
      end else begin
         if(hash_clr) begin
            state <= CLR;
         end else begin
            state <= state_nxt;
         end
      end
   end


   always @ (*) begin
      state_nxt     = state;
      hash_rdy      = 0;
      h_clr         = 0;
      h_pad         = 0;
      h_run         = 0;
      w_en          = 0;
      w_op          = 2'b00;
      fn_en         = 0;
      fn_op         = 2'b00;
      lst_en        = 0;
      lst_op        = 2'b00;
      hash_done     = 0;
      flg_opad_up   = 0;
      flg_opad_down = 0;
      flg_lst_up    = 0;
      flg_lst_down  = 0;
      case (state)
        IDLE     : begin
           hash_rdy     = 1;
           if(hash_en) begin
              w_en      = 1;
              lst_en    = 1;
              fn_en     = 1;
              state_nxt = (INIT << hash_op[1:0]);
           end
        end
        INIT     : begin
           fn_op  = 2'b01;
           fn_en  = 1;
           lst_op = 2'b01;
           lst_en = 1;
           if(h_flg_mac) begin
              w_op      = 2'b01;
              w_en      = 1;
              state_nxt = RUN;
           end else begin
              h_clr = 1;
              state_nxt = DONE;
           end
        end
        RUN       : begin
           h_run         = 1;
           state_nxt     = BUSY;
        end
        PAD      : begin
           h_pad         = 1;
           lst_op        = 2'b11;
           lst_en        = 1;
           state_nxt     = RUN;
        end
        CLR      : begin
           fn_op         = 2'b11;
           fn_en         = 1;
           lst_op        = 2'b11;
           lst_en        = 1;
           h_clr         = 1;
           state_nxt     = DONE;
        end
        BUSY     : begin
           if(kw_done) begin
              if(flg_opad) begin
                 state_nxt     = OPAD;
              end else begin
                 state_nxt     = HNXT;
              end
           end
        end
        HNXT     : begin
           fn_op         = 2'b10;
           fn_en         = 1;
           if(flg_opad) begin
              state_nxt     = PAD;
              flg_opad_down = 1;
           end else if(h_flg_lst) begin
              state_nxt     = RCHK;
           end else begin
              state_nxt     = DONE;
           end
        end
        RCHK     : begin
           if(h_flg_ovf) begin
              state_nxt = PAD;
           end else begin
              state_nxt = HOUT;
           end
        end
        OPAD     : begin
           lst_op      = 2'b01;
           lst_en      = 1;
           w_op        = 2'b11;
           w_en        = 1;
           state_nxt   = HNXT;
        end
        HOUT     : begin
           lst_en         = 1;
           lst_op         = 2'b10;
           if(h_flg_mac) begin
              fn_en       = 1;
              if(flg_lst) begin
                 fn_op         = 2'b11;
                 state_nxt     = DONE;
                 flg_lst_down  = 1;
              end else begin
                 fn_op       = 2'b01;
                 w_op          = 2'b10;
                 w_en          = 1;
                 state_nxt     = RUN;
                 flg_lst_up    = 1;
                 flg_opad_up   = 1;
              end
           end else begin
              state_nxt     = DONE;
           end
        end
        DONE     : begin
           hash_done = 1;
           state_nxt = IDLE;
        end
      endcase // case (state)
   end
endmodule // hash_cu
