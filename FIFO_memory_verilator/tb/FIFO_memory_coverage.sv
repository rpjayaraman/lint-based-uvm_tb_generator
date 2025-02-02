class FIFO_memory_coverage extends uvm_subscriber#(FIFO_memory_seq_item);

`uvm_component_utils(FIFO_memory_coverage)
FIFO_memory_seq_item item;
uvm_analysis_imp#(FIFO_memory_seq_item,FIFO_memory_coverage) cov_export;

extern function new( string name = "FIFO_memory_coverage",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);
extern virtual function void write(FIFO_memory_seq_item t);
extern function void report_phase(uvm_phase phase);

endclass //FIFO_memory_coverage

function FIFO_memory_coverage::new(string name,uvm_component parent);
	super.new(name,parent);
endfunction : new

function void FIFO_memory_coverage::build_phase(uvm_phase phase);
 super.build_phase(phase);
	cov_export=new("cov_export", this);

 `uvm_info(get_type_name(),"In Build Phase ...",UVM_NONE)

endfunction : build_phase

function void FIFO_memory_coverage::connect_phase(uvm_phase phase);
	super.connect_phase(phase);

 `uvm_info(get_type_name(),"In Connect Phase ...",UVM_NONE)

endfunction: connect_phase

task FIFO_memory_coverage::run_phase(uvm_phase phase);
	super.run_phase(phase);

 `uvm_info(get_type_name(),"In Run Phase ...",UVM_NONE)

endtask: run_phase

function void FIFO_memory_coverage::write(FIFO_memory_seq_item t);
	item=t;
endfunction : write

function void FIFO_memory_coverage:: report_phase(uvm_phase phase);
	super.report_phase(phase);
endfunction: report_phase