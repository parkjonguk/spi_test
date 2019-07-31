//
/////////////////////////////////////////////////////////////////////////////
/////////// PORT 0 
/////////////////////////////////////////////////////////////////////////////
//    Port 0 is connected to 2 masters:
//	master 0
//	master 1
//
//    and to 2 slaves (default slave included):
//	slave 0


`include "define.v"


module ml_ahb_port_0(
   round_robin,
   priority_level,
   // clocks and resets
   resetn,
   hclk,

   // from/to master X
   mx_hsel,
   mx_haddr,
   mx_htrans,
   mx_hsize,
   mx_hburst,
   mx_hwrite,
   mx_hwdata,
   mx_hready_in,
   mx_hready,
   mx_hresp,
   mx_hrdata,
   // from/to slave
   hsel,
   haddr,
   htrans,
   hsize,
   hburst,
   hwrite,
   hwdata,
   hready,
   hresp,
   hrdata);
   
`define ML_AHB_PATH_FSM_STATE_WIDTH  8   


// following parameter must NOT be modified (already set to correct value)
parameter ADDR_WIDTH = 32;
parameter NB_MASTER_PORT = 2;
//parameter PRIO_WIDTH = 2; // represent number of bit needed to encode priority (Log2(NB_MASTER_PORT)) : is NB_MASTER_PORT=2 -> 1 bit, NB_MASTER_PORT = 4 -> 2 bits ... 
parameter PRIO_WIDTH = 1; // represent number of bit needed to encode priority (Log2(NB_MASTER_PORT)) : is NB_MASTER_PORT=2 -> 1 bit, NB_MASTER_PORT = 4 -> 2 bits ... 
parameter NB_SLAVE_PORT = 2;

/////////////////////////////////////////////
// parameter to be left untouched by user
parameter CTRL_ADDR_WIDTH = (((NB_MASTER_PORT)>4096)? (((NB_MASTER_PORT)>262144)? (((NB_MASTER_PORT)>2097152)? (((NB_MASTER_PORT)>8388608)? 24 : (((NB_MASTER_PORT)> 4194304)? 23 : 22)) : (((NB_MASTER_PORT)>1048576)? 21 : (((NB_MASTER_PORT)>524288)? 20 : 19))) : (((NB_MASTER_PORT)>32768)? (((NB_MASTER_PORT)>131072)?  18 : (((NB_MASTER_PORT)>65536)? 17 : 16)) : (((NB_MASTER_PORT)>16384)? 15 : (((NB_MASTER_PORT)>8192)? 14 : 13)))) : (((NB_MASTER_PORT)>64)? (((NB_MASTER_PORT)>512)?  (((NB_MASTER_PORT)>2048)? 12 : (((NB_MASTER_PORT)>1024)? 11 : 10)) : (((NB_MASTER_PORT)>256)? 9 : (((NB_MASTER_PORT)>128)? 8 : 7))) : (((NB_MASTER_PORT)>8)? (((NB_MASTER_PORT)> 32)? 6 : (((NB_MASTER_PORT)>16)? 5 : 4)) : (((NB_MASTER_PORT)>4)? 3 : (((NB_MASTER_PORT)>2)? 2 : 1)))));

// config 
//input  [NB_MASTER_PORT-1:0] mx_sleep_req; // sleep mode was requseted for this master
input   round_robin; // if high round robin algo is used for arbitration algorithm
input[(NB_MASTER_PORT*PRIO_WIDTH) - 1 : 0] priority_level;
//output  [NB_MASTER_PORT-1:0] mx_sleep_ack; // sleep mode was acknowledge for this master

// clocks and resets
input resetn;
input hclk;

   // from/to master X (X ranging from O to NB_MASTER_PORT-1)
input [( NB_MASTER_PORT * NB_SLAVE_PORT ) - 1 : 0 ]   mx_hsel;
input [( NB_MASTER_PORT * ADDR_WIDTH ) - 1 : 0 ]   mx_haddr;
input [( NB_MASTER_PORT * 2 ) - 1 : 0 ]   mx_htrans;
input [( NB_MASTER_PORT * 3 ) - 1 : 0 ]   mx_hsize;
input [( NB_MASTER_PORT * 3 ) - 1 : 0 ]   mx_hburst;
input [( NB_MASTER_PORT * 1 ) - 1 : 0 ]   mx_hwrite;
input [( NB_MASTER_PORT * 32) - 1 : 0 ]   mx_hwdata;
input [( NB_MASTER_PORT * 1 ) - 1 : 0 ]   mx_hready_in; // WARNING, this signal MUST be a "AND" between all hready from other endpoint (except this one).
output[( NB_MASTER_PORT * 1 ) - 1 : 0 ]   mx_hready;
output[( NB_MASTER_PORT * 2 ) - 1 : 0 ]   mx_hresp;
output[( NB_MASTER_PORT * 32) - 1 : 0 ]   mx_hrdata;

   // from/to slave
