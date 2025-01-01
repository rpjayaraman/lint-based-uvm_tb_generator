class FIFO_memory_test extends uvm_test;

virtual FIFO_memory_interface vif;
FIFO_memory_env u_env;
		FIFO_memory_base_sequence u_seq;

`uvm_component_utils(FIFO_memory_test)

extern function new( string name = "FIFO_memory_test",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);

endclass //FIFO_memory_test

function FIFO_memory_test::new(string name,uvm_component parent);
 super.new(name,parent);
endfunction : new

function void FIFO_memory_test::build_phase(uvm_phase phase);
 super.build_phase(phase);

 `uvm_info(get_type_name(),"In Build Phase ...",UVM_NONE)
	u_env=FIFO_memory_env::type_id::create("u_env",this);
endfunction : build_phase

task FIFO_memory_test::run_phase(uvm_phase phase);
	super.run_phase(phase);

		`uvm_info(get_type_name(),"In Run Phase ...",UVM_NONE)
		u_seq=FIFO_memory_base_sequence::type_id::create("u_seq",this);
		phase.raise_objection( this, "Starting phase objection");

		`uvm_info(get_type_name(), $sformatf("Starting Sequence"), UVM_LOW)
		uvm_top.print_topology();
		u_seq.start(u_env.u_agent.u_sqr);

		phase.drop_objection( this, "Dropping phase objection");
endtask: run_phase
