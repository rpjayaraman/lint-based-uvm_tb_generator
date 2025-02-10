class apb_ram_sequencer extends uvm_sequencer#(apb_ram_seq_item);

`uvm_component_utils(apb_ram_sequencer)

extern function new( string name = "apb_ram_sequencer",uvm_component parent=null);
extern function void build_phase(uvm_phase phase);

endclass //apb_ram_sequencer

function apb_ram_sequencer::new(string name,uvm_component parent);
 super.new(name,parent);
endfunction : new

function void apb_ram_sequencer::build_phase(uvm_phase phase);
 super.build_phase(phase);
 `uvm_info(get_type_name(),"In Build Phase ...",UVM_NONE)
endfunction : build_phase
