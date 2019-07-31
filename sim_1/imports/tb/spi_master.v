`timescale 1ns/1ns

module spi_master(/*AUTOARG*/
   // Outputs
   ss_n, mosi, sck, tx_data_ready, rx_data, rx_data_valid,
   // Inputs
   reset_n, clk, miso, tx_data, tx_data_valid, rx_data_ready, opcode
   );

   input			reset_n;
   input			clk;

   output       ss_n;
   input       miso;
   output      mosi;
   output      sck;

   input [7:0] tx_data;
   input       tx_data_valid;
   output      tx_data_ready;

   output [7:0] rx_data;
   output       rx_data_valid;
   input        rx_data_ready;

   input [7:0]  opcode;

   reg          ss_n;
   reg          sck;
   reg [2:0]    sck_idx;
   reg [7:0]    miso_shift;
   reg [7:0]    mosi_shift;

   reg [7:0]    tx_data_f;
   reg          data_exist;


   localparam SCK_DELAY = 100;

   localparam ST_IDLE   =	2'd0;
   localparam ST_OPCODE	= 2'd1;
   localparam ST_WRITE  = 2'd2;
   localparam ST_READ   =	2'd3;

   localparam OP_WRITE		=	8'h80;			// Host Read
   localparam OP_READ		=	8'h00;			// Host Write 

   reg [1:0]    state;
   reg [1:0]    nstate;

   //synopsys translate_off
   reg [30*8:1] state_str;
   always @(state)
     begin
	      case (state)
		      ST_IDLE			: state_str = "ST_IDLE";
		      ST_OPCODE			: state_str = "ST_OPCODE";
		      ST_WRITE			: state_str = "ST_WRITE";
		      ST_READ			: state_str = "ST_READ";
		      default				: state_str = "default";
	      endcase
     end
   //synopsys translate_on


   always @( * ) begin
      nstate = state;
	    case (state)
		    ST_IDLE :  begin
			     if(tx_data_ready)
				     nstate = ST_OPCODE;
			  end
	      ST_OPCODE :  begin
			     if(sck_idx == 7) begin
				      if(opcode == OP_WRITE)
					      nstate = ST_WRITE;
				      else
					      nstate = ST_READ;
			     end
		    end
		    ST_WRITE :  begin
			     if(sck_idx == 0 && !data_exist && !sck)
				     nstate = ST_IDLE;
		    end

		    ST_READ :  begin
			     if(sck_idx == 0 && !data_exist)
				     nstate = ST_IDLE;
		    end
	    endcase
   end

   always @(negedge reset_n or posedge clk) begin
	      if (!reset_n)
		      state <= ST_IDLE;
	      else
		      state <= #1 nstate;
     end

   always @(negedge reset_n or posedge clk) begin
      if(!reset_n) begin
         sck <= 0;
      end else begin
         #(SCK_DELAY/2) sck <= ~sck;
      end
   end

   always @ (negedge reset_n or negedge  sck) begin
      if(!reset_n)
        ss_n <= 1;
      else
        if(state == ST_IDLE)
          #1 ss_n <= 1;
        else
          #1 ss_n <= 0;
   end

   always @(negedge reset_n or posedge sck)
     begin
	      if (!reset_n )
		      sck_idx <= #1 0;
	      else begin
		       if(state == ST_IDLE)
			       sck_idx <= #1 0;
           else
			       sck_idx <= #1 sck_idx + 1;
	      end
     end

     always @(negedge reset_n or posedge sck)
     begin
	      if (!reset_n )
		      miso_shift <= #1 0;
	      else
			    miso_shift <= #1 {miso_shift[6:0], miso};
     end

   always @(negedge reset_n or posedge sck)
     begin
	      if (!reset_n )
		      mosi_shift <= #1 0;
	      else
          if(state == ST_OPCODE && sck_idx == 0)
            mosi_shift <= #1 opcode;
          else if(state == ST_WRITE && sck_idx == 0) begin
             mosi_shift <= #1 tx_data_f;
          end else
			      mosi_shift <= #1 {mosi_shift[6:0], 1'b0};
     end

   assign mosi = mosi_shift[7];


   assign tx_data_ready = tx_data_valid && ((state == ST_IDLE && sck_idx == 0) 
                                            || (state == ST_WRITE && sck_idx == 0) 
                                            || (state == ST_READ && sck_idx == 0));
   always @(negedge reset_n or posedge sck or posedge tx_data_ready) begin
	    if (!reset_n )
        data_exist <= 0;
      else
        if(tx_data_ready) begin
           data_exist <= 1;
           tx_data_f <= tx_data;
        end else if((state == ST_WRITE || state == ST_READ) && sck_idx == 0)
          data_exist <= 0;
   end

   assign rx_data_valid = state == ST_READ && sck_idx == 0;
   assign #1 rx_data = miso_shift;
   
endmodule
