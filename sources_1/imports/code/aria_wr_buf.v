module aria_wr_buf (/*AUTOARG*/
   // Outputs
   core_wd_rdy, wb_op_rdy, size_msg, bc_dec_en, wb_d, wb_d_vld, wb_d_lst,
   // Inputs
   clk, rst_n, clr_core, cmd_en, wr_size, l3_wd, l3_wd_vld, wb_op, wb_en,
   wb_one, wb_d_rdy
   ) ;
   // System Area
   input           clk, rst_n;
   input           clr_core;
   // L3 CMD
   input           cmd_en;
   input [15:0]    wr_size;
   // L3 WD
   input [31:0]    l3_wd;
   input           l3_wd_vld;
   output          core_wd_rdy;
   // ARIA CU OPEARATION
   // NM, CCM_A, CBC_D, CMAC
   output          wb_op_rdy;
   input [1:0]     wb_op;
   input           wb_en;
   input           wb_one;
   output [31:0]   size_msg;
   // CBC-HMAC
   output          bc_dec_en;
   // ARIA_BLK_D
   output [127:0]  wb_d;
   output          wb_d_vld;
   output          wb_d_lst;
   input           wb_d_rdy;


   /* OUTPUT Type */
   reg             core_wd_rdy;
   reg             wb_op_rdy;
   reg             wb_d_vld;
   reg             wb_d_lst;
   reg [31:0]      size_msg;

   wire [127:0]    wb_d;
   wire            bc_dec_en;

   /* Internal Register */
   reg [4:0]       ptr;
   reg [23:0]      wb_t;
   reg [31:0]      wb_m[0:3];


   /* Current Operation Buffer */
   reg             flg_cmac;
   reg             flg_cbcd;
   wire            flg_cbcd_nxt;
   wire            flg_cmac_nxt;

   assign flg_cbcd_nxt = (wb_op == 2'b10) ? 1'b1 : 1'b0;
   assign flg_cmac_nxt = (wb_op == 2'b11) ? 1'b1 : 1'b0;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         flg_cmac <= 1'b0;
         flg_cbcd <= 1'b0;
      end else begin
         if(wb_d_lst & wb_d_rdy) begin
            flg_cmac <= 1'b0;
            flg_cbcd <= 1'b0;
         end else if(wb_en) begin
            flg_cmac <= flg_cmac_nxt;
            flg_cbcd <= flg_cbcd_nxt;
         end
      end
   end

   assign bc_dec_en = flg_cbcd & l3_wd_vld & core_wd_rdy;

   /* ARIA Init Size */
   reg             size_update;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         size_msg <= 32'd0;
      end else begin
         if(clr_core) begin
            size_msg <= 32'd0;
         end else if (size_update) begin
            size_msg <= l3_wd;
         end
      end
   end

   // Current Memory Data
   reg [31:0]      wb_c;
   wire [1:0]      ah, al;
   assign ah    = ptr[3:2];
   assign al    = ptr[3:2] + 2'd1;

   always @ (*) begin
      wb_c = wb_m[ah];
   end

   // l3_wd
   wire   [31:0]  wd_dh;
   wire   [31:0]  wd_dl;
   wire   [31:0]  msk_pt;
   wire   [31:0]  msk_cd;
   wire   [63:0]  lsh_wd;
   assign msk_pt         = {32{1'b1}}     >> {ptr[1:0], 3'd0};
   assign msk_cd         = wb_c & (~msk_pt);
   assign lsh_wd         = {l3_wd, 32'd0} >> {ptr[1:0], 3'd0};
   assign {wd_dh, wd_dl} = {msk_cd, 32'd0} | lsh_wd;

   // Counter
   reg    [15:0] cntr;
   wire   [15:0] cntr_sub;
   wire   [15:0] cntr_nxt;
   wire          cntr_lst;
   wire          cntr_fin;

   assign cntr_sub   = cntr - 16'd4;
   assign cntr_nxt   = cntr_lst ? 16'd0 : cntr_sub;
   assign cntr_lst   = (cntr <  16'd5) ? 1 : 0;
   assign cntr_fin   = (cntr == 16'd0) ? 1 : 0;

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         cntr <= 16'd0;
      end else begin
         if(cmd_en) begin
            cntr <= wr_size;
         end else if(core_wd_rdy & l3_wd_vld) begin
            cntr <= cntr_nxt;
         end
      end
   end

   // Pointer
   wire [4:0]     ptr_add_lst;
   wire [4:0]     ptr_add_32b;
   wire [4:0]     ptr_nxt;
   wire           ptr_lst;
   assign ptr_add_lst    = ptr + cntr[2:0];
   assign ptr_add_32b    = ptr + 5'd4;
   assign ptr_nxt        = cntr_lst ? ptr_add_lst : ptr_add_32b;

   // CMAC PADDING
   wire [31:0]    rsh_one;
   wire [31:0]    pad_one;
   assign rsh_one = 32'h80000000 >> {ptr[1:0], 3'd0};
   assign pad_one = msk_cd | rsh_one;


   // Internal Memory
   reg            wb_update;
   reg            ccm_a_init;
   reg            cmac_pad;
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         wb_m[0] <= 32'd0;
         wb_m[1] <= 32'd0;
         wb_m[2] <= 32'd0;
         wb_m[3] <= 32'd0;
         wb_t    <= 24'd0;
         ptr     <= 5'd0;
      end else begin
         if(cmd_en | clr_core | ccm_a_init) begin
            wb_m[1] <= 32'd0;
            wb_m[2] <= 32'd0;
            wb_m[3] <= 32'd0;
            wb_t    <= 24'd0;
            if(ccm_a_init) begin
               wb_m[0] <= {wr_size, 16'd0};
               ptr     <= 5'd2;
            end else begin
               wb_m[0] <= 32'd0;
               ptr     <= 5'd0;
            end
         end else if(wb_update) begin
            wb_m[ah] <= wd_dh;
            ptr      <= ptr_nxt;
            if(ah == 2'b11) begin
               wb_t     <= wd_dl[31:8];
            end else begin
               wb_m[al] <= wd_dl;
            end
         end else if(wb_d_vld & wb_d_rdy) begin
            wb_m[0]  <= {wb_t, 8'd0};
            wb_m[1]  <= 32'd0;
            wb_m[2]  <= 32'd0;
            wb_m[3]  <= 32'd0;
            wb_t     <= 24'd0;
            ptr      <= {1'b0, ptr[3:0]};
         end else if(cmac_pad) begin
            wb_m[ah] <= pad_one;
         end
      end
   end

   assign wb_d = {wb_m[0], wb_m[1], wb_m[2], wb_m[3]};
   // State Transition

   localparam IDLE       = 7'b0000001;
   localparam CCM_ADD    = 7'b0000010;
   localparam RECEIVE    = 7'b0000100;
   localparam FULL       = 7'b0001000;
   localparam MAC_PAD    = 7'b0010000;
   localparam LAST_MSG   = 7'b0100000;
   localparam MSG_SIZE   = 7'b1000000;

   wire   full_lst;
   assign full_lst = cntr_fin & (ptr[1:0] == 2'd0);

   reg [6:0] state, state_nxt;

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
      state_nxt     = state;
      wb_op_rdy     = 0;
      wb_update     = 0;
      size_update   = 0;
      ccm_a_init    = 0;
      wb_d_vld      = 0;
      wb_d_lst      = 0;
      core_wd_rdy   = 0;
      cmac_pad      = 0;
      case (state)
        IDLE : begin
           wb_op_rdy    = 1;
           if(wb_one) begin
              state_nxt = MSG_SIZE;
           end else if(wb_en) begin
              if(wb_op == 2'b01) begin
                 state_nxt = CCM_ADD;
              end else begin
                 state_nxt = RECEIVE;
              end
           end
        end
        CCM_ADD : begin
           ccm_a_init = 1;
           state_nxt  = RECEIVE;
        end
        RECEIVE : begin
           if(ptr[4]) begin
              state_nxt     = FULL;
           end else if(cntr_fin)begin
              if(flg_cmac) begin
                 state_nxt = MAC_PAD;
              end else begin
                 state_nxt = LAST_MSG;
              end
           end else begin
              core_wd_rdy   = 1;
              if(l3_wd_vld) begin
                 wb_update  = 1;
              end
           end
        end
        FULL : begin
           wb_d_vld = 1;
           wb_d_lst = full_lst;
           if(wb_d_rdy) begin
              if(full_lst) begin
                 state_nxt = IDLE;
              end else begin
                 state_nxt = RECEIVE;
              end
           end
        end
        MAC_PAD : begin
           state_nxt = LAST_MSG;
           cmac_pad  = 1;
        end
        LAST_MSG : begin
           wb_d_vld = 1;
           wb_d_lst = 1;
           if(wb_d_rdy) begin
              state_nxt = IDLE;
           end
        end
        MSG_SIZE : begin
           core_wd_rdy    = 1;
           if(l3_wd_vld) begin
              state_nxt   = IDLE;
              size_update = 1;
           end
        end
      endcase // case (state)
   end




endmodule // aria_wr_buf
