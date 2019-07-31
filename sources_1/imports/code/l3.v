module l3 (/*AUTOARG*/
   // Outputs
   wr_en, wr_d, wr_addr, rd_en, rd_addr, core_wd_rdy, core_resp_vld, core_resp,
   core_rd_vld, core_rd, cmd_op, wr_size, cmd_extend, cmd_en,
   // Inputs
   wr_open, rst_n, resp_res, resp_rdy, resp_err, resp_done, rd_open, rd_d,
   l3_wd_vld, l3_wd, l3_size, l3_rd_rdy, l3_op, l3_extend, l3_en, id_err,
   core_sel, cmd_rdy, clr_core, clk
   ) ;
   output [15:0]        wr_size;
   output [15:0]        cmd_extend;
   output               cmd_en;
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                clk;                    // To CH_CMD of l3_cmd.v, ...
   input                clr_core;               // To CH_CMD of l3_cmd.v, ...
   input                cmd_rdy;                // To CH_CMD of l3_cmd.v
   input                core_sel;               // To CH_CMD of l3_cmd.v, ...
   input                id_err;                 // To CH_CMD of l3_cmd.v
   input                l3_en;                  // To CH_CMD of l3_cmd.v, ...
   input [15:0]         l3_extend;              // To CH_CMD of l3_cmd.v
   input [7:0]          l3_op;                  // To CH_CMD of l3_cmd.v
   input                l3_rd_rdy;              // To CH_RD of l3_rd.v
   input [15:0]         l3_size;                // To CH_CMD of l3_cmd.v
   input [31:0]         l3_wd;                  // To CH_WR of l3_wr.v
   input                l3_wd_vld;              // To CH_WR of l3_wr.v
   input [31:0]         rd_d;                   // To CH_RD of l3_rd.v
   input                rd_open;                // To CH_RD of l3_rd.v
   input                resp_done;              // To CH_RESP of l3_resp.v
   input [1:0]          resp_err;               // To CH_RESP of l3_resp.v
   input                resp_rdy;               // To CH_RESP of l3_resp.v
   input [3:0]          resp_res;               // To CH_RESP of l3_resp.v
   input                rst_n;                  // To CH_CMD of l3_cmd.v, ...
   input                wr_open;                // To CH_WR of l3_wr.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [7:0]         cmd_op;                 // From CH_CMD of l3_cmd.v
   output [31:0]        core_rd;                // From CH_RD of l3_rd.v
   output               core_rd_vld;            // From CH_RD of l3_rd.v
   output [7:0]         core_resp;              // From CH_RESP of l3_resp.v
   output               core_resp_vld;          // From CH_RESP of l3_resp.v
   output               core_wd_rdy;            // From CH_WR of l3_wr.v
   output [13:0]        rd_addr;                // From CH_RD of l3_rd.v
   output               rd_en;                  // From CH_RD of l3_rd.v
   output [13:0]        wr_addr;                // From CH_WR of l3_wr.v
   output [31:0]        wr_d;                   // From CH_WR of l3_wr.v
   output               wr_en;                  // From CH_WR of l3_wr.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 err_if_id;              // From CH_CMD of l3_cmd.v
   wire                 err_if_rdy;             // From CH_CMD of l3_cmd.v
   // End of automatics
   /*AUTOREG*/

   l3_cmd  CH_CMD  (/*AUTOINST*/
                    // Outputs
                    .err_if_rdy         (err_if_rdy),
                    .err_if_id          (err_if_id),
                    .cmd_en             (cmd_en),
                    .cmd_op             (cmd_op[7:0]),
                    .cmd_extend         (cmd_extend[15:0]),
                    .wr_size            (wr_size[15:0]),
                    // Inputs
                    .clk                (clk),
                    .rst_n              (rst_n),
                    .clr_core           (clr_core),
                    .core_sel           (core_sel),
                    .id_err             (id_err),
                    .l3_en              (l3_en),
                    .l3_op              (l3_op[7:0]),
                    .l3_extend          (l3_extend[15:0]),
                    .l3_size            (l3_size[15:0]),
                    .cmd_rdy            (cmd_rdy));
   l3_wr   CH_WR   (/*AUTOINST*/
                    // Outputs
                    .core_wd_rdy        (core_wd_rdy),
                    .wr_d               (wr_d[31:0]),
                    .wr_addr            (wr_addr[13:0]),
                    .wr_en              (wr_en),
                    // Inputs
                    .clk                (clk),
                    .rst_n              (rst_n),
                    .clr_core           (clr_core),
                    .cmd_en             (cmd_en),
                    .wr_size            (wr_size[15:0]),
                    .wr_open            (wr_open),
                    .l3_wd              (l3_wd[31:0]),
                    .l3_wd_vld          (l3_wd_vld));
   l3_rd   CH_RD   (/*AUTOINST*/
                    // Outputs
                    .core_rd_vld        (core_rd_vld),
                    .core_rd            (core_rd[31:0]),
                    .rd_addr            (rd_addr[13:0]),
                    .rd_en              (rd_en),
                    // Inputs
                    .clk                (clk),
                    .rst_n              (rst_n),
                    .clr_core           (clr_core),
                    .cmd_en             (cmd_en),
                    .cmd_extend         (cmd_extend[15:0]),
                    .rd_open            (rd_open),
                    .l3_rd_rdy          (l3_rd_rdy),
                    .rd_d               (rd_d[31:0]));
   l3_resp CH_RESP (/*AUTOINST*/
                    // Outputs
                    .core_resp          (core_resp[7:0]),
                    .core_resp_vld      (core_resp_vld),
                    // Inputs
                    .clk                (clk),
                    .rst_n              (rst_n),
                    .clr_core           (clr_core),
                    .l3_en              (l3_en),
                    .core_sel           (core_sel),
                    .err_if_id          (err_if_id),
                    .err_if_rdy         (err_if_rdy),
                    .resp_done          (resp_done),
                    .resp_err           (resp_err[1:0]),
                    .resp_res           (resp_res[3:0]),
                    .resp_rdy           (resp_rdy));

endmodule // l3