output[NB_SLAVE_PORT-1:0]  hsel;
output[ADDR_WIDTH-1:0]   haddr;
output[1:0]    htrans;
output[2:0]    hsize;
output[2:0]    hburst;
output         hwrite;
output[31:0]   hwdata;
input          hready;
input [1:0]    hresp;
input [31:0]   hrdata;


//  master X control registered version (X ranging from O to NB_MASTER_PORT-1)
reg [( NB_MASTER_PORT * NB_SLAVE_PORT ) - 1 : 0 ]   mx_hsel_d;
reg [( NB_MASTER_PORT * ADDR_WIDTH ) - 1 : 0 ]   mx_haddr_d;
reg [( NB_MASTER_PORT * 2 ) - 1 : 0 ]    mx_htrans_d;
reg [( NB_MASTER_PORT * 3 ) - 1 : 0 ]    mx_hsize_d;
reg [( NB_MASTER_PORT * 3 ) - 1 : 0 ]    mx_hburst_d;
reg [( NB_MASTER_PORT * 1 ) - 1 : 0 ]    mx_hwrite_d;
wire[( NB_MASTER_PORT * 1 ) - 1 : 0 ]    mx_hready;
wire[( NB_MASTER_PORT * 2 ) - 1 : 0 ]    mx_hresp;


wire  [NB_MASTER_PORT  - 1 : 0 ]   mx_htrans0;

// slave control
wire[NB_SLAVE_PORT-1:0]  hsel;
wire[ADDR_WIDTH-1:0]   haddr;
wire[1:0]    htrans;
wire[2:0]    hsize;
wire[2:0]    hburst;
wire         hwrite;
wire[31:0]   hwdata;

wire [NB_MASTER_PORT -1 : 0 ] mx_sel;
wire [NB_MASTER_PORT -1 : 0 ] mx_data_sel;
wire [NB_MASTER_PORT -1 : 0 ] mx_reg_ctrl;      
wire [NB_MASTER_PORT -1 : 0 ] mx_ctrl_from_reg; 
wire [NB_MASTER_PORT -1 : 0 ] mx_ctrl_sel; 
wire [NB_MASTER_PORT -1 : 0 ] mx_resp_idle;
wire [NB_MASTER_PORT -1 : 0 ] mx_resp_from_slave;  
wire [NB_MASTER_PORT -1 : 0 ] mx_arb_grant;       







//////////////////////////////////
// 
//////////////////////////////////
assign mx_htrans0 = HTRANS0_ONLY(mx_htrans);

assign mx_sel = (MASTER_SEL(mx_hsel))&(HTRANS_NOT_IDLE(mx_htrans))&mx_hready_in; // sel if selected by adec and transfer is asked and transfer on previous slave is not waited

//////////////////////////////////
// Arbitration scheme
//////////////////////////////////


ml_ahb_arb_port_0 ml_ahb_arb_port_0_inst(
   .round_robin(round_robin),
   .priority_level(priority_level),
//   .mx_sleep_req(mx_sleep_req),
   .hclk(hclk),
   .resetn(resetn),
   .mx_sel(mx_sel),
   .mx_htrans0(mx_htrans0),
   .hready(hready),
   .mx_arb_grant(mx_arb_grant)
//   .mx_sleep_ack(mx_sleep_ack)
   );
      
//////////////////////////////////
// FSM for path management (port X)
//////////////////////////////////


