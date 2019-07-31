
module ml_ahb(

   //config
   mapped_to_common,
   s0_round_robin,
   m0_s0_prio,
   m1_s0_prio,
   s1_round_robin,
   m0_s1_prio,
   m1_s1_prio,
   // from/to master 0
   m0_haddr,
   m0_htrans,
   m0_hsize,
   m0_hburst,
   m0_hwrite,
   m0_hwdata,
   m0_hready,
   m0_hresp,
   m0_hrdata,

   // from/to master 1
   m1_haddr,
   m1_htrans,
   m1_hsize,
   m1_hburst,
   m1_hwrite,
   m1_hwdata,
   m1_hready,
   m1_hresp,
   m1_hrdata,

   // from/to port 0
   s0_hsel,
   s0_hsel_default,   
   s0_haddr,
   s0_htrans,
   s0_hsize,
   s0_hburst,
   s0_hwrite,
   s0_hwdata,
   s0_hready,
   s0_hresp,
   s0_hrdata,

   // from/to port 1
   s1_hsel,   
   s1_haddr,
   s1_htrans,
   s1_hsize,
   s1_hburst,
   s1_hwrite,
   s1_hwdata,
   s1_hready,
   s1_hresp,
   s1_hrdata,

   // clocks and reset
   resetn,
   hclk);

