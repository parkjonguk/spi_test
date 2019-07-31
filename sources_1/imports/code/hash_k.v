module hash_k (/*AUTOARG*/
   // Outputs
   k,
   // Inputs
   round
   ) ;
   input  [6:0]  round;
   output [63:0] k;
   wire   [63:0] k;

   wire [31:0]   kh;
   wire [31:0]   kl;
   assign k = {kh, kl};

   hash_kh CST_H (/*AUTOINST*/
                  // Outputs
                  .kh                   (kh[31:0]),
                  // Inputs
                  .round             (round[6:0]));
   hash_kl CST_L (/*AUTOINST*/
                  // Outputs
                  .kl                   (kl[31:0]),
                  // Inputs
                  .round             (round[6:0]));
endmodule // hash_k

module hash_kh (/*AUTOARG*/
   // Outputs
   kh,
   // Inputs
   round
   ) ;
   input [6:0]   round;

   output [31:0] kh;

   reg  [31:0]   kh;

   always @ (*) begin
      case (round)
        7'd00 : kh = 32'h428a2f98;
        7'd01 : kh = 32'h71374491;
        7'd02 : kh = 32'hb5c0fbcf;
        7'd03 : kh = 32'he9b5dba5;
        7'd04 : kh = 32'h3956c25b;
        7'd05 : kh = 32'h59f111f1;
        7'd06 : kh = 32'h923f82a4;
        7'd07 : kh = 32'hab1c5ed5;
        7'd08 : kh = 32'hd807aa98;
        7'd09 : kh = 32'h12835b01;
        7'd10 : kh = 32'h243185be;
        7'd11 : kh = 32'h550c7dc3;
        7'd12 : kh = 32'h72be5d74;
        7'd13 : kh = 32'h80deb1fe;
        7'd14 : kh = 32'h9bdc06a7;
        7'd15 : kh = 32'hc19bf174;
        7'd16 : kh = 32'he49b69c1;
        7'd17 : kh = 32'hefbe4786;
        7'd18 : kh = 32'h0fc19dc6;
        7'd19 : kh = 32'h240ca1cc;
        7'd20 : kh = 32'h2de92c6f;
        7'd21 : kh = 32'h4a7484aa;
        7'd22 : kh = 32'h5cb0a9dc;
        7'd23 : kh = 32'h76f988da;
        7'd24 : kh = 32'h983e5152;
        7'd25 : kh = 32'ha831c66d;
        7'd26 : kh = 32'hb00327c8;
        7'd27 : kh = 32'hbf597fc7;
        7'd28 : kh = 32'hc6e00bf3;
        7'd29 : kh = 32'hd5a79147;
        7'd30 : kh = 32'h06ca6351;
        7'd31 : kh = 32'h14292967;
        7'd32 : kh = 32'h27b70a85;
        7'd33 : kh = 32'h2e1b2138;
        7'd34 : kh = 32'h4d2c6dfc;
        7'd35 : kh = 32'h53380d13;
        7'd36 : kh = 32'h650a7354;
        7'd37 : kh = 32'h766a0abb;
        7'd38 : kh = 32'h81c2c92e;
        7'd39 : kh = 32'h92722c85;
        7'd40 : kh = 32'ha2bfe8a1;
        7'd41 : kh = 32'ha81a664b;
        7'd42 : kh = 32'hc24b8b70;
        7'd43 : kh = 32'hc76c51a3;
        7'd44 : kh = 32'hd192e819;
        7'd45 : kh = 32'hd6990624;
        7'd46 : kh = 32'hf40e3585;
        7'd47 : kh = 32'h106aa070;
        7'd48 : kh = 32'h19a4c116;
        7'd49 : kh = 32'h1e376c08;
        7'd50 : kh = 32'h2748774c;
        7'd51 : kh = 32'h34b0bcb5;
        7'd52 : kh = 32'h391c0cb3;
        7'd53 : kh = 32'h4ed8aa4a;
        7'd54 : kh = 32'h5b9cca4f;
        7'd55 : kh = 32'h682e6ff3;
        7'd56 : kh = 32'h748f82ee;
        7'd57 : kh = 32'h78a5636f;
        7'd58 : kh = 32'h84c87814;
        7'd59 : kh = 32'h8cc70208;
        7'd60 : kh = 32'h90befffa;
        7'd61 : kh = 32'ha4506ceb;
        7'd62 : kh = 32'hbef9a3f7;
        7'd63 : kh = 32'hc67178f2;
        7'd64 : kh = 32'hca273ece;
        7'd65 : kh = 32'hd186b8c7;
        7'd66 : kh = 32'heada7dd6;
        7'd67 : kh = 32'hf57d4f7f;
        7'd68 : kh = 32'h06f067aa;
        7'd69 : kh = 32'h0a637dc5;
        7'd70 : kh = 32'h113f9804;
        7'd71 : kh = 32'h1b710b35;
        7'd72 : kh = 32'h28db77f5;
        7'd73 : kh = 32'h32caab7b;
        7'd74 : kh = 32'h3c9ebe0a;
        7'd75 : kh = 32'h431d67c4;
        7'd76 : kh = 32'h4cc5d4be;
        7'd77 : kh = 32'h597f299c;
        7'd78 : kh = 32'h5fcb6fab;
        7'd79 : kh = 32'h6c44198c;
        default : kh = 32'd0;
      endcase // case (round)
   end