ml_ahb_path_port_all  ml_ahb_path_port_all_inst [NB_MASTER_PORT - 1 : 0 ](
// surelint sees write-write race condition when connections are explicit
// Do implicit connections for surelint

//   resetn,   // plugged to resetn
//   hclk,     // plugged to hclk
//   hready,   // plugged to hready_in
//   mx_sel,   // plugged to sel
//   mx_arb_grant, // plugged to grant
//   mx_data_sel,  // plugged to data_sel
//   mx_reg_ctrl,  // plugged to reg_ctrl
//   mx_ctrl_from_reg,  // plugged to ctrl_from_reg
//   mx_ctrl_sel,       // plugged to ctrl_sel
//   mx_resp_idle,      // plugged to resp_idle
//   mx_resp_from_slave // plugged to resp_from_slave

// Do explicit connections for safety reason

   .resetn(resetn),
   .hclk(hclk),
   .hready_in(hready),
   .sel(mx_sel),
   .grant(mx_arb_grant),
   .data_sel(mx_data_sel),
   .reg_ctrl(mx_reg_ctrl),
   .ctrl_from_reg(mx_ctrl_from_reg),
   .ctrl_sel(mx_ctrl_sel),
   .resp_idle(mx_resp_idle),
   .resp_from_slave(mx_resp_from_slave)
   );