`define ML_AHB_PATH_FSM_STATE_WIDTH  8   


//config
input [0:0] mapped_to_common;
input s0_round_robin;
input [0:0] m0_s0_prio;
input [0:0] m1_s0_prio;
input s1_round_robin;
input [0:0] m0_s1_prio;
input [0:0] m1_s1_prio;
// from/to master 0
input [31:0] m0_haddr;
input [1:0]  m0_htrans;
input [2:0]  m0_hsize;
input [2:0]  m0_hburst;
input        m0_hwrite;
input [31:0] m0_hwdata;
output       m0_hready;
output[1:0]  m0_hresp;
output[31:0] m0_hrdata;

// from/to master 1
input [31:0] m1_haddr;
input [1:0]  m1_htrans;
input [2:0]  m1_hsize;
input [2:0]  m1_hburst;
input        m1_hwrite;
input [31:0] m1_hwdata;
output       m1_hready;
output[1:0]  m1_hresp;
output[31:0] m1_hrdata;

// from/to port 0
output  s0_hsel;
output s0_hsel_default;        
output [31:0] s0_haddr;
output[1:0]    s0_htrans;
output[2:0]    s0_hsize;
output[2:0]    s0_hburst;
output         s0_hwrite;
output[31:0]   s0_hwdata;
input          s0_hready;
input [1:0]    s0_hresp;
input [31:0]   s0_hrdata;

// from/to port 1
output  s1_hsel;        
output [31:0] s1_haddr;
output[1:0]    s1_htrans;
output[2:0]    s1_hsize;
output[2:0]    s1_hburst;
output         s1_hwrite;
output[31:0]   s1_hwdata;
input          s1_hready;
input [1:0]    s1_hresp;
input [31:0]   s1_hrdata;

// clocks and reset
input resetn;
input hclk;//port 0 is connected to masters 0 1
wire  m0_s0_hsel;
wire [31:0] m0_s0_hrdata;
wire [1:0]  m0_s0_hresp;
wire        m0_s0_hready;
wire        m0_except_s0_hready;

wire  m1_s0_hsel;
wire [31:0] m1_s0_hrdata;
wire [1:0]  m1_s0_hresp;
wire        m1_s0_hready;
wire        m1_except_s0_hready;
//port 1 is connected to masters 0 1
wire  m0_s1_hsel;
wire [31:0] m0_s1_hrdata;
wire [1:0]  m0_s1_hresp;
wire        m0_s1_hready;
wire        m0_except_s1_hready;

wire  m1_s1_hsel;
wire [31:0] m1_s1_hrdata;
wire [1:0]  m1_s1_hresp;
wire        m1_s1_hready;
wire        m1_except_s1_hready;

/////////////////////////////////////////////////////////////////////////////////////////////////
////////////////// ENDPOINT INSTANTIATION ///////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
//port 0 is connected to masters 0 1

ml_ahb_port_0 ml_ahb_port_0(
// clocks and resets
   .resetn(resetn),
   .hclk(hclk),
// config
   .round_robin(s0_round_robin),
   .priority_level({m1_s0_prio ,m0_s0_prio }),
// from/to master X 
   .mx_htrans({m1_htrans ,m0_htrans }),
   .mx_hsize({m1_hsize ,m0_hsize }),
   .mx_hburst({m1_hburst ,m0_hburst }),
   .mx_hwrite({m1_hwrite ,m0_hwrite }),
   .mx_hwdata({m1_hwdata ,m0_hwdata }),
   .mx_hsel({{m1_hsel_default , m1_s0_hsel} ,{m0_hsel_default , m0_s0_hsel} }),
   .mx_hready({m1_s0_hready ,m0_s0_hready }),
   .mx_hresp({m1_s0_hresp ,m0_s0_hresp }),
   .mx_hrdata({m1_s0_hrdata ,m0_s0_hrdata }),
   .mx_hready_in({m1_except_s0_hready ,m0_except_s0_hready }),
   .mx_haddr({m1_haddr[31:0] ,m0_haddr[31:0] }),
// from/to slave
   .htrans(s0_htrans),
   .hsize(s0_hsize),
   .hburst(s0_hburst),
   .hwrite(s0_hwrite),
   .hwdata(s0_hwdata),
   .hready(s0_hready),
   .hresp(s0_hresp),
   .hrdata(s0_hrdata),
   .hsel({s0_hsel_default, s0_hsel}),
   .haddr(s0_haddr));


//port 1 is connected to masters 0 1

ml_ahb_port_1 ml_ahb_port_1(
// clocks and resets
   .resetn(resetn),
   .hclk(hclk),
// config
   .round_robin(s1_round_robin),
   .priority_level({m1_s1_prio ,m0_s1_prio }),
// from/to master X 
   .mx_htrans({m1_htrans ,m0_htrans }),
   .mx_hsize({m1_hsize ,m0_hsize }),
   .mx_hburst({m1_hburst ,m0_hburst }),
   .mx_hwrite({m1_hwrite ,m0_hwrite }),
   .mx_hwdata({m1_hwdata ,m0_hwdata }),
   .mx_hsel({m1_s1_hsel ,m0_s1_hsel }),
   .mx_hready({m1_s1_hready ,m0_s1_hready }),
   .mx_hresp({m1_s1_hresp ,m0_s1_hresp }),
   .mx_hrdata({m1_s1_hrdata ,m0_s1_hrdata }),
   .mx_hready_in({m1_except_s1_hready ,m0_except_s1_hready }),
   .mx_haddr({m1_haddr[31:0] ,m0_haddr[31:0] }),
// from/to slave
   .htrans(s1_htrans),
   .hsize(s1_hsize),
   .hburst(s1_hburst),
   .hwrite(s1_hwrite),
   .hwdata(s1_hwdata),
   .hready(s1_hready),
   .hresp(s1_hresp),
   .hrdata(s1_hrdata),
   .hsel(s1_hsel),
   .haddr(s1_haddr));



/////////////////////////////////////////////////////////////////////////////////////////////////
////////////////// ADDRESS DECODERS INSTANTIATION ///////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

//master 0 is connected to port 0 1 (slave 0 1)
ml_ahb_decoder_master_0 ml_ahb_decoder_master_0(
   .haddr31_downto_16 ( m0_haddr[31:16] ),
   .mapped_to_common(mapped_to_common),
   .hsel_default(m0_hsel_default),
   .hsel({
       m0_s1_hsel ,
       m0_s0_hsel 
   }));

//master 1 is connected to port 0 1 (slave 0 1)
ml_ahb_decoder_master_1 ml_ahb_decoder_master_1(
   .haddr31_downto_16 ( m1_haddr[31:16] ),
   .mapped_to_common(mapped_to_common),
   .hsel_default(m1_hsel_default),
   .hsel({
       m1_s1_hsel ,
       m1_s0_hsel 
   }));

/////////////////////////////////////////////////////////////////////////////////////////////////
////////////////// TRANSFER PATH                /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

//master 0 is connected to port 0 1
assign m0_except_s1_hready = 1'b1 & m0_s0_hready ;
assign m0_except_s0_hready = m0_s1_hready & 1'b1 ;
//master 1 is connected to port 0 1
assign m1_except_s1_hready = 1'b1 & m1_s0_hready ;
assign m1_except_s0_hready = m1_s1_hready & 1'b1 ;

/////////////////////////////////////////////////////////////////////////////////////////////////
////////////////// RETURN PATH                  /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

//master 0 is connected to port 0 1
assign m0_hready =  m0_s1_hready & m0_s0_hready ;
assign m0_hrdata =  m0_s1_hrdata | m0_s0_hrdata ;
assign m0_hresp =  m0_s1_hresp | m0_s0_hresp ;

//master 1 is connected to port 0 1
assign m1_hready =  m1_s1_hready & m1_s0_hready ;
assign m1_hrdata =  m1_s1_hrdata | m1_s0_hrdata ;
assign m1_hresp =  m1_s1_hresp | m1_s0_hresp ;


endmodule 
