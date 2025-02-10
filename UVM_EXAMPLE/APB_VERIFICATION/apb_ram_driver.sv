`define DRIV_VIF vif.DRIVER.driver_cb

class apb_ram_driver extends uvm_driver#(apb_ram_seq_item);

`uvm_component_utils(apb_ram_driver)

virtual apb_ram_interface vif;

extern function new( string name = "apb_ram_driver",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);

endclass //apb_ram_driver

function apb_ram_driver::new(string name,uvm_component parent);
 super.new(name,parent);
endfunction : new

function void apb_ram_driver::build_phase(uvm_phase phase);
 super.build_phase(phase);

 `uvm_info(get_type_name(),"In Build Phase ...",UVM_NONE)
	if(!uvm_config_db#(virtual apb_ram_interface)::get(this, "", "vif", vif))
		begin
		`uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
		end
endfunction : build_phase

task apb_ram_driver::run_phase(uvm_phase phase);
	super.run_phase(phase);

 `uvm_info(get_type_name(),"In Run Phase ...",UVM_NONE)
  vif.presetn <= 0;
  vif.paddr <= 0;
  vif.psel <= 0;
  vif.penable <= 0;
  vif.pwrite <= 0;
  vif.pwdata <= 0;
  
	forever begin //{
		apb_ram_seq_item tr;
		seq_item_port.get_next_item(tr);
		uvm_report_info(get_type_name(), $sformatf("Got Input Transaction %s",tr.input2string()));
		//Driver Logic
      //Check reset 
       @(posedge vif.pclk);
      if (!tr.presetn) begin
          	vif.presetn <= 0;
  			vif.paddr <= 0;
  			vif.psel <= 0;
  			vif.penable <= 0;
  			vif.pwrite <= 0;
  			vif.pwdata <= 0;
  
      end
      else if (tr.presetn && tr.pwrite) begin //write
        vif.presetn <= 1;
        vif.pwrite <= 1;
        vif.paddr <= tr.paddr;
        vif.pwdata <= tr.pwdata;
        vif.psel <= 1;
        @(posedge vif.pclk);
        vif.penable <= 1;
        @(negedge vif.pready);
         vif.penable <= 0;
       tr.pslverr <= vif.pslverr;

        
      end //write
      else if (tr.presetn && !tr.pwrite) begin //read
        vif.presetn <= 1;
        vif.pwrite <= 0;
        vif.paddr <= tr.paddr;
        vif.psel <= 1;
        @(posedge vif.pclk);
        vif.penable <= 1;
        @(negedge vif.pready);
         vif.penable <= 0;
        	tr.prdata <= vif.prdata;
       tr.pslverr <= vif.pslverr;

        
      end //read
      
      
      
      
      
		uvm_report_info(get_type_name(), $sformatf("Got Response %s",tr.output2string()));
		seq_item_port.item_done();
	end //}

endtask: run_phase
