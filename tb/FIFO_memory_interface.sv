
interface FIFO_memory_interface (input logic  clk,  reset);
 
parameter DATA_WIDTH=8;
parameter ADDR_WIDTH=4; 
logic [DATA_WIDTH-1:0]din;    
logic read; 
logic write; 
logic [DATA_WIDTH-1:0]dout; 
logic empty;      
logic full; 
logic ale; 
logic alf;
//--------------------------------------
//Driver Clocking Block
//--------------------------------------
clocking driver_cb @(posedge clk);
	default input #1 output #1;
	output din;
	output  read;
	output  write;
	input dout;
	input  empty;
	input  full;
	input  ale;
	input  alf;

endclocking //driver_cb
//--------------------------------------
//Monitor Clocking Block
//--------------------------------------
clocking monitor_cb @(posedge clk);
default input #1 output #1;
	input din;
	input  read;
	input  write;
	input dout;
	input  empty;
	input  full;
	input  ale;
	input  alf;

endclocking //monitor_cb
//--------------------------------------
//Driver Modport
//--------------------------------------
modport DRIVER  (clocking driver_cb,input  clk,  reset);

//--------------------------------------
//Monitor Modport
//--------------------------------------
modport MONITOR (clocking monitor_cb,input  clk,  reset);

endinterface //FIFO_memory_interface