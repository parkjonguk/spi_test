`define PRODUCT_RELEASE
`define FPGA
`define CMOD_A7						// Active-High Reset
//`define GENESYS2
//`define USE_CHIPSCOPE
`define HOST_IF_SPI
`define HOST_IF_UART
`define HOST_IF_SFIFO
`define HOST_AHB_BRIDGE_SUPPORT
`define AHB_ADDR_INC
//`define HOST_IRQ_SUPPORT
`define LARGE_LOOPBACK_MEM
//`define AHB_LITE

`define SYS_CLK_96M
//`define SYS_CLK_100M
//`define SYS_CLK_135M
//`define SYS_CLK_150M
//`define SYS_CLK_200M


`ifdef PRODUCT_RELEASE
	`undef FPGA
	`undef CMOD_A7
	`undef GENESYS2
	`undef FIFO_TEST
	`undef USE_CHIPSCOPE
	`undef SYS_CLK_100M
	`undef SYS_CLK_135M
	`undef SYS_CLK_150M
	`undef SYS_CLK_200M
	`undef HOST_IRQ_SUPPORT
	`undef LARGE_LOOPBACK_MEM

	`define HOST_IF_SPI
	`define HOST_IF_UART
	`define HOST_IF_SFIFO
	`define HOST_AHB_BRIDGE_SUPPORT
	`define AHB_ADDR_INC
	`define SYS_CLK_96M
`endif


`define HOST_MODE_SPI				2'd0
`define HOST_MODE_UART				2'd1
`define HOST_MODE_SFIFO				2'd3

`define SOF1						8'hAA
`define SOF2						8'h55

`define DIR_TX						0			// Host Read
`define DIR_RX						1			// Host Write

`define LOOP_NONE					1'b0
`define LOOP_AHB_CRYPTO				1'b1

// I2C
`define I2C_SLAVE_ADDR				8'h50		// 7-bit address = 8'h28

`define I2C_VERSION_VALUE			8'h12

// Default Baudrate = 4Mbaud
`ifdef SYS_CLK_96M
	`define DEF_BAUD_NCO_0			8'hAB
	`define DEF_BAUD_NCO_1			8'hAA
	`define DEF_BAUD_NCO_2			8'hAA
	`define DEF_BAUD_NCO_3			8'h0A
`elsif SYS_CLK_100M
	`define DEF_BAUD_NCO_0			8'hA4
	`define DEF_BAUD_NCO_1			8'h70
	`define DEF_BAUD_NCO_2			8'h3D
	`define DEF_BAUD_NCO_3			8'h0A
`elsif SYS_CLK_135M
	`define DEF_BAUD_NCO_0			8'hB2
	`define DEF_BAUD_NCO_1			8'hCE
	`define DEF_BAUD_NCO_2			8'h95
	`define DEF_BAUD_NCO_3			8'h07
`elsif SYS_CLK_150M
	`define DEF_BAUD_NCO_0			8'h6D
	`define DEF_BAUD_NCO_1			8'hA0
	`define DEF_BAUD_NCO_2			8'hD3
	`define DEF_BAUD_NCO_3			8'h06
`else	// SYS_CLK_200M
	`define DEF_BAUD_NCO_0			8'h52
	`define DEF_BAUD_NCO_1			8'hB8
	`define DEF_BAUD_NCO_2			8'h1E
	`define DEF_BAUD_NCO_3			8'h05
`endif


`define I2C_ADDR_VERSION			8'h00
`define I2C_ADDR_MODE				8'h01
`define I2C_ADDR_IO_CONFIG			8'h02
`define I2C_ADDR_UART_CONFIG		8'h03
`define I2C_ADDR_UART_BAUD_0		8'h04
`define I2C_ADDR_UART_BAUD_1		8'h05
`define I2C_ADDR_UART_BAUD_2		8'h06
`define I2C_ADDR_UART_BAUD_3		8'h07

// AHB
`define AHB_IDLE					2'b00
`define AHB_BUSY					2'b01
`define AHB_NONSEQ					2'b10
`define AHB_SEQ						2'b11

`define AHB_HTRANS_IDLE				2'b00
`define AHB_HTRANS_BUSY				2'b01
`define AHB_HTRANS_NONSEQ			2'b10
`define AHB_HTRANS_SEQ				2'b11

`define HSIZE_BIT8					3'd0
`define HSIZE_BIT16					3'd1
`define HSIZE_BIT32					3'd2


`define AHB_ADDR_COMMON				32'h0000_0000
`define AHB_ADDR_HOST_BRIDGE		32'h8000_0000
`define AHB_ADDR_CRYPTO				32'h9000_0000

`define AHB_SLAVE_ADDR_0			`AHB_ADDR_HOST_BRIDGE
`define AHB_SLAVE_ADDR_1			`AHB_ADDR_CRYPTO
