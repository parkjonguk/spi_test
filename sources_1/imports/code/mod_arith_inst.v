//-----------------------------------------------------------------------------
// Title         : Instruction Decoder for Modular Arithmetic
// Project       : ECC 1.1
//-----------------------------------------------------------------------------
// File          : mod_arith_inst.v
// Author        : Haeyoung Kim  <ryoung0327@gmail.com>
// Created       : 17.11.2018
// Last modified : 15.12.2018
//-----------------------------------------------------------------------------
// Description :
//  - Instruction Decoder for Modular Arithmetic
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by ISLAB This model is the confidential and
// proprietary property of ISLAB and the possession or use of this
// file requires a written license from ISLAB.
//------------------------------------------------------------------------------
// Modification history :
// 17.11.2018 : created by Haeyoung Kim
// 15.12.2018 : Code refactoring by Haeyoung Kim
//-----------------------------------------------------------------------------
module mod_arith_inst (/*AUTOARG*/
   // Outputs
   inst_nxt, inst_last, flg_mul, flg_s,
   // Inputs
   clk, rst_n, inst_op, inst_en, ap_nxt, an_nxt
   ) ;
   input        clk;
   input        rst_n;

   input [1:0]  inst_op;
   input        inst_en;

   input  [1:0] ap_nxt, an_nxt;


   output [1:0] inst_nxt;
   output       inst_last;

   output       flg_mul;
   output       flg_s;


   /* Local Parameter */
   localparam INST_MUL_INIT = 2'b00;
   localparam INST_DIV_INIT = 2'b01;
   localparam INST_NEXT     = 2'b10;
   localparam INST_CLEAR    = 2'b11;

   localparam MQRTR         = 2'b00;
   localparam MHLV          = 2'b01;
   localparam MADD          = 2'b10;
   localparam MADD_SWP      = 2'b11;

   /* Output Type */
   reg [1:0]    inst_nxt;
   reg          flg_mul;
   wire         flg_s;
   wire         inst_last;

   /* Internal Register */
   reg [1:0]    r_op, sel_op;
   reg [8:0]    r_p,  sel_p, p_nxt;
   reg [8:0]    r_d,  sel_d, d_nxt;
   reg          r_s,  sel_s, s_nxt;
   reg          sel_flg_mul;

   assign       flg_s = r_s;

   /* Internal Function 1: Calculate Next Register Input*/
   wire [8:0]   p_sub1, p_sub2;
   wire [8:0]   d_sub1, d_sub2, d_add1, d_add2;

   wire         flg_d_eq_1;
   wire         flg_d_eq_2;
   wire         flg_d_eq_3;
   wire         flg_p_eq_1;

   assign p_sub1      = r_p - 9'd1;
   assign p_sub2      = r_p - 9'd2;

   assign d_sub1      = r_d - 9'd1;
   assign d_sub2      = r_d - 9'd2;
   assign d_add1      = r_d + 9'd1;
   assign d_add2      = r_d + 9'd2;

   assign flg_d_eq_1  = (r_d == 9'd1) ? 1 : 0;
   assign flg_d_eq_2  = (r_d == 9'd2) ? 1 : 0;
   assign flg_d_eq_3  = (r_d == 9'd3) ? 1 : 0;
   assign flg_p_eq_1  = (r_p == 9'd1) ? 1 : 0;


   /* Internal Function 2 : Select Current OP Results */
   always @ (*) begin
      s_nxt = r_s;
      d_nxt = r_d;
      p_nxt = r_p;
	    case(r_op)
		    MQRTR : begin
			     if(r_s == 1'b0) begin
				      if(flg_d_eq_3)
					      s_nxt = 1;
				      if(!flg_d_eq_2)begin
					       d_nxt = d_sub2;
				      end else begin
					       p_nxt = p_sub1;
					       s_nxt = 1;
              end
			     end else begin
				      d_nxt = d_add2;
				      if(flg_p_eq_1)begin
					       s_nxt = 0;
					       p_nxt = p_sub1;
				      end else begin
					       p_nxt = p_sub2;
				      end
			     end
		    end
		    MHLV  : begin
			     if(r_s == 1'b0) begin
				      d_nxt = d_sub1;
				      if(flg_d_eq_2)
					      s_nxt = 1;
			     end else begin
			        d_nxt = d_add1;
			        p_nxt = p_sub1;
			     end
		    end
		    MADD : begin
           if(flg_mul) begin
              if(flg_p_eq_1) begin
                 p_nxt = p_sub1;
                 s_nxt = 0;
              end else begin
                 p_nxt = p_sub2;
              end
           end else if(r_s == 1'b1) begin
              p_nxt = p_sub1;
              d_nxt = d_add1;
			     end else begin
              d_nxt = d_sub1;
              if(flg_d_eq_2)
                s_nxt = 1;
			     end
		    end
		    MADD_SWP : begin
			     d_nxt = d_sub1;
			     if(!flg_d_eq_2)
				     s_nxt = 0;
		    end
	    endcase
   end

   /* Internal Function 3 : Select Next OP */
   // RSD_TBINARY(AP, AN)
   wire [1:0]   bin_nxt_a;
   assign       bin_nxt_a = ap_nxt - an_nxt;

   always @ (*) begin
      case (bin_nxt_a[1:0])
        2'b00 : begin
           inst_nxt = MQRTR;
        end
        2'b10 : begin
           inst_nxt = MHLV;
        end
        default : begin
           if(!inst_op[1] | flg_mul) begin
              inst_nxt = MADD;
           end else if(s_nxt == 1'b0 | d_nxt == 8'd1) begin
              inst_nxt = MADD;
           end else begin
              inst_nxt = MADD_SWP;
           end
        end
      endcase // case (bin_a[1:0])
   end

   /* Internal Function 4 : External Flag */
   assign inst_last  = (p_nxt == 9'd0) ? 1 : 0;


   /* Internal Function 5 : Internal Register Input Selector */
   always @ (*) begin
      case (inst_op)
        INST_MUL_INIT: begin
           sel_p         = 9'd257;
           sel_d         = 9'd1;
           sel_s         = 1'b1;
           sel_op        = inst_nxt;
           sel_flg_mul   = 1'b1;
        end
        INST_DIV_INIT: begin
           sel_p         = 9'd257;
           sel_d         = 9'd1;
           sel_s         = 1;
           sel_op        = inst_nxt;
           sel_flg_mul   = 1'b0;
        end
        INST_NEXT: begin
           sel_p         = p_nxt;
           sel_d         = d_nxt;
           sel_s         = s_nxt;
           sel_op        = inst_nxt;
           sel_flg_mul   = flg_mul;
        end
        INST_CLEAR: begin
           sel_p         = 9'd0;
           sel_d         = 9'd0;
           sel_s         = 0;
           sel_op        = 2'd0;
           sel_flg_mul   = 0;
        end
      endcase // case (inst_op)
   end
   /* Internal Function 5 : Internal Register */
   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         r_p          <= 9'd0;
         r_d          <= 9'd0;
         r_s          <= 0;
         r_op         <= 2'd0;
         flg_mul    <= 0;
      end else begin
         if(inst_en) begin
            r_p         <= sel_p;
            r_d         <= sel_d;
            r_s         <= sel_s;
            r_op        <= sel_op;
            flg_mul     <= sel_flg_mul;
         end
      end
   end

endmodule // op_patch
