
/////////////////////////////////////////////////////////////////////////////
/////////// ADDRESS DECODER FOR MASTER 1
/////////////////////////////////////////////////////////////////////////////
// master 1 can address :
//
//		slave 0
//		slave 1

`include "define.v"

module ml_ahb_decoder_master_1(
   haddr31_downto_16,  // AHB address from master
   mapped_to_common,
   hsel,   // Selection to slave_endpoint
   hsel_default); // Selection to default slave, active if address does not match any address range defined
   
   input [31:16]   haddr31_downto_16;
   input [0:0] mapped_to_common;
   output [1:0]   hsel;
   output hsel_default;

   wire [31:0] mapping0;
   wire [31:0] mapping1;
   wire [31:0] common_mapping;


   assign mapping0=`AHB_SLAVE_ADDR_0;
   assign mapping1=`AHB_SLAVE_ADDR_1;
   assign common_mapping=`AHB_ADDR_COMMON;


   wire [16 -1:0] xor_0;
   wire match_0;

   assign xor_0=(haddr31_downto_16[31:16] ^ mapping0[31:16]);
   assign match_0=~(|xor_0);

   wire [16 -1:0] xor_common_0;
   wire [16 -1:0] xor_common_masked_0;
   wire match_common_0;

   assign xor_common_0=(haddr31_downto_16[30:24] ^ common_mapping[30:24]);
   assign xor_common_masked_0 = xor_common_0 | ~({ 16 {mapped_to_common==0}} );
   assign match_common_0=~(|xor_common_masked_0);
   assign hsel[0] = match_0 | match_common_0;

   wire [16 -1:0] xor_1;
   wire match_1;

   assign xor_1=(haddr31_downto_16[31:16] ^ mapping1[31:16]);
   assign match_1=~(|xor_1);

   assign hsel[1] = match_1;



   assign hsel_default = ((|hsel) == 1'b0)?1'b1:1'b0;

endmodule
