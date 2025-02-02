class FIFO_memory_scoreboard extends uvm_scoreboard;

virtual FIFO_memory_interface vif;
uvm_analysis_imp#(FIFO_memory_seq_item,FIFO_memory_scoreboard) sb_export;

`uvm_component_utils(FIFO_memory_scoreboard)

extern function new( string name = "FIFO_memory_scoreboard",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);
extern virtual function void write(FIFO_memory_seq_item pkt);
endclass //FIFO_memory_scoreboard

function FIFO_memory_scoreboard::new(string name,uvm_component parent);
	super.new(name,parent);
	sb_export=new("sb_export", this);
endfunction : new

function void FIFO_memory_scoreboard::build_phase(uvm_phase phase);
 super.build_phase(phase);

 `uvm_info(get_type_name(),"In Build Phase ...",UVM_NONE)

endfunction : build_phase

task FIFO_memory_scoreboard::run_phase(uvm_phase phase);
	super.run_phase(phase);

 `uvm_info(get_type_name(),"In Run Phase ...",UVM_NONE)

endtask: run_phase

function void FIFO_memory_scoreboard::write(FIFO_memory_seq_item pkt);
	pkt.print();
endfunction : write
