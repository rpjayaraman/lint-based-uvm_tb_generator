import uvm_pkg:: *;
`include "uvm_macros.svh"
`include "FIFO_memory_seq_item.sv"
`include "FIFO_memory_sequencer.sv"
`include "FIFO_memory_base_sequence.sv"
`include "FIFO_memory_driver.sv"
`include "FIFO_memory_interface.sv"
`include "FIFO_memory_monitor.sv"
`include "FIFO_memory_agent.sv"
`include "FIFO_memory_scoreboard.sv"
`include "FIFO_memory_coverage.sv"
`include "FIFO_memory_env.sv"
`include "FIFO_memory_test.sv"

module FIFO_memory_top;

//--------------------------------------
//signal declaration: clock and reset
//--------------------------------------
bit clk; 
bit reset;

initial begin
 clk=0; reset=0;
end
//--------------------------------------
//clock Generation
//--------------------------------------
always begin
	#5 clk <= ~clk;
end

//--------------------------------------
//Interface Instance
//--------------------------------------
FIFO_memory_interface intf( clk,  reset);

//--------------------------------------
//DUT Instance
//--------------------------------------
 FIFO_memory UUT(
	.clk(intf.clk),
	.reset(intf.reset),
	.din(intf.din),
	.read(intf.read),
	.write(intf.write),
	.dout(intf.dout),
	.empty(intf.empty),
	.full(intf.full),
	.ale(intf.ale),
	.alf(intf.alf)
);

initial begin
	uvm_config_db#(virtual FIFO_memory_interface)::set(uvm_root::get(), "*", "vif", intf);
	//enable wave dump
	$dumpfile("dump.vcd");
	$dumpvars;
end

initial begin
	run_test("FIFO_memory_test");
end

endmodule //FIFO_memory_top
