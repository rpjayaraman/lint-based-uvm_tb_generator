class FIFO_memory_base_sequence extends uvm_sequence#(FIFO_memory_seq_item);

`uvm_object_utils(FIFO_memory_base_sequence)
FIFO_memory_seq_item req;

extern function new( string name = "FIFO_memory_base_sequence");
extern task body();

endclass //FIFO_memory_base_sequence

function FIFO_memory_base_sequence::new(string name = "FIFO_memory_base_sequence");
 super.new( name );
endfunction : new

task FIFO_memory_base_sequence::body();
`uvm_info(get_type_name(), $sformatf("Start of FIFO_memory_base_sequence Sequence"), UVM_LOW)
req = FIFO_memory_seq_item:: type_id :: create("req");
repeat(5) begin //{
	`uvm_do(req)
end //}
`uvm_info(get_type_name(), $sformatf("End of FIFO_memory_base_sequence Sequence"), UVM_LOW)

endtask //FIFO_memory_base_sequence