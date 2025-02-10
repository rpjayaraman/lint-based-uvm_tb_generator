class FIFO_memory_base_sequence extends uvm_sequence#(FIFO_memory_seq_item);

`uvm_object_utils(FIFO_memory_base_sequence)
FIFO_memory_seq_item req;
FIFO_memory_seq_item rsp;

extern function new( string name = "FIFO_memory_base_sequence");
extern task body();
  extern task do_reset(FIFO_memory_seq_item);
  extern task do_write(FIFO_memory_seq_item);
  extern task do_read(FIFO_memory_seq_item);
  extern task do_write_untill_full_flag(FIFO_memory_seq_item);
  extern task do_read_untill_empty_flag(FIFO_memory_seq_item);
endclass //FIFO_memory_base_sequence

function FIFO_memory_base_sequence::new(string name = "FIFO_memory_base_sequence");
 super.new( name );
endfunction : new

    task FIFO_memory_base_sequence::do_reset(FIFO_memory_seq_item tx);
      start_item(tx);
      tx.reset = 1;
      tx.din = 0;
      tx.read = 0;
      tx.write = 0;
      finish_item(tx);
    endtask 
    
    
    task FIFO_memory_base_sequence::do_write(FIFO_memory_seq_item tx);
      start_item(tx);
      assert (tx.randomize() with {tx.reset == 0;
                                  tx.write == 1;
                                  tx.read == 0;});
      finish_item(tx);
      get_response(rsp);
      //Printing the response
      `uvm_info(get_type_name(), $sformatf("Response %s", rsp.output2string()), UVM_LOW)
    endtask 
      task FIFO_memory_base_sequence::do_read(FIFO_memory_seq_item tx);
      start_item(tx);
      assert (tx.randomize() with {tx.reset == 0;
                                  tx.write == 0;
                                  tx.read == 1;});
      finish_item(tx);
      get_response(rsp);
      //Printing the response
      `uvm_info(get_type_name(), $sformatf("Response %s", rsp.output2string()), UVM_LOW)
    endtask 
    
    task FIFO_memory_base_sequence::do_write_untill_full_flag(FIFO_memory_seq_item tx);
      while(!rsp.full) begin
        do_write(tx);
      end
      `uvm_info(get_type_name(), "WRITE is DONE  --------->", UVM_LOW)
  endtask 
    
    task FIFO_memory_base_sequence::do_read_untill_empty_flag(FIFO_memory_seq_item tx);
      while(!rsp.empty) begin
        do_read(tx);
      end
      `uvm_info(get_type_name(), "READ is DONE  <--------->", UVM_LOW)
  endtask 
      
    
task FIFO_memory_base_sequence::body();
`uvm_info(get_type_name(), $sformatf("Start of FIFO_memory_base_sequence Sequence"), UVM_LOW)
req = FIFO_memory_seq_item:: type_id :: create("req");

  do_reset(req); //task to perform reset
  do_write (req); //Tas to perform WRITE 
  do_write_untill_full_flag(req); //perform write operation untill FULL is asserted
  do_read(req); //Task to perform READ  
  do_read_untill_empty_flag(req); //perform read operation untill empty is asserted
  
  
`uvm_info(get_type_name(), $sformatf("End of FIFO_memory_base_sequence Sequence"), UVM_LOW)

endtask //FIFO_memory_base_sequence