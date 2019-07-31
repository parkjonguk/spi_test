
/////////////////////////////////////////////////////////////////////////////
/////////// PRIORITY DECODER FOR PORT 0
/////////////////////////////////////////////////////////////////////////////
// There are 2 masters connected to port 0 :
//	master 0
//	master 1

module ml_ahb_prio_port_0(
   prio,
   decod
   );
   
input [5:0] prio;
output [1:0] decod;

wire [2:0] a0_0;
wire [2:0] a0_1;

wire [1:0] res1_0;

assign a0_0 = prio[2:0];
assign a0_1 = prio[5:3];

assign res1_0 = (a0_1 < a0_0 )?2'b10:2'b01;

assign decod = res1_0;

endmodule
