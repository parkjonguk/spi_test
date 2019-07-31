module bridge (/*AUTOARG*/
   // Outputs
   l3_rd, l3_rd_vld, l3_wd_rdy, resp, resp_vld, mk_sel, ecc_sel, aria_sel,
   ssk_sel, hash_sel,
   // Inputs
   l3_sel, mk_resp_vld, mk_rd, mk_rd_vld, mk_resp, mk_wd_rdy, ecc_resp_vld,
   ecc_rd, ecc_rd_vld, ecc_resp, ecc_wd_rdy, aria_resp_vld, aria_rd,
   aria_rd_vld, aria_resp, aria_wd_rdy, ssk_resp_vld, ssk_rd, ssk_rd_vld,
   ssk_resp, ssk_wd_rdy, hash_resp_vld, hash_rd, hash_rd_vld, hash_resp,
   hash_wd_rdy
   ) ;
   output [31:0]        l3_rd;
   output               l3_rd_vld;
   output               l3_wd_rdy;
   output [7:0]         resp;
   output               resp_vld;

   input [3:0]          l3_sel;

   output               mk_sel;
   input                mk_resp_vld;
   input [31:0]         mk_rd;
   input                mk_rd_vld;
   input [7:0]          mk_resp;
   input                mk_wd_rdy;

   output               ecc_sel;
   input                ecc_resp_vld;
   input [31:0]         ecc_rd;
   input                ecc_rd_vld;
   input [7:0]          ecc_resp;
   input                ecc_wd_rdy;

   output               aria_sel;
   input                aria_resp_vld;
   input [31:0]         aria_rd;
   input                aria_rd_vld;
   input [7:0]          aria_resp;
   input                aria_wd_rdy;

   output               ssk_sel;
   input                ssk_resp_vld;
   input [31:0]         ssk_rd;
   input                ssk_rd_vld;
   input [7:0]          ssk_resp;
   input                ssk_wd_rdy;

   output               hash_sel;
   input                hash_resp_vld;
   input [31:0]         hash_rd;
   input                hash_rd_vld;
   input [7:0]          hash_resp;
   input                hash_wd_rdy;



   reg                  mk_sel;
   reg                  ecc_sel;
   reg                  ssk_sel;
   reg                  hash_sel;
   reg                  aria_sel;


   reg [31:0]           l3_rd;
   reg                  l3_rd_vld;
   reg                  l3_wd_rdy;
   reg [7:0]            resp;
   reg                  resp_vld;


   always @ (*) begin
      mk_sel   = 0;
      ecc_sel  = 0;
      ssk_sel  = 0;
      hash_sel = 0;
      aria_sel = 0;
      case (l3_sel)
        4'd1 : mk_sel   = 1;
        4'd2 : ssk_sel  = 1;
        4'd3 : ecc_sel  = 1;
        4'd4 : hash_sel = 1;
        4'd5 : aria_sel = 1;
      endcase // case (l3_sel)
   end

   always @ (*) begin
      case (l3_sel)
        4'd1 : begin
           l3_rd     = mk_rd;
           l3_rd_vld = mk_rd_vld;
           l3_wd_rdy = mk_wd_rdy;
           resp      = mk_resp;
           resp_vld  = mk_resp_vld;
        end
        4'd2 : begin
           l3_rd     = ssk_rd;
           l3_rd_vld = ssk_rd_vld;
           l3_wd_rdy = ssk_wd_rdy;
           resp      = ssk_resp;
           resp_vld  = ssk_resp_vld;
        end
        4'd3 : begin
           l3_rd     = ecc_rd;
           l3_rd_vld = ecc_rd_vld;
           l3_wd_rdy = ecc_wd_rdy;
           resp      = ecc_resp;
           resp_vld  = ecc_resp_vld;
        end
        4'd4 : begin
           l3_rd     = hash_rd;
           l3_rd_vld = hash_rd_vld;
           l3_wd_rdy = hash_wd_rdy;
           resp      = hash_resp;
           resp_vld  = hash_resp_vld;
        end
        4'd5 : begin
           l3_rd     = aria_rd;
           l3_rd_vld = aria_rd_vld;
           l3_wd_rdy = aria_wd_rdy;
           resp      = aria_resp;
           resp_vld  = aria_resp_vld;
        end
        default : begin
           l3_rd     = 32'd0;
           l3_rd_vld = 1'b0;
           l3_wd_rdy = 1'b0;
           resp      = 8'b11111111;
           resp_vld  = 1'b1;
        end
      endcase // case (l3_rd)
   end

endmodule // bridge

