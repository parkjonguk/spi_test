module l3_resp (/*AUTOARG*/
   // Outputs
   core_resp, core_resp_vld,
   // Inputs
   clk, rst_n, clr_core, l3_en, core_sel, err_if_id, err_if_rdy, resp_done,
   resp_err, resp_res, resp_rdy
   ) ;
   input           clk, rst_n;
   input           clr_core;

   input           l3_en;
   input           core_sel;

   input           err_if_id;
   input           err_if_rdy;
   input           resp_done;
   input [1:0]     resp_err;
   input [3:0]     resp_res;

   input           resp_rdy;
   output [7:0]    core_resp;
   output          core_resp_vld;

   reg [1:0]       head;
   reg [1:0]       err;
   reg [3:0]       res;
   reg             core_resp_vld;

   assign core_resp = {head, err, res};


   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         err <= 2'b00;
         res <= 4'd0;
      end else begin
         if(clr_core | (core_sel & l3_en)) begin
            err <= 2'b00;
            res <= 4'd0;
         end else if(resp_done) begin
            err <= resp_err;
            res <= resp_res;
         end else if(resp_rdy & core_resp_vld) begin
            err <= 2'b00;
            res <= 4'd0;
         end
      end
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         head <= 2'b00;
      end else begin
         if(clr_core | (core_sel & l3_en)) begin
            head <= 2'b00;
         end else if(err_if_id | err_if_rdy) begin
            head <= {err_if_id, err_if_rdy};
         end else if(resp_rdy & core_resp_vld) begin
            head <= 2'b00;
         end
      end
   end

   always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
         core_resp_vld <= 1'b0;
      end else begin
         if(clr_core | (core_sel & l3_en)) begin
            core_resp_vld <= 1'b0;
         end else if(err_if_id | err_if_rdy | resp_done)begin
            core_resp_vld <= 1'b1;
         end else if(resp_rdy & core_resp_vld) begin
            core_resp_vld <= 1'b0;
         end
      end
   end

endmodule // l3_resp
