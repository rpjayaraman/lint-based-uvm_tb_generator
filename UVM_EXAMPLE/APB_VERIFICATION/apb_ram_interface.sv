
interface apb_ram_interface (input logic  pclk);

    logic presetn;
    logic psel;
    logic penable;
    logic pwrite;
    logic [31:0] paddr;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic pready;
    logic pslverr;
//--------------------------------------
//Driver Clocking Block
//--------------------------------------
clocking driver_cb @(posedge pclk);
	default input #1 output #1;
	output  psel;
	output  penable;
	output  pwrite;
	output  paddr;
	output  pwdata;
	input  prdata;
	input  pready;
	input  pslverr;

endclocking //driver_cb
//--------------------------------------
//Monitor Clocking Block
//--------------------------------------
clocking monitor_cb @(posedge pclk);
default input #1 output #1;
	input  psel;
	input  penable;
	input  pwrite;
	input  paddr;
	input  pwdata;
	input  prdata;
	input  pready;
	input  pslverr;

endclocking //monitor_cb
//--------------------------------------
//Driver Modport
//--------------------------------------
modport DRIVER  (clocking driver_cb,input  pclk);

//--------------------------------------
//Monitor Modport
//--------------------------------------
modport MONITOR (clocking monitor_cb,input  pclk);

endinterface //apb_ram_interface