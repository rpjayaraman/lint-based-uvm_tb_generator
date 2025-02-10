import uvm_pkg:: *;
`include "uvm_macros.svh"
`include "apb_ram_seq_item.sv"
`include "apb_ram_sequencer.sv"
`include "apb_ram_base_sequence.sv"
`include "apb_ram_driver.sv"
`include "apb_ram_interface.sv"
`include "apb_ram_monitor.sv"
`include "apb_ram_agent.sv"
`include "apb_ram_scoreboard.sv"
`include "apb_ram_coverage.sv"
`include "apb_ram_env.sv"
`include "apb_ram_test.sv"

module apb_ram_top;

//--------------------------------------
//signal declaration: clock and reset
//--------------------------------------
    bit pclk;

initial begin
 pclk=0;
end
//--------------------------------------
//clock Generation
//--------------------------------------
always begin
	#5 pclk <= ~pclk;
end

//--------------------------------------
//Interface Instance
//--------------------------------------
apb_ram_interface intf(pclk);

//--------------------------------------
//DUT Instance
//--------------------------------------
 apb_ram UUT(
	.presetn(intf.presetn),
	.pclk(intf.pclk),
	.psel(intf.psel),
	.penable(intf.penable),
	.pwrite(intf.pwrite),
	.paddr(intf.paddr),
	.pwdata(intf.pwdata),
	.prdata(intf.prdata),
	.pready(intf.pready),
	.pslverr(intf.pslverr)
);

initial begin
	uvm_config_db#(virtual apb_ram_interface)::set(uvm_root::get(), "*", "vif", intf);
	//enable wave dump
	$dumpfile("dump.vcd");
	$dumpvars;
end

initial begin
	run_test("apb_ram_test");
end

endmodule //apb_ram_top