endmodule // hash_kh

module hash_kl (/*AUTOARG*/
   // Outputs
   kl,
   // Inputs
   round
   ) ;
   input [6:0]   round;

   output [31:0] kl;

   reg [31:0]    kl;

   always @ (*) begin
      case (round)
        7'd00 : kl = 32'hd728ae22;
        7'd01 : kl = 32'h23ef65cd;
        7'd02 : kl = 32'hec4d3b2f;
        7'd03 : kl = 32'h8189dbbc;
        7'd04 : kl = 32'hf348b538;
        7'd05 : kl = 32'hb605d019;
        7'd06 : kl = 32'haf194f9b;
        7'd07 : kl = 32'hda6d8118;
        7'd08 : kl = 32'ha3030242;
        7'd09 : kl = 32'h45706fbe;
        7'd10 : kl = 32'h4ee4b28c;
        7'd11 : kl = 32'hd5ffb4e2;
        7'd12 : kl = 32'hf27b896f;
        7'd13 : kl = 32'h3b1696b1;
        7'd14 : kl = 32'h25c71235;
        7'd15 : kl = 32'hcf692694;
        7'd16 : kl = 32'h9ef14ad2;
        7'd17 : kl = 32'h384f25e3;
        7'd18 : kl = 32'h8b8cd5b5;
        7'd19 : kl = 32'h77ac9c65;
        7'd20 : kl = 32'h592b0275;
        7'd21 : kl = 32'h6ea6e483;
        7'd22 : kl = 32'hbd41fbd4;
        7'd23 : kl = 32'h831153b5;
        7'd24 : kl = 32'hee66dfab;
        7'd25 : kl = 32'h2db43210;
        7'd26 : kl = 32'h98fb213f;
        7'd27 : kl = 32'hbeef0ee4;
        7'd28 : kl = 32'h3da88fc2;
        7'd29 : kl = 32'h930aa725;
        7'd30 : kl = 32'he003826f;
        7'd31 : kl = 32'h0a0e6e70;
        7'd32 : kl = 32'h46d22ffc;
        7'd33 : kl = 32'h5c26c926;
        7'd34 : kl = 32'h5ac42aed;
        7'd35 : kl = 32'h9d95b3df;
        7'd36 : kl = 32'h8baf63de;
        7'd37 : kl = 32'h3c77b2a8;
        7'd38 : kl = 32'h47edaee6;
        7'd39 : kl = 32'h1482353b;
        7'd40 : kl = 32'h4cf10364;
        7'd41 : kl = 32'hbc423001;
        7'd42 : kl = 32'hd0f89791;
        7'd43 : kl = 32'h0654be30;
        7'd44 : kl = 32'hd6ef5218;
        7'd45 : kl = 32'h5565a910;
        7'd46 : kl = 32'h5771202a;
        7'd47 : kl = 32'h32bbd1b8;
        7'd48 : kl = 32'hb8d2d0c8;
        7'd49 : kl = 32'h5141ab53;
        7'd50 : kl = 32'hdf8eeb99;
        7'd51 : kl = 32'he19b48a8;
        7'd52 : kl = 32'hc5c95a63;
        7'd53 : kl = 32'he3418acb;
        7'd54 : kl = 32'h7763e373;
        7'd55 : kl = 32'hd6b2b8a3;
        7'd56 : kl = 32'h5defb2fc;
        7'd57 : kl = 32'h43172f60;
        7'd58 : kl = 32'ha1f0ab72;
        7'd59 : kl = 32'h1a6439ec;
        7'd60 : kl = 32'h23631e28;
        7'd61 : kl = 32'hde82bde9;
        7'd62 : kl = 32'hb2c67915;
        7'd63 : kl = 32'he372532b;
        7'd64 : kl = 32'hea26619c;
        7'd65 : kl = 32'h21c0c207;
        7'd66 : kl = 32'hcde0eb1e;
        7'd67 : kl = 32'hee6ed178;
        7'd68 : kl = 32'h72176fba;
        7'd69 : kl = 32'ha2c898a6;
        7'd70 : kl = 32'hbef90dae;
        7'd71 : kl = 32'h131c471b;
        7'd72 : kl = 32'h23047d84;
        7'd73 : kl = 32'h40c72493;
        7'd74 : kl = 32'h15c9bebc;
        7'd75 : kl = 32'h9c100d4c;
        7'd76 : kl = 32'hcb3e42b6;
        7'd77 : kl = 32'hfc657e2a;
        7'd78 : kl = 32'h3ad6faec;
        7'd79 : kl = 32'h4a475817;
        default : kl = 32'd0;
      endcase // case (round)
   end
endmodule // hash_kl
