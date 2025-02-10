class apb_ram_base_sequence extends uvm_sequence#(apb_ram_seq_item);

`uvm_object_utils(apb_ram_base_sequence)
apb_ram_seq_item req;

extern function new( string name = "apb_ram_base_sequence");
extern task body();

endclass //apb_ram_base_sequence

function apb_ram_base_sequence::new(string name = "apb_ram_base_sequence");
 super.new( name );
endfunction : new

task apb_ram_base_sequence::body();
`uvm_info(get_type_name(), $sformatf("Start of apb_ram_base_sequence Sequence"), UVM_LOW)
req = apb_ram_seq_item:: type_id :: create("req");
    `uvm_do_with(req, {
  				req.presetn == 0;	})
  `uvm_do_with(req, {
  				req.presetn == 1;
    			req.pwrite  ==1;
    			req.paddr == 1;
  		})
    `uvm_do_with(req, {
  				req.presetn == 1;
    			req.pwrite  ==0;
    			req.paddr == 1;
  		})
`uvm_info(get_type_name(), $sformatf("End of apb_ram_base_sequence Sequence"), UVM_LOW)

endtask //apb_ram_base_sequence