//////////////////////////////////
// control registration for port X
//////////////////////////////////
always @ (posedge hclk or negedge resetn) begin
   if (~resetn) begin
      mx_hsel_d   <={(NB_MASTER_PORT*NB_SLAVE_PORT){1'b0}};
      mx_haddr_d  <={(NB_MASTER_PORT*ADDR_WIDTH){1'b0}};
      mx_htrans_d <={(NB_MASTER_PORT*2){1'b0}};
      mx_hsize_d  <={(NB_MASTER_PORT*3){1'b0}};
      mx_hburst_d <={(NB_MASTER_PORT*3){1'b0}};
      mx_hwrite_d <={(NB_MASTER_PORT*1){1'b0}};
   end
   else begin
      mx_hsel_d   <= REG_HSEL  (mx_reg_ctrl,mx_hsel   ,mx_hsel_d);
      mx_haddr_d  <= REG_ADDR  (mx_reg_ctrl,mx_haddr  ,mx_haddr_d);
      mx_htrans_d <= REG_TRANS (mx_reg_ctrl,mx_htrans ,mx_htrans_d);
      mx_hsize_d  <= REG_SIZE  (mx_reg_ctrl,mx_hsize  ,mx_hsize_d);
      mx_hburst_d <= REG_BURST (mx_reg_ctrl,mx_hburst ,mx_hburst_d);
      mx_hwrite_d <= REG_WRITE (mx_reg_ctrl,mx_hwrite ,mx_hwrite_d);
   end
end  
      

//////////////////////////////////
// control signal to slave selection
//////////////////////////////////

//assign htrans   = HTRANS_TO_SLAVE(mx_ctrl_sel,mx_ctrl_from_reg,mx_htrans,mx_htrans_d);
//assign hsel     = HSEL_TO_SLAVE(mx_ctrl_sel,mx_ctrl_from_reg,mx_hsel,mx_hsel_d);
assign haddr    = HADDR_TO_SLAVE (mx_ctrl_sel,mx_ctrl_from_reg,mx_haddr,mx_haddr_d);
assign hsize    = HSIZE_TO_SLAVE (mx_ctrl_sel,mx_ctrl_from_reg,mx_hsize,mx_hsize_d);
assign hburst   = HBURST_TO_SLAVE(mx_ctrl_sel,mx_ctrl_from_reg,mx_hburst,mx_hburst_d);
assign hwrite   = HWRITE_TO_SLAVE(mx_ctrl_sel,mx_ctrl_from_reg,mx_hwrite,mx_hwrite_d);

assign htrans   = NEW_HTRANS_TO_SLAVE(mx_ctrl_sel,mx_ctrl_from_reg,mx_htrans,mx_htrans_d);
assign hsel     = NEW_HSEL_TO_SLAVE  (mx_ctrl_sel,mx_ctrl_from_reg,mx_hsel,mx_hsel_d);


//////////////////////////////////
// write data to slave
//////////////////////////////////
assign hwdata = HWDATA_TO_SLAVE(mx_data_sel,mx_hwdata);

//////////////////////////////////
// response and data to port X
//////////////////////////////////    

assign mx_hrdata = HRDATA_TO_MASTER(mx_data_sel,hrdata);
assign mx_hready = HREADY_TO_MASTER(mx_resp_from_slave,mx_resp_idle,hready);
assign mx_hresp  = HRESP_TO_MASTER (mx_resp_from_slave,hresp);


  

//////////////////////////////////////////////////////////////////////////////////
///////// FUNCTIONS             //////////////////////////////////////////////////

// HTRANS0_ONLY :
// takes only bit 0 of trans
function [NB_MASTER_PORT -1:0] HTRANS0_ONLY;
   input [(NB_MASTER_PORT * 2) -1 : 0] trans_in; // trans is on 2 bytes
   
   integer i;

   begin
      
      for (i=0; i< NB_MASTER_PORT ; i=i+1) begin
         HTRANS0_ONLY[i] = trans_in>>(2*i);     // right shift of 2 to take trans[0] from each master.
      end
      
   end
endfunction

// HTRANS_NOT_IDLE :
// return 1 if htrans is not IDLE
function [NB_MASTER_PORT -1:0] HTRANS_NOT_IDLE;
   input [(NB_MASTER_PORT * 2) -1 : 0] trans_in; // trans is on 2 bytes
   
   integer i;
   integer j;
   integer k;
   reg [1:0] trans_tmp;

   begin
      
      k=0;
      for (i=0; i< NB_MASTER_PORT ; i=i+1) begin
         for(j=0;j< 2 ; j=j+1) begin
            trans_tmp[j]=trans_in[k];  // get correct bit frm master i
            k=k+1;
         end
         HTRANS_NOT_IDLE[i]=(trans_tmp==`AHB_HTRANS_IDLE)?1'b0:1'b1; // return true if htrans is not IDLE
      end
      
   end
endfunction

// REG_ADDR :
// receives three arguments :
// 1st : which master should register new addr (selection)
// 2nd : current address
// 3rd : registered address
// return new address
function [(NB_MASTER_PORT * ADDR_WIDTH) -1 : 0 ] REG_ADDR;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [(NB_MASTER_PORT * ADDR_WIDTH) -1 : 0 ] cur_addr;
   input [(NB_MASTER_PORT * ADDR_WIDTH) -1 : 0 ] reg_addr;
   
   integer i,j,k;
   
   begin
   
   k=0;
   for(i=0; i < NB_MASTER_PORT; i = i+1) begin
      for(j=0; j < ADDR_WIDTH ; j = j+1) begin
         REG_ADDR[k] = (selection[i] == 1'b1)?cur_addr[k]:reg_addr[k]; // if selected take new address, else keep current address
         k=k+1;
      end
   end
end
endfunction

// REG_HSEL :
// receives three arguments :
// 1st : which master should register new hsel (selection)
// 2nd : current hsel
// 3rd : registered hsel
// return new hsel
function [(NB_MASTER_PORT * NB_SLAVE_PORT) -1 : 0 ] REG_HSEL;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [(NB_MASTER_PORT * NB_SLAVE_PORT) -1 : 0 ] cur_hsel;
   input [(NB_MASTER_PORT * NB_SLAVE_PORT) -1 : 0 ] reg_hsel;
   
   integer i,j,k;
   
   begin
   
   k=0;
   for(i=0; i < NB_MASTER_PORT; i = i+1) begin
      for(j=0; j < NB_SLAVE_PORT ; j = j+1) begin
         REG_HSEL[k] = (selection[i] == 1'b1)?cur_hsel[k]:reg_hsel[k]; // if selected take new hsel, else keep current hsel
         k=k+1;
      end
   end
end
endfunction

// REG_TRANS :
// receives three arguments :
// 1st : which master should register new htrans (selection)
// 2nd : current htrans
// 3rd : registered htrans
// return new trans
function [(NB_MASTER_PORT * 2) -1 : 0 ] REG_TRANS;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [(NB_MASTER_PORT * 2) -1 : 0 ] cur_trans;
   input [(NB_MASTER_PORT * 2) -1 : 0 ] reg_trans;
   
   integer i,j,k;
   
   begin
   
   k=0;
   for(i=0; i < NB_MASTER_PORT; i = i+1) begin
      for(j=0; j < 2 ; j = j+1) begin
         REG_TRANS[k] = (selection[i] == 1'b1)?cur_trans[k]:reg_trans[k]; // if selected take new trans, else keep current trans
         k=k+1;
      end
   end
end
endfunction

// REG_SIZE :
// receives three arguments :
// 1st : which master should register new hsize (selection)
// 2nd : current hsize
// 3rd : registered hsize
// return new size
function [(NB_MASTER_PORT * 3) -1 : 0 ] REG_SIZE;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [(NB_MASTER_PORT * 3) -1 : 0 ] cur_size;
   input [(NB_MASTER_PORT * 3) -1 : 0 ] reg_size;
   
   integer i,j,k;
   
   begin
   
   k=0;
   for(i=0; i < NB_MASTER_PORT; i = i+1) begin
      for(j=0; j < 3 ; j = j+1) begin
         REG_SIZE[k] = (selection[i] == 1'b1)?cur_size[k]:reg_size[k]; // if selected take new size, else keep current size
         k=k+1;
      end
   end
end
endfunction

// REG_BURST :
// receives three arguments :
// 1st : which master should register new hburst (selection)
// 2nd : current hburst
// 3rd : registered hburst
// return new burstess
function [(NB_MASTER_PORT * 3) -1 : 0 ] REG_BURST;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [(NB_MASTER_PORT * 3) -1 : 0 ] cur_burst;
   input [(NB_MASTER_PORT * 3) -1 : 0 ] reg_burst;
   
   integer i,j,k;
   
   begin
   
   k=0;
   for(i=0; i < NB_MASTER_PORT; i = i+1) begin
      for(j=0; j < 3 ; j = j+1) begin
         REG_BURST[k] = (selection[i] == 1'b1)?cur_burst[k]:reg_burst[k]; // if selected take new burst, else keep current burst
         k=k+1;
      end
   end
end
endfunction

// REG_WRITE :
// receives three arguments :
// 1st : which master should register new hwrite (selection)
// 2nd : current hwrite
// 3rd : registered hwrite
// return new writeess
function [(NB_MASTER_PORT * 1) -1 : 0 ] REG_WRITE;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [(NB_MASTER_PORT * 1) -1 : 0 ] cur_write;
   input [(NB_MASTER_PORT * 1) -1 : 0 ] reg_write;
   
   integer i,j,k;
   
   begin
   
   k=0;
   for(i=0; i < NB_MASTER_PORT; i = i+1) begin
      for(j=0; j < 1 ; j = j+1) begin
         REG_WRITE[k] = (selection[i] == 1'b1)?cur_write[k]:reg_write[k]; // if selected take new write, else keep current write
         k=k+1;
      end
   end
end
endfunction



// HSEL_TO_SLAVE :
// this function select correct hsel to be presented to slave.
// receives 4 args :
// 1st : selection, indicates which master should present hsel
// 2nd : registered, indicates if hsel comes from master IF or from registered version
// 3rd : hsel, from IF
// 4th : hsel_d, from register

function [(1 * NB_SLAVE_PORT) -1 : 0 ] HSEL_TO_SLAVE;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [NB_MASTER_PORT - 1 : 0] registered;
   input [(NB_MASTER_PORT * NB_SLAVE_PORT) - 1 : 0] sel_c;
   input [(NB_MASTER_PORT * NB_SLAVE_PORT) - 1 : 0] sel_d;
   
   integer i;
   
   begin
   
   HSEL_TO_SLAVE = {NB_SLAVE_PORT{1'b0}};
   for(i=0;i<NB_MASTER_PORT;i=i+1) begin
      if(selection[i]==1'b1) begin
         HSEL_TO_SLAVE = ((registered[i] == 1'b1)?sel_d:sel_c)>>(NB_SLAVE_PORT*i); // take only correct bit of register (or not) version of sel
      end
   end
   end
endfunction
 
function [(1 * NB_SLAVE_PORT) -1 : 0 ] NEW_HSEL_TO_SLAVE;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [NB_MASTER_PORT - 1 : 0] registered;
   input [(NB_MASTER_PORT * NB_SLAVE_PORT) - 1 : 0] sel_c;
   input [(NB_MASTER_PORT * NB_SLAVE_PORT) - 1 : 0] sel_d;
   reg [(NB_MASTER_PORT * NB_SLAVE_PORT) - 1 : 0] sel_tmp;
   
   integer i,j,k;
   
   
   begin
   
      
   NEW_HSEL_TO_SLAVE = {NB_SLAVE_PORT{1'b0}};
   k=0;
   for(i=0;i<NB_MASTER_PORT;i=i+1) begin
      for(j=0;j<NB_SLAVE_PORT;j=j+1) begin
         if (selection[i]==1'b1) begin
            if (registered[i] == 1'b1) begin
               NEW_HSEL_TO_SLAVE[j]= sel_d[k];
            end
            else begin 
               NEW_HSEL_TO_SLAVE[j]= sel_c[k];
            end
         end
         k=k+1;
      end
   end
   
   
   end
endfunction


 
 

 
// HTRANS_TO_SLAVE :
// this function select correct htrans to be presented to slave.
// receives 4 args :
// 1st : selection, indicates which master should present htrans
// 2nd : registered, indicates if htrans comes from master IF or from registered version
// 3rd : htrans, from IF
// 4th : htrans_d, from register
function [(1 * 2) -1 : 0 ] HTRANS_TO_SLAVE;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [NB_MASTER_PORT - 1 : 0] registered;
   input [(NB_MASTER_PORT * 2) - 1 : 0] trans;
   input [(NB_MASTER_PORT * 2) - 1 : 0] trans_d;
   
   integer i;
   
   begin
   
   HTRANS_TO_SLAVE = 2'b0;
   for(i=0;i<NB_MASTER_PORT;i=i+1) begin
      if(selection[i]==1'b1) begin
         HTRANS_TO_SLAVE = ((registered[i] == 1'b1)?trans_d:trans)>>(2*i); // take only correct bit of register (or not) version of trans
      end
   end
   end
endfunction

   

function [(1 * 2) -1 : 0 ] NEW_HTRANS_TO_SLAVE;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [NB_MASTER_PORT - 1 : 0] registered;
   input [(NB_MASTER_PORT * 2) - 1 : 0] trans;
   input [(NB_MASTER_PORT * 2) - 1 : 0] trans_d;
         
   integer i,j,k;
   
   begin
      
   NEW_HTRANS_TO_SLAVE = {2{1'b0}};
   k=0;
   for(i=0;i<NB_MASTER_PORT;i=i+1) begin
      for(j=0;j<2;j=j+1) begin
         if (selection[i]==1'b1) begin
            if (registered[i] == 1'b1) begin
               NEW_HTRANS_TO_SLAVE[j]= trans_d[k];
            end
            else begin 
               NEW_HTRANS_TO_SLAVE[j]= trans[k];
            end
         end
         k=k+1;
      end
   end
   
   end
endfunction
   
  




// HADDR_TO_SLAVE :
// this function select correct haddr to be presented to slave.
// receives 4 args :
// 1st : selection, indicates which master should present haddr
// 2nd : registered, indicates if haddr comes from master IF or from registered version
// 3rd : haddr, from IF
// 4th : haddr_d, from register
function [(1 * ADDR_WIDTH) -1 : 0 ] HADDR_TO_SLAVE;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [NB_MASTER_PORT - 1 : 0] registered;
   input [(NB_MASTER_PORT * ADDR_WIDTH) - 1 : 0] addr;
   input [(NB_MASTER_PORT * ADDR_WIDTH) - 1 : 0] addr_d;
   
   integer i,j,k;
   
   begin
      
   HADDR_TO_SLAVE = {ADDR_WIDTH{1'b0}};
   k=0;
   for(i=0;i<NB_MASTER_PORT;i=i+1) begin
      for(j=0;j<ADDR_WIDTH;j=j+1) begin
         if (selection[i]==1'b1) begin
            if (registered[i] == 1'b1) begin
               HADDR_TO_SLAVE[j]= addr_d[k];
            end
            else begin 
               HADDR_TO_SLAVE[j]= addr[k];
            end
         end
         k=k+1;
      end
   end
   end
endfunction

function [(1 * ADDR_WIDTH) -1 : 0 ] NEW_HADDR_TO_SLAVE;
   input [CTRL_ADDR_WIDTH - 1 : 0] selection;
   input [NB_MASTER_PORT - 1 : 0] registered;
   input [(NB_MASTER_PORT * ADDR_WIDTH) - 1 : 0] addr;
   input [(NB_MASTER_PORT * ADDR_WIDTH) - 1 : 0] addr_d;
   
   
   begin
   
      NEW_HADDR_TO_SLAVE = ((registered[selection] == 1'b1)?addr_d:addr)>>(ADDR_WIDTH*selection); // take only correct bit of register (or not) version of trans
   
   end
endfunction




   
// HSIZE_TO_SLAVE :
// this function select correct hsize to be presented to slave.
// receives 4 args :
// 1st : selection, indicates which master should present hsize
// 2nd : registered, indicates if hsize comes from master IF or from registered version
// 3rd : hsize, from IF
// 4th : hsize_d, from register
function [(1 * 3) -1 : 0 ] HSIZE_TO_SLAVE;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [NB_MASTER_PORT - 1 : 0] registered;
   input [(NB_MASTER_PORT * 3) - 1 : 0] size;
   input [(NB_MASTER_PORT * 3) - 1 : 0] size_d;
   
   integer i,j,k;
   
   begin
   
   HSIZE_TO_SLAVE = 3'b0;
   k=0;
   for(i=0;i<NB_MASTER_PORT;i=i+1) begin
      for(j=0;j<3;j=j+1) begin
         if(selection[i]==1'b1) begin
            if (registered[i] == 1'b1) begin
               HSIZE_TO_SLAVE[j]= size_d[k];
            end
            else begin 
               HSIZE_TO_SLAVE[j]= size[k];
            end
         end
         k=k+1;
      end
   end
   end
endfunction

function [(1 * 3) -1 : 0 ] NEW_HSIZE_TO_SLAVE;
   input [CTRL_ADDR_WIDTH - 1 : 0] selection;
   input [NB_MASTER_PORT - 1 : 0] registered;
   input [(NB_MASTER_PORT * 3) - 1 : 0] size;
   input [(NB_MASTER_PORT * 3) - 1 : 0] size_d;
   
   
   begin
   
      NEW_HSIZE_TO_SLAVE = ((registered[selection] == 1'b1)?size_d:size)>>(3*selection); // take only correct bit of register (or not) version of trans

   end
endfunction
   




// HBURST_TO_SLAVE :
// this function select correct hburst to be presented to slave.
// receives 4 args :
// 1st : selection, indicates which master should present hburst
// 2nd : registered, indicates if hburst comes from master IF or from registered version
// 3rd : hburst, from IF
// 4th : hburst_d, from register
function [(1 * 3) -1 : 0 ] HBURST_TO_SLAVE;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [NB_MASTER_PORT - 1 : 0] registered;
   input [(NB_MASTER_PORT * 3) - 1 : 0] burst;
   input [(NB_MASTER_PORT * 3) - 1 : 0] burst_d;
   
   integer i,j,k;
   
   begin
   
   HBURST_TO_SLAVE = 3'b0;
   k=0;
   for(i=0;i<NB_MASTER_PORT;i=i+1) begin
      for(j=0;j<3;j=j+1) begin
         if(selection[i]==1'b1) begin
            if (registered[i] == 1'b1) begin
               HBURST_TO_SLAVE[j]= burst_d[k];
            end
            else begin 
               HBURST_TO_SLAVE[j]= burst[k];
            end
         end
         k=k+1;
      end
   end
   end
endfunction

function [(1 * 3) -1 : 0 ] NEW_HBURST_TO_SLAVE;
   input [CTRL_ADDR_WIDTH - 1 : 0] selection;
   input [NB_MASTER_PORT - 1 : 0] registered;
   input [(NB_MASTER_PORT * 3) - 1 : 0] burst;
   input [(NB_MASTER_PORT * 3) - 1 : 0] burst_d;
   
   
   begin
   
      NEW_HBURST_TO_SLAVE = ((registered[selection] == 1'b1)?burst_d:burst)>>(3*selection); // take only correct bit of register (or not) version of trans

   end
endfunction
   




// HWRITE_TO_SLAVE :
// this function select correct hwrite to be presented to slave.
// receives 4 args :
// 1st : selection, indicates which master should present hwrite
// 2nd : registered, indicates if hwrite comes from master IF or from registered version
// 3rd : hwrite, from IF
// 4th : hwrite_d, from register
function [(1 * 1) -1 : 0 ] HWRITE_TO_SLAVE;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [NB_MASTER_PORT - 1 : 0] registered;
   input [(NB_MASTER_PORT * 1) - 1 : 0] write;
   input [(NB_MASTER_PORT * 1) - 1 : 0] write_d;
   
   integer i,j,k;
   
   begin
   
   HWRITE_TO_SLAVE = 1'b0;
   k=0;
   for(i=0;i<NB_MASTER_PORT;i=i+1) begin
      for(j=0;j<1;j=j+1) begin
         if(selection[i]==1'b1) begin
            if (registered[i] == 1'b1) begin
               HWRITE_TO_SLAVE[j]= write_d[k];
            end
            else begin 
               HWRITE_TO_SLAVE[j]= write[k];
            end
         end
         k=k+1;
      end
   end
   end
endfunction

function [(1 * 1) -1 : 0 ] NEW_HWRITE_TO_SLAVE;
   input [CTRL_ADDR_WIDTH - 1 : 0] selection;
   input [NB_MASTER_PORT - 1 : 0] registered;
   input [(NB_MASTER_PORT * 1) - 1 : 0] write;
   input [(NB_MASTER_PORT * 1) - 1 : 0] write_d;
   
   
   begin
   
      NEW_HWRITE_TO_SLAVE = ((registered[selection] == 1'b1)?write_d:write)>>(1*selection); // take only correct bit of register (or not) version of trans

   end
endfunction




// HWDATA_TO_SLAVE :
// this function select correct write data to be presented to slave.
// receives 2 args :
// 1st : selection, indicates which master should present hwrite
// 2nd : write data from masters
function [(1 * 32) -1 : 0 ] HWDATA_TO_SLAVE;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [(NB_MASTER_PORT * 32) - 1 : 0] wdata;
   
   integer i,j,k;
   
   begin
   
   HWDATA_TO_SLAVE = 32'b0;
   k=0;
   for(i=0;i<NB_MASTER_PORT;i=i+1) begin
      for(j=0;j<32;j=j+1) begin
         if(selection[i]==1'b1) begin
            HWDATA_TO_SLAVE[j]= wdata[k];
         end
         k=k+1;
      end
   end
   end
endfunction


// HRDATA_TO_MASTER :
// this function select correct write data to be presented to slave.
// receives 2 args :
// 1st : selection, indicates which master should present hwrite
// 2nd : read data from slave
function [(NB_MASTER_PORT * 32) -1 : 0 ] HRDATA_TO_MASTER;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [(1 * 32) - 1 : 0] rdata;
   
   integer i,j,k;
   
   begin
   
   HRDATA_TO_MASTER = {(NB_MASTER_PORT*32){1'b0}};
   k=0;
   for(i=0;i<NB_MASTER_PORT;i=i+1) begin
      for(j=0;j<32;j=j+1) begin
         if(selection[i]==1'b1) begin
            HRDATA_TO_MASTER[k] = rdata[j]; // take only correct bit of read data
         end
         else begin
            HRDATA_TO_MASTER[k] = 1'b0; // if not in data phase 0's must be returned.
         end
         k=k+1;
      end
   end
   end
endfunction


// HRESP_TO_MASTER :
// this function select correct write data to be presented to slave.
// receives 2 args :
// 1st : selection,
// 2nd : resp from slave
function [(NB_MASTER_PORT * 2) -1 : 0 ] HRESP_TO_MASTER;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [(1 * 2) - 1 : 0] resp;
   
   integer i,j,k;
   
   begin
   
   HRESP_TO_MASTER = {(NB_MASTER_PORT*2){1'b0}};
   k=0;
   for(i=0;i<NB_MASTER_PORT;i=i+1) begin
      for(j=0;j<2;j=j+1) begin
         if(selection[i]==1'b1) begin
            HRESP_TO_MASTER[k] = resp[j]; // take only correct bit of resp from slave
         end
         else begin
            HRESP_TO_MASTER[k] = 1'b0; // OKAY response
         end
         k=k+1;
      end
   end
   end
endfunction


// HREADY_TO_MASTER :
// this function select correct write data to be presented to slave.
// receives 2 args :
// 1st : selection,
// 2nd : idle,
// 3rd : ready from slave
function [(NB_MASTER_PORT * 1) -1 : 0 ] HREADY_TO_MASTER;
   input [NB_MASTER_PORT - 1 : 0] selection;
   input [NB_MASTER_PORT - 1 : 0] idle;
   input [(1 * 1) - 1 : 0] ready;
   
   integer i,j,k;
   
   begin
   
   HREADY_TO_MASTER = {(NB_MASTER_PORT*1){1'b0}};
   k=0;
   for(i=0;i<NB_MASTER_PORT;i=i+1) begin
      for(j=0;j<1;j=j+1) begin
         if(selection[i]==1'b1) begin
            HREADY_TO_MASTER[k] = ready[j]; // take only correct bit of ready from slave
         end
         else begin
            if(idle[i] == 1'b1) begin
               HREADY_TO_MASTER[k] = 1'b1; // must be ready
            end
            else begin
               HREADY_TO_MASTER[k] = 1'b0; // must wait
            end
         end
         k=k+1;
      end
   end
   end
endfunction

//MASTER_SEL :
// master can address more than one slave (multiple hsel for one slave).
// This function is used to combine multiple hsel to single one
function [( NB_MASTER_PORT ) - 1 : 0 ] MASTER_SEL;
   input [( NB_MASTER_PORT * NB_SLAVE_PORT ) - 1 : 0 ]   msel;
   
   integer i;
   reg [NB_SLAVE_PORT - 1:0] master_sel_tmp;
   
   begin
   
   
   for(i=0;i<NB_MASTER_PORT;i=i+1) begin
      master_sel_tmp= msel >> (i*NB_SLAVE_PORT);
      MASTER_SEL[i]=|master_sel_tmp;
   end
   
   end
   
endfunction
   

endmodule

