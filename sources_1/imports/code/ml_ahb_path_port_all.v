
/////////////////////////////////////////////////////////////////////////////
/////////// PATH selection state machine
/////////////////////////////////////////////////////////////////////////////

module ml_ahb_path_port_all(

   resetn,
   hclk,
   hready_in,
   sel,
   grant,
   data_sel,
   reg_ctrl,
   ctrl_from_reg,
   ctrl_sel,
   resp_idle,
   resp_from_slave
   );
`define ML_AHB_PATH_FSM_STATE_WIDTH  8

input    resetn;
input    hclk;
input    hready_in;
input    sel;
input    grant;

output   data_sel;
output   reg_ctrl;
output   ctrl_from_reg;
output   ctrl_sel;
output   resp_idle;
output   resp_from_slave;


//////////////////////////////////
// define state of state machine
//////////////////////////////////
// warning : states are coded wisely 
parameter IDLE                   =  `ML_AHB_PATH_FSM_STATE_WIDTH'b00_000001;
parameter ACCESS                 =  `ML_AHB_PATH_FSM_STATE_WIDTH'b00_001111;
parameter DENY                   =  `ML_AHB_PATH_FSM_STATE_WIDTH'b00_100000;
parameter DENY_W                 =  `ML_AHB_PATH_FSM_STATE_WIDTH'b00_000000;
parameter ACCESS_W               =  `ML_AHB_PATH_FSM_STATE_WIDTH'b01_001111;
parameter ACCESS_LAST_W          =  `ML_AHB_PATH_FSM_STATE_WIDTH'b00_000111;
parameter ACCESS_AFTER_DENY      =  `ML_AHB_PATH_FSM_STATE_WIDTH'b00_011111;
parameter ACCESS_AFTER_DENY_W    =  `ML_AHB_PATH_FSM_STATE_WIDTH'b10_001111;


reg   [`ML_AHB_PATH_FSM_STATE_WIDTH-1:0]    state;
reg   [`ML_AHB_PATH_FSM_STATE_WIDTH-1:0]    state_next;

// synopsys translate_off
reg [(40*8):0] state_next_str;
reg [(40*8):0] state_str;

always @ (state) begin
   case(state) 
      IDLE : state_str = "IDLE";
      ACCESS : state_str = "ACCESS";
      DENY : state_str = "DENY";
      DENY_W : state_str = "DENY_W";
      ACCESS_W : state_str = "ACCESS_W";
      ACCESS_LAST_W : state_str = "ACCESS_LAST_W";
      ACCESS_AFTER_DENY : state_str = "ACCESS_AFTER_DENY";
      ACCESS_AFTER_DENY_W : state_str = "ACCESS_AFTER_DENY_W";
   endcase
end

always @ (state_next) begin
   case(state_next) 
      IDLE : state_next_str = "IDLE";
      ACCESS : state_next_str = "ACCESS";
      DENY : state_next_str = "DENY";
      DENY_W : state_next_str = "DENY_W";
      ACCESS_W : state_next_str = "ACCESS_W";
      ACCESS_LAST_W : state_next_str = "ACCESS_LAST_W";
      ACCESS_AFTER_DENY : state_next_str = "ACCESS_AFTER_DENY";
      ACCESS_AFTER_DENY_W : state_next_str = "ACCESS_AFTER_DENY_W";
   endcase
end
// synopsys translate_on


/////////////////////////////////////////////////////////////
//         FSM sequential part                             //
/////////////////////////////////////////////////////////////

always @(posedge hclk or negedge resetn) begin
   if (~resetn) begin
      state <= IDLE;
   end
   else begin
      state <= state_next;
   end
end


/////////////////////////////////////////////////////////////
//         FSM combinatorial part                          //
/////////////////////////////////////////////////////////////

always @(state or sel  or hready_in or grant) begin
   case (state)
      IDLE : begin
         if (sel == 1'b1 ) begin          // access asked
            if(grant == 1'b0) begin       // but resource not granted
               state_next = DENY;
            end
            else begin
               if( hready_in == 1'b0 ) begin
                  state_next = DENY;
               end
               else begin                    // and resource granted 
                  state_next = ACCESS;  // and resource ready
               end
            end
         end 
         else begin                      // no access asked
            state_next = IDLE;
         end
      end
      
      DENY : begin        
         if(grant == 1'b0 || hready_in == 1'b0 ) begin       // resource not granted or not ready
            state_next = DENY_W;
         end 
         else begin                    // and resource granted 
            state_next = ACCESS_AFTER_DENY;
         end
      end

      DENY_W : begin         //// same transition as DENY
         if(grant == 1'b0 || hready_in == 1'b0 ) begin       // resource not granted or not ready
            state_next = DENY_W;
         end 
         else begin                    // and resource granted 
            state_next = ACCESS_AFTER_DENY;
         end
      end
        
      ACCESS_AFTER_DENY : begin
         if ( hready_in == 1'b0) begin
            state_next = ACCESS_AFTER_DENY_W;
         end
         else begin
            if (sel == 1'b1) begin
               if (grant == 1'b0) begin
                  state_next = DENY;
               end
               else begin
                  state_next = ACCESS;
               end
            end
            else begin
               state_next = IDLE;
            end
         end
      end
         
      ACCESS_AFTER_DENY_W : begin //// same transition as ACCESS_AFTER_DENY
         if ( hready_in == 1'b0) begin
            state_next = ACCESS_AFTER_DENY_W;
         end
         else begin
            if (sel == 1'b1) begin
               if (grant == 1'b0) begin
                  state_next = DENY;
               end
               else begin
                  state_next = ACCESS;
               end
            end
            else begin
               state_next = IDLE;
            end
         end
      end
         
      
      ACCESS : begin 
         if (sel == 1'b1 ) begin          // access asked
            if (hready_in == 1'b0) begin
               state_next = ACCESS_W;
            end
            else begin
               if (grant == 1'b0) begin
                  state_next = DENY;
               end 
               else begin
                  state_next = ACCESS;
               end
            end
         end
         else begin
            if (hready_in == 1'b0) begin
               state_next = ACCESS_LAST_W;
            end
            else begin
               state_next = IDLE;
            end
         end
      end
      
      ACCESS_W :  begin //// same transition as ACCESS
         if (sel == 1'b1 ) begin          // access asked
            if (hready_in == 1'b0) begin
               state_next = ACCESS_W;
            end
            else begin
               if (grant == 1'b0) begin
                  state_next = DENY;
               end 
               else begin
                  state_next = ACCESS;
               end
            end
         end
         else begin
            if (hready_in == 1'b0) begin
               state_next = ACCESS_LAST_W;
            end
            else begin
               state_next = IDLE;
            end
         end
      end
       
      ACCESS_LAST_W : begin //// same transition as ACCESS
         if (sel == 1'b1 ) begin          // access asked
            if (hready_in == 1'b0) begin
               state_next = ACCESS_W;
            end
            else begin
               if (grant == 1'b0) begin
                  state_next = DENY;
               end 
               else begin
                  state_next = ACCESS;
               end
            end
         end
         else begin
            if (hready_in == 1'b0) begin
               state_next = ACCESS_LAST_W;
            end
            else begin
               state_next = IDLE;
            end
         end
      end
            
        
      default : begin
         state_next = IDLE;
      end

   endcase
end


/////////////////////////////////////////////////////////////
//         output assignment                               //
/////////////////////////////////////////////////////////////
//assign   reg_ctrl = (state_next==DENY)?1'b1:1'b0;
assign reg_ctrl = state_next[5];

//assign   ctrl_from_reg = (state_next==ACCESS_AFTER_DENY)?1'b1:1'b0;
assign ctrl_from_reg = state_next[4];

//assign   ctrl_sel          = (state_next ==ACCESS ||state_next ==ACCESS_W ||state_next ==ACCESS_AFTER_DENY ||state_next==ACCESS_AFTER_DENY_W)?1'b1:1'b0;
assign ctrl_sel = state_next[3];


//assign   resp_from_slave   = (state      ==ACCESS ||state      ==ACCESS_W ||state      ==ACCESS_AFTER_DENY ||state     ==ACCESS_AFTER_DENY_W || state==ACCESS_LAST_W)?1'b1:1'b0;
assign resp_from_slave = state[2];

//assign   data_sel          = (state      ==ACCESS ||state      ==ACCESS_W ||state      ==ACCESS_AFTER_DENY ||state     ==ACCESS_AFTER_DENY_W || state==ACCESS_LAST_W)?1'b1:1'b0;
assign data_sel = state[1];

//assign   resp_idle = (state==DENY_W||state==DENY)?1'b0:1'b1;
assign resp_idle = state[0];


endmodule

