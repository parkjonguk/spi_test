
/////////////////////////////////////////////////////////////////////////////
/////////// ARBITRATION FOR PORT 1
/////////////////////////////////////////////////////////////////////////////
// There are 2 masters connected to port 1 :
//	master 0
//	master 1

module ml_ahb_arb_port_1 (
   round_robin,
   priority_level,
   hclk,
   resetn,
   mx_sel,
   mx_htrans0,
   hready,
   mx_arb_grant
   );

/////////////////////////////////////////////
// parameter must not mbe modified by user (already set to correct value)
parameter NB_MASTER_PORT = 2; // number of master plugged to this slave
parameter PRIO_WIDTH = 1; // represent number of bit needed to encode priority (Log2(NB_MASTER_PORT)) : is NB_MASTER_PORT=2 -> 1 bit, NB_MASTER_PORT = 4 -> 2 bits ... 

/////////////////////////////////////////////
// parameter to be left untouched by user
parameter PRIO_IDX_WIDTH = (((NB_MASTER_PORT)>4096)? (((NB_MASTER_PORT)>262144)? (((NB_MASTER_PORT)>2097152)? (((NB_MASTER_PORT)>8388608)? 24 : (((NB_MASTER_PORT)> 4194304)? 23 : 22)) : (((NB_MASTER_PORT)>1048576)? 21 : (((NB_MASTER_PORT)>524288)? 20 : 19))) : (((NB_MASTER_PORT)>32768)? (((NB_MASTER_PORT)>131072)?  18 : (((NB_MASTER_PORT)>65536)? 17 : 16)) : (((NB_MASTER_PORT)>16384)? 15 : (((NB_MASTER_PORT)>8192)? 14 : 13)))) : (((NB_MASTER_PORT)>64)? (((NB_MASTER_PORT)>512)?  (((NB_MASTER_PORT)>2048)? 12 : (((NB_MASTER_PORT)>1024)? 11 : 10)) : (((NB_MASTER_PORT)>256)? 9 : (((NB_MASTER_PORT)>128)? 8 : 7))) : (((NB_MASTER_PORT)>8)? (((NB_MASTER_PORT)> 32)? 6 : (((NB_MASTER_PORT)>16)? 5 : 4)) : (((NB_MASTER_PORT)>4)? 3 : (((NB_MASTER_PORT)>2)? 2 : 1)))));

input   round_robin; // if high round robin algo is used
input  [(NB_MASTER_PORT*PRIO_WIDTH) - 1 : 0] priority_level;
input   hclk;
input   resetn;
input   [NB_MASTER_PORT-1:0] mx_sel; // request from endpoint
input   [NB_MASTER_PORT-1:0] mx_htrans0; // re-arbitration is only possible during IDLE or NON-SEQ
input   hready;     // used to know that current transfer is not stalled
output  [NB_MASTER_PORT-1:0] mx_arb_grant; // grant



wire no_new_arbitration_allowed;
wire [NB_MASTER_PORT-1:0]  mx_arb_grant; 
reg  [NB_MASTER_PORT-1:0]  mx_arb_grant_d; 
reg  mx_arb_granted; 
reg  [NB_MASTER_PORT-1:0]  mx_arb_deny_d;
wire [(NB_MASTER_PORT*( PRIO_WIDTH +1 )) - 1 : 0] rr_priority_level; // this is internally generated priority for Round-Robin algorithm 
wire [(NB_MASTER_PORT*( PRIO_WIDTH +2 )) - 1 : 0] transfer_priority_level; //
wire [NB_MASTER_PORT-1:0] mx_access_req; 
reg  [NB_MASTER_PORT-1:0]  rr_high_prio_master; // this vector indicates to which master is given highest priority
wire                       rr_rotate; // this signal indicates that new transfer has started and that round-robin can be rotated
wire [NB_MASTER_PORT-1:0] mx_arb_grant_decoded; 



wire [NB_MASTER_PORT-1:0] nseq_access;
wire [NB_MASTER_PORT-1:0] seq_access;


//////////////////////////////////
// Arbitration scheme
//////////////////////////////////

assign nseq_access = mx_sel & ~mx_htrans0; // non sequential access is on going
assign seq_access  = mx_sel &  mx_htrans0; // sequential access is on going

assign no_new_arbitration_allowed = (|(seq_access & mx_arb_grant_d[NB_MASTER_PORT-1:0]))|~hready; // cannot rearbitrate if a seq access that was granted is on going   

assign mx_access_req = ( mx_sel |  mx_arb_deny_d);// fill array of requestor


assign rr_priority_level = F_RR_PRIORITY_LEVEL(priority_level,rr_high_prio_master,round_robin);
assign transfer_priority_level = F_PRIORITY_ARRAY(mx_access_req,rr_priority_level);

// rotate round robin after first new access
assign rr_rotate = (|(nseq_access|mx_arb_deny_d)) & ~no_new_arbitration_allowed;


ml_ahb_prio_port_1 ml_ahb_prio_port_1(
   .prio(transfer_priority_level),
   .decod(mx_arb_grant_decoded)
   );
   
   


assign mx_arb_grant = ((no_new_arbitration_allowed)?mx_arb_grant_d:mx_arb_grant_decoded)&{NB_MASTER_PORT{mx_access_req}};


//////////////////////////////////////////////////
// register value of current hgrant for later use
always @ (posedge hclk or negedge resetn) begin
   if (~resetn) begin
      mx_arb_grant_d <= {NB_MASTER_PORT{1'b0}};
   end
   else begin
      if (hready == 1'b1) begin
         mx_arb_grant_d <= mx_arb_grant;
      end
   end
end

//////////////////////////////////////////////////
// set arb_deny if access was asked and refused.
// this signal is used to know that this master
// must be granted when its turns comes.
integer arb_idx;
always @ (posedge hclk or negedge resetn) begin
   if (~resetn) begin
      mx_arb_deny_d <= {NB_MASTER_PORT{1'b0}};
   end
   else begin   
      for(arb_idx=0; arb_idx < NB_MASTER_PORT ; arb_idx=arb_idx+1) begin
         if (mx_arb_grant[arb_idx] == 1'b1) begin
            mx_arb_deny_d[arb_idx] <= 1'b0;  // access was granted
         end
         else begin
            if ( (nseq_access[arb_idx] == 1'b1 )&&(mx_arb_grant[arb_idx]==1'b0) == 1'b1 ) begin  // access was asked and not granted
               mx_arb_deny_d[arb_idx] <= 1'b1;
            end
         end
      end
   end
end



//////////////////////////////////////////////////
// assign high priority to master selected by round-robin algo
always @ (posedge hclk or negedge resetn) begin
   if (~resetn) begin
      rr_high_prio_master <= {{(NB_MASTER_PORT-1){1'b1}},1'b0}; // note that bit with 0 indicates master with highest priority (a bit confusing but it is the way it is).
   end
   else begin 
      if (rr_rotate == 1'b1) begin
         rr_high_prio_master <= F_ROTATE_LEFT(rr_high_prio_master);
      end
   end
end

//////////////////////////////////////////////////////
// this function concatenate priority array
// from Round-Robin and a bit from transfer
// asked
function [(NB_MASTER_PORT*( PRIO_WIDTH +2 )) - 1 : 0] F_PRIORITY_ARRAY;
   
   input [NB_MASTER_PORT - 1 : 0 ] transfer_ok_array;
   input [(NB_MASTER_PORT*( PRIO_WIDTH +1 )) - 1 : 0] priority_level_array; 

   integer i;
   integer j;

   begin
      for(i=0;i<NB_MASTER_PORT;i=i+1)begin
         for(j=0;j<PRIO_WIDTH+1;j=j+1)begin
            F_PRIORITY_ARRAY[i*(PRIO_WIDTH+2)+j]=priority_level_array[i*(PRIO_WIDTH+1)+j]; // copy priority level in LSB
         end
         F_PRIORITY_ARRAY[i*(PRIO_WIDTH+2)+PRIO_WIDTH+1]=~transfer_ok_array[i]; // if transfer_ok is not set MSB is set to 1 (lowest priority)
      end
   end
endfunction





//////////////////////////////////////////////////////
// This function is used to generate
// array of priority level.
// priority from prgogramed register and priority from Round-Robin algo 
// are mixed together

function [(NB_MASTER_PORT * (PRIO_WIDTH +1) ) - 1  : 0 ] F_RR_PRIORITY_LEVEL; // one extra bit is need for round robin algo
   input [(NB_MASTER_PORT * PRIO_WIDTH) -1 : 0 ] priority_in;
   input [NB_MASTER_PORT -1 : 0 ] rr_priority; // indicates which master is selected by RR algo
   input use_round_robin;
   
   integer i;
   integer j;
   integer k;
   integer l;
   
   begin


   k=0;
   l=0;
   
   for(i=0;i<NB_MASTER_PORT;i=i+1)begin
   
      for(j=0;j<=PRIO_WIDTH;j=j+1) begin
      
         if(j==PRIO_WIDTH) begin
            F_RR_PRIORITY_LEVEL[l]=(use_round_robin==1'b1)?rr_priority[i]:1'b1; // if round robin is used concatenate with rr_priority, if not put 1.
         end
         else begin
            F_RR_PRIORITY_LEVEL[l]=priority_in[k];
            k=k+1;
         end
         l=l+1;
         
      end
      
   end
   
   end
   
endfunction
   



//////////////////////////////////////////////////
// This function forbid re-arbitration
//function F_NO_NEW_ARB

 

//////////////////////////////////////////////////
// this function does a logical left rotate on input vector.

function   [NB_MASTER_PORT-1:0] F_ROTATE_LEFT;
   input [NB_MASTER_PORT-1:0] val;
   
   integer i;
   
   begin
   
   for(i=0;i<NB_MASTER_PORT;i=i+1)begin
      F_ROTATE_LEFT[i]=(i==0)?val[NB_MASTER_PORT-1]:val[i-1];
   end
   
   end
endfunction
      
endmodule


