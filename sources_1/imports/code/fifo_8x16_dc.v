module fifo_8x16_dc (/*AUTOARG*/
   // Outputs
   dout, empty, full,
   // Inputs
   rd_en, rd_clk, rst, din, wr_en, wr_clk
   );
   output reg  [7:0]        dout;
   output reg               empty;
   input wire               rd_en;
   input wire               rd_clk;
   input wire               rst;

   input wire [7:0]         din;
   output reg               full;
   input wire               wr_en;
   input wire               wr_clk;

   reg [7:0]                Mem [15:0];
   wire [3:0]               pNextWordToWrite, pNextWordToRead;
   wire                     EqualAddresses;
   wire                     NextWriteAddressEn, NextReadAddressEn;
   wire                     Set_Status, Rst_Status;
   reg                      Status;
   wire                     PresetFull, PresetEmpty;
   always @ (posedge rd_clk)
     if (rd_en & !empty)
       dout <= Mem[pNextWordToRead];

   always @ (posedge wr_clk)
     if (wr_en & !full)
       Mem[pNextWordToWrite] <= din;

   assign NextWriteAddressEn = wr_en & ~full;
   assign NextReadAddressEn  = rd_en  & ~empty;

   GrayCounter GrayCounter_pWr
     (.GrayCount_out(pNextWordToWrite),
      .Enable_in(NextWriteAddressEn),
      .rst(rst),
      .Clk(wr_clk)
      );
   GrayCounter GrayCounter_pRd
     (.GrayCount_out(pNextWordToRead),
      .Enable_in(NextReadAddressEn),
      .rst(rst),
      .Clk(rd_clk)
      );

   //'EqualAddresses' logic:
   assign EqualAddresses = (pNextWordToWrite == pNextWordToRead);

   //'Quadrant selectors' logic:
   assign Set_Status = (pNextWordToWrite[4-2] ~^ pNextWordToRead[4-1]) &
                       (pNextWordToWrite[4-1] ^  pNextWordToRead[4-2]);
   assign Rst_Status = (pNextWordToWrite[4-2] ^  pNextWordToRead[4-1]) &
                       (pNextWordToWrite[4-1] ~^ pNextWordToRead[4-2]);
    //'Status' latch logic:
    always @ (Set_Status, Rst_Status, rst) //D Latch w/ Asynchronous Clear & Preset.
        if (Rst_Status | rst)
            Status = 0;  //Going 'Empty'.
        else if (Set_Status)
            Status = 1;  //Going 'Full'.
    //'full' logic for the writing port:
    assign PresetFull = Status & EqualAddresses;  //'Full' Fifo.

    always @ (posedge wr_clk or posedge PresetFull) //D Flip-Flop w/ Asynchronous Preset.
        if (PresetFull)
            full <= 1;
        else
            full <= 0;

    //'empty' logic for the reading port:
    assign PresetEmpty = ~Status & EqualAddresses;  //'Empty' Fifo.

    always @ (posedge rd_clk or posedge PresetEmpty)  //D Flip-Flop w/ Asynchronous Preset.
        if (PresetEmpty)
            empty <= 1;
        else
            empty <= 0;
endmodule

module GrayCounter
   (output reg  [3:0]    GrayCount_out,  //'Gray' code count output.

    input wire Enable_in, //Count enable.
    input wire rst, //Count reset.
    input wire Clk);
   reg [3:0] BinaryCount;

   always @ (posedge Clk)
     if (rst) begin
        BinaryCount   <= {4{1'b0}} + 1;  //Gray count begins @ '1' with
     GrayCount_out <= {4{1'b0}};      // first 'Enable_in'.
  end
     else if (Enable_in) begin
        BinaryCount   <= BinaryCount + 1;
        GrayCount_out <= {BinaryCount[3],
                          BinaryCount[2:0] ^ BinaryCount[3:1]};
     end

endmodule
