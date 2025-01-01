class FIFO_memory_sequencer extends uvm_sequencer#(FIFO_memory_seq_item);

`uvm_component_utils(FIFO_memory_sequencer)

extern function new( string name = "FIFO_memory_sequencer",uvm_component parent=null);
extern function void build_phase(uvm_phase phase);

endclass //FIFO_memory_sequencer

function FIFO_memory_sequencer::new(string name,uvm_component parent);
 super.new(name,parent);
endfunction : new

function void FIFO_memory_sequencer::build_phase(uvm_phase phase);
 super.build_phase(phase);
 `uvm_info(get_type_name(),"In Build Phase ...",UVM_NONE)
endfunction : build_phase
