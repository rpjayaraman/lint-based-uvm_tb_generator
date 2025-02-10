class apb_ram_agent extends uvm_agent;

`uvm_component_utils(apb_ram_agent)
apb_ram_sequencer u_sqr;
apb_ram_driver u_driver;
apb_ram_monitor u_monitor;

virtual apb_ram_interface vif;

extern function new( string name = "apb_ram_agent",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass //apb_ram_agent

function apb_ram_agent::new(string name,uvm_component parent);
	super.new(name,parent);
endfunction : new

function void apb_ram_agent::build_phase(uvm_phase phase);
 super.build_phase(phase);

 `uvm_info(get_type_name(),"In Build Phase ...",UVM_NONE)
	u_sqr     =apb_ram_sequencer   ::type_id::create("u_sqr",this);
	u_driver  =apb_ram_driver ::type_id::create("u_driver",this);
	u_monitor =apb_ram_monitor::type_id::create("u_monitor",this);
endfunction : build_phase

function void apb_ram_agent::connect_phase(uvm_phase phase);
 super.connect_phase(phase);
 `uvm_info(get_type_name(),"In Connect Phase ...",UVM_NONE)

 u_driver.seq_item_port.connect(u_sqr.seq_item_export);
 `uvm_info(get_type_name(),"CONNECT_PHASE:Connected Driver and Sequencer",UVM_NONE)
endfunction : connect_phase
