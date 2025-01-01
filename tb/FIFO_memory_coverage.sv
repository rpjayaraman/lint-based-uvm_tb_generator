class FIFO_memory_coverage extends uvm_subscriber#(FIFO_memory_seq_item);

`uvm_component_utils(FIFO_memory_coverage)
FIFO_memory_seq_item item;
uvm_analysis_imp#(FIFO_memory_seq_item,FIFO_memory_coverage) cov_export;
covergroup cg_FIFO_memory_coverage;

	option.per_instance = 1;
	option.name="Coverage for  FIFO_memory";
	option.comment="Add your comment";
	option.goal=100;

	cp_din: coverpoint (item.din)
	{
		option.auto_bin_max = 2;
	}
	cp_read: coverpoint (item.read)
	{
		option.auto_bin_max = 2;
	}
	cp_write: coverpoint (item.write)
	{
		option.auto_bin_max = 2;
	}

	cross_cp: cross cp_din, cp_read, cp_write;

endgroup: cg_FIFO_memory_coverage
extern function new( string name = "FIFO_memory_coverage",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);
extern virtual function void write(FIFO_memory_seq_item t);
extern function void report_phase(uvm_phase phase);

endclass //FIFO_memory_coverage

function FIFO_memory_coverage::new(string name,uvm_component parent);
	super.new(name,parent);
	cg_FIFO_memory_coverage=new();
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
	cg_FIFO_memory_coverage.sample();
endfunction : write

function void FIFO_memory_coverage:: report_phase(uvm_phase phase);
	super.report_phase(phase);
	`uvm_info(get_full_name(),$sformatf("Coverage is %f",cg_FIFO_memory_coverage.get_coverage()),UVM_LOW);
endfunction: report_phase