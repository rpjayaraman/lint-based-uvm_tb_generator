`define DRIV_VIF vif.DRIVER.driver_cb

class FIFO_memory_driver extends uvm_driver#(FIFO_memory_seq_item);

`uvm_component_utils(FIFO_memory_driver)

virtual FIFO_memory_interface vif;
  FIFO_memory_seq_item tx;
  FIFO_memory_seq_item rsp;

extern function new( string name = "FIFO_memory_driver",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);
extern task do_reset();
extern task do_driver(input FIFO_memory_seq_item t, output FIFO_memory_seq_item r);

endclass //FIFO_memory_driver

function FIFO_memory_driver::new(string name,uvm_component parent);
 super.new(name,parent);
endfunction : new

function void FIFO_memory_driver::build_phase(uvm_phase phase);
 super.build_phase(phase);

 `uvm_info(get_type_name(),"In Build Phase ...",UVM_NONE)
	if(!uvm_config_db#(virtual FIFO_memory_interface)::get(this, "", "vif", vif))
		begin
		`uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
		end
  tx =FIFO_memory_seq_item::type_id::create("tx");
endfunction : build_phase

task FIFO_memory_driver::do_reset();
  vif.reset <= 1;
  vif.din <= 0;
  vif.read <= 0;
  vif.write <= 0;
  
endtask 
  
task FIFO_memory_driver::do_driver(input FIFO_memory_seq_item t, output FIFO_memory_seq_item r);
FIFO_memory_seq_item resp; //temp handle which has holds the response
  if(!$cast(resp, t.clone())) //We are cloning transaction item 
    `uvm_fatal("DRIVER", "CAST FAILED")
    @(posedge vif.clk); //waiting for the posedge of clk

  if(t.reset) begin //Perform reset
      vif.reset <= 1;
  	  vif.din <= 0;
      vif.read <= 0;
      vif.write <= 0;
    @(posedge vif.clk);
    resp.dout = vif.dout;
    resp.full = vif.full;
    resp.empty = vif.empty;
    resp.alf = vif.alf;
    resp.ale = vif.ale;
    r = resp;
  end
  
  else if (!t.reset && t.write) begin //Write operation 
    vif.reset <= t.reset;
    vif.din <= t.din;
    vif.write <= t.write;
    vif.read <= 0;
    @(posedge vif.clk);
    //Capturing the response
    resp.dout = vif.dout;
    resp.full = vif.full;
    resp.empty = vif.empty;
    resp.alf = vif.alf;
    resp.ale = vif.ale;
    r = resp;
  end
  else if (!t.reset && t.read) begin //READ operation 
    vif.reset <= t.reset;
    vif.din <= t.din;
    vif.write <=0;
    vif.read <= t.read;
    @(posedge vif.clk);
    //Capturing the response
    resp.dout = vif.dout;
    resp.full = vif.full;
    resp.empty = vif.empty;
    resp.alf = vif.alf;
    resp.ale = vif.ale;
    r = resp;
  end
    
  
endtask 
  
  
task FIFO_memory_driver::run_phase(uvm_phase phase);
	super.run_phase(phase);

 `uvm_info(get_type_name(),"In Run Phase ...",UVM_NONE)
  //Initialze the variables
  do_reset();
	forever begin //{
      seq_item_port.get_next_item(tx);
      uvm_report_info(get_type_name(), $sformatf("Got Input Transaction %s",tx.input2string()));
      do_driver(tx, rsp); //TX -> From Sequence RSp -> To sequence
      rsp.set_id_info(tx); // This function will copy the sequence-id and transaction id from tx -> rx
      uvm_report_info(get_type_name(), $sformatf("Got Response %s",rsp.output2string())); //we print response which we are going to send to sequence
      seq_item_port.item_done(rsp); //we have to send the respone in item_done
	end //}

endtask: run_phase
