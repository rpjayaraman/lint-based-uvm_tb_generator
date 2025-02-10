`define MON_VIF vif.MONITOR.monitor_cb
class FIFO_memory_monitor extends uvm_monitor;

uvm_analysis_port#(FIFO_memory_seq_item) mon_aport;
FIFO_memory_seq_item rx;

`uvm_component_utils(FIFO_memory_monitor)

virtual FIFO_memory_interface vif;

extern function new( string name = "FIFO_memory_monitor",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);

endclass //FIFO_memory_monitor

function FIFO_memory_monitor::new(string name,uvm_component parent);
	super.new(name,parent);
	mon_aport=new("mon_aport", this);
endfunction : new

function void FIFO_memory_monitor::build_phase(uvm_phase phase);
 super.build_phase(phase);

 `uvm_info(get_type_name(),"In Build Phase ...",UVM_NONE)	if(!uvm_config_db#(virtual FIFO_memory_interface)::get(this, "", "vif", vif))
		begin
		`uvm_fatal("NO_MON_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
		end
endfunction : build_phase

task FIFO_memory_monitor::run_phase(uvm_phase phase);
	super.run_phase(phase);

 `uvm_info(get_type_name(),"In Run Phase ...",UVM_NONE)

  rx=FIFO_memory_seq_item::type_id::create("rx",this);
	forever begin //{
		//Monitor Logic
      uvm_report_info(get_type_name(), $sformatf("Printing Transaction %s",rx.convert2string()));
      @(posedge vif.clk);
      if(vif.reset) begin
        rx.reset = vif.reset;
        mon_aport.write(rx);
      end
      else if (!vif.reset && vif.write && !vif.full) begin //WRITE
        @(posedge vif.clk);
      	rx.reset = 0;
        rx.din = vif.din;
        rx.write = vif.write;
        rx.read = 0;
        rx.dout = vif.dout;
        rx.alf = vif.alf;
        rx.full = vif.full;
        rx.ale = vif.ale;
        rx.empty = vif.empty;
        mon_aport.write(rx);
        `uvm_info(get_type_name(), "Sending WRITE trans to analysis port", UVM_LOW)
      
      end
      
      else if (!vif.reset && vif.read && !vif.empty) begin //WRITE
        @(posedge vif.clk);
      	rx.reset = 0;
        rx.din = vif.din;
        rx.write = 0;
        rx.read = vif.read;
        rx.dout = vif.dout;
        rx.alf = vif.alf;
        rx.full = vif.full;
        rx.ale = vif.ale;
        rx.empty = vif.empty;
        mon_aport.write(rx);
        `uvm_info(get_type_name(), "Sending read  trans to analysis port", UVM_LOW)
      
      end
      
      
		//mon_aport.write(tr);
	end //}

endtask: run_phase
