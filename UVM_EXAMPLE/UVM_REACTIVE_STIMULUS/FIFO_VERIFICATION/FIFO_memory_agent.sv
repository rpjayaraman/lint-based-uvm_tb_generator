class FIFO_memory_agent extends uvm_agent;

`uvm_component_utils(FIFO_memory_agent)
FIFO_memory_sequencer u_sqr;
FIFO_memory_driver u_driver;
FIFO_memory_monitor u_monitor;

virtual FIFO_memory_interface vif;

extern function new( string name = "FIFO_memory_agent",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass //FIFO_memory_agent

function FIFO_memory_agent::new(string name,uvm_component parent);
	super.new(name,parent);
endfunction : new

function void FIFO_memory_agent::build_phase(uvm_phase phase);
 super.build_phase(phase);

 `uvm_info(get_type_name(),"In Build Phase ...",UVM_NONE)
	u_sqr     =FIFO_memory_sequencer   ::type_id::create("u_sqr",this);
	u_driver  =FIFO_memory_driver ::type_id::create("u_driver",this);
	u_monitor =FIFO_memory_monitor::type_id::create("u_monitor",this);
endfunction : build_phase

function void FIFO_memory_agent::connect_phase(uvm_phase phase);
 super.connect_phase(phase);
 `uvm_info(get_type_name(),"In Connect Phase ...",UVM_NONE)

 u_driver.seq_item_port.connect(u_sqr.seq_item_export);
 `uvm_info(get_type_name(),"CONNECT_PHASE:Connected Driver and Sequencer",UVM_NONE)
endfunction : connect_phase
