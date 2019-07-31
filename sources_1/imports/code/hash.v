module hash (/*AUTOARG*/
   // Outputs
   hash_rdy, hash_done, hash_f, hash_o,
   // Inputs
   rst_n, msg_size, msg, key, hash_op, hash_en, hash_clr, clk, hash_m
   ) ;
   input  [511:0]       hash_m;
   output [511:0]       hash_f;
   output [511:0]       hash_o;
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                clk;                    // To CU of hash_cu.v, ...
   input                hash_clr;               // To CU of hash_cu.v
   input                hash_en;                // To CU of hash_cu.v
   input [4:0]          hash_op;                // To CU of hash_cu.v, ...
   input [511:0]        key;                    // To WR of hash_w.v
   input [1023:0]       msg;                    // To WR of hash_w.v
   input [31:0]         msg_size;               // To WR of hash_w.v
   input                rst_n;                  // To CU of hash_cu.v, ...
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output               hash_done;              // From CU of hash_cu.v
   output               hash_rdy;               // From CU of hash_cu.v
   // End of automatics
   /*AUTOREG*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 fn_en;                  // From CU of hash_cu.v
   wire [1:0]           fn_op;                  // From CU of hash_cu.v
   wire                 h_clr;                  // From CU of hash_cu.v
   wire                 h_flg_384;              // From CU of hash_cu.v
   wire                 h_flg_ovf;              // From WR of hash_w.v
   wire                 h_pad;                  // From CU of hash_cu.v
   wire                 h_run;                  // From CU of hash_cu.v
   wire [63:0]          k;                      // From KR of hash_k.v
   wire [63:0]          kw;                     // From KW of hash_kw.v
   wire                 kw_done;                // From KW of hash_kw.v
   wire                 kw_flg0;                // From KW of hash_kw.v
   wire                 kw_nxt;                 // From KW of hash_kw.v
   wire                 kw_vld;                 // From KW of hash_kw.v
   wire                 lst_en;                 // From CU of hash_cu.v
   wire [1:0]           lst_op;                 // From CU of hash_cu.v
   wire [6:0]           round;                  // From KW of hash_kw.v
   wire [63:0]          w;                      // From WR of hash_w.v
   wire                 w_en;                   // From CU of hash_cu.v
   wire [1:0]           w_op;                   // From CU of hash_cu.v
   // End of automatics

   wire [511:0]        hash_i;                 // To FN of hash_fn.v, ...
   assign hash_i = hash_op[4] ? hash_m : hash_o;
   hash_cu  CU  (/*AUTOINST*/
                 // Outputs
                 .hash_rdy              (hash_rdy),
                 .hash_done             (hash_done),
                 .h_clr                 (h_clr),
                 .h_pad                 (h_pad),
                 .h_run                 (h_run),
                 .w_op                  (w_op[1:0]),
                 .w_en                  (w_en),
                 .fn_op                 (fn_op[1:0]),
                 .fn_en                 (fn_en),
                 .lst_op                (lst_op[1:0]),
                 .lst_en                (lst_en),
                 .h_flg_384             (h_flg_384),
                 // Inputs
                 .clk                   (clk),
                 .rst_n                 (rst_n),
                 .hash_op               (hash_op[3:0]),
                 .hash_en               (hash_en),
                 .hash_clr              (hash_clr),
                 .kw_done               (kw_done),
                 .h_flg_ovf             (h_flg_ovf));
   hash_w   WR  (/*AUTOINST*/
                 // Outputs
                 .h_flg_ovf             (h_flg_ovf),
                 .w                     (w[63:0]),
                 // Inputs
                 .clk                   (clk),
                 .h_clr                 (h_clr),
                 .h_flg_384             (h_flg_384),
                 .h_pad                 (h_pad),
                 .hash_f                (hash_f[511:0]),
                 .hash_op               (hash_op[3:2]),
                 .key                   (key[511:0]),
                 .kw_done               (kw_done),
                 .kw_nxt                (kw_nxt),
                 .msg                   (msg[1023:0]),
                 .msg_size              (msg_size[31:0]),
                 .rst_n                 (rst_n),
                 .w_en                  (w_en),
                 .w_op                  (w_op[1:0]));
   hash_k   KR  (/*AUTOINST*/
                 // Outputs
                 .k                     (k[63:0]),
                 // Inputs
                 .round                 (round[6:0]));
   hash_kw  KW  (/*AUTOINST*/
                 // Outputs
                 .kw_vld                (kw_vld),
                 .kw_nxt                (kw_nxt),
                 .kw_flg0               (kw_flg0),
                 .kw_done               (kw_done),
                 .round                 (round[6:0]),
                 .kw                    (kw[63:0]),
                 // Inputs
                 .clk                   (clk),
                 .rst_n                 (rst_n),
                 .h_clr                 (h_clr),
                 .h_run                 (h_run),
                 .h_flg_384             (h_flg_384),
                 .w                     (w[63:0]),
                 .k                     (k[63:0]));
   hash_fn  FN  (/*AUTOINST*/
                 // Outputs
                 .hash_o                (hash_o[511:0]),
                 // Inputs
                 .clk                   (clk),
                 .rst_n                 (rst_n),
                 .fn_op                 (fn_op[1:0]),
                 .fn_en                 (fn_en),
                 .h_flg_384             (h_flg_384),
                 .kw_vld                (kw_vld),
                 .kw_done               (kw_done),
                 .kw_flg0               (kw_flg0),
                 .kw                    (kw[63:0]),
                 .hash_f                (hash_f[511:0]),
                 .hash_i                (hash_i[511:0]));
   hash_lst LS (/*AUTOINST*/
                // Outputs
                .hash_f                 (hash_f[511:0]),
                // Inputs
                .clk                    (clk),
                .rst_n                  (rst_n),
                .h_flg_384              (h_flg_384),
                .h_clr                  (h_clr),
                .lst_op                 (lst_op[1:0]),
                .lst_en                 (lst_en),
                .hash_i                 (hash_i[511:0]),
                .hash_o                 (hash_o[511:0]));
endmodule // hash
