class FIFO_memory_scoreboard extends uvm_scoreboard;

virtual FIFO_memory_interface vif;
uvm_analysis_imp#(FIFO_memory_seq_item,FIFO_memory_scoreboard) sb_export;
  FIFO_memory_seq_item trans_q[$];
  int data_in_q [$]; //Queue to store the din data
  
`uvm_component_utils(FIFO_memory_scoreboard)

extern function new( string name = "FIFO_memory_scoreboard",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);
extern virtual function void write(FIFO_memory_seq_item pkt);
endclass //FIFO_memory_scoreboard

function FIFO_memory_scoreboard::new(string name,uvm_component parent);
	super.new(name,parent);
	sb_export=new("sb_export", this);
endfunction : new

function void FIFO_memory_scoreboard::build_phase(uvm_phase phase);
 super.build_phase(phase);

 `uvm_info(get_type_name(),"In Build Phase ...",UVM_NONE)

endfunction : build_phase

task FIFO_memory_scoreboard::run_phase(uvm_phase phase);
FIFO_memory_seq_item recv_trans;
int temp_din;
  super.run_phase(phase);

 `uvm_info(get_type_name(),"In Run Phase ...",UVM_NONE)

  forever begin
    
    //wait for queue to be filled
    wait(trans_q.size > 0);
    if(trans_q.size > 0) begin
      
      recv_trans = trans_q.pop_front();     
      
    end //queue size loop
    if (recv_trans.reset) begin
      `uvm_info(get_type_name(), "RESET is detected", UVM_LOW)
    end
    else if (!recv_trans.reset && recv_trans.write) begin //write operation
      data_in_q.push_back(recv_trans.din); //if it is write, push the din data into queue
      `uvm_info("WRITE_DEBUG", "GOT WRITE TRANS", UVM_LOW)
    end
   
    else if (!recv_trans.reset && recv_trans.read) begin //read operation 
      temp_din = data_in_q.pop_front();
      `uvm_info("READ_DEBUG", "GOT READ TRANS", UVM_LOW)

      if(recv_trans.dout != 0) begin
        if(temp_din == recv_trans.dout)
          `uvm_warning("PASS", $sformatf("%d == %d", temp_din , recv_trans.dout), UVM_LOW)
          else
            `uvm_error("FAIL", $sformatf("%d != %d", temp_din , recv_trans.dout))

            
      end
    end
    
    
  end //forever loop
  
  
  
  
  
  
endtask: run_phase

function void FIFO_memory_scoreboard::write(FIFO_memory_seq_item pkt);
//pkt.print();
  //lets push the incoming transaction into queue
  trans_q.push_back(pkt);
        `uvm_info("DEBUG", $sformatf("%p", pkt.input2string), UVM_LOW)
endfunction : write
