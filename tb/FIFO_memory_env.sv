class FIFO_memory_env extends uvm_env;

`uvm_component_utils(FIFO_memory_env)
FIFO_memory_agent u_agent;
FIFO_memory_scoreboard u_sb;
FIFO_memory_coverage u_cov;

extern function new( string name = "FIFO_memory_env",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass //FIFO_memory_env

function FIFO_memory_env::new(string name,uvm_component parent);
	super.new(name,parent);
endfunction : new

function void FIFO_memory_env::build_phase(uvm_phase phase);
 super.build_phase(phase);

 `uvm_info(get_type_name(),"In Build Phase ...",UVM_NONE)
	u_agent=FIFO_memory_agent::type_id::create("u_agent",this);	u_sb=FIFO_memory_scoreboard::type_id::create("u_sb",this);	u_cov=FIFO_memory_coverage::type_id::create("u_cov",this);
endfunction : build_phase

function void FIFO_memory_env::connect_phase(uvm_phase phase);
 super.connect_phase(phase);
 `uvm_info(get_type_name(),"Connecting monitor and Scoreboard",UVM_NONE)
	u_agent.u_monitor.mon_aport.connect(u_sb.sb_export);	u_agent.u_monitor.mon_aport.connect(u_cov.cov_export);
endfunction : connect_phase
