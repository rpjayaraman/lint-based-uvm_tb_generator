`define MON_VIF vif.MONITOR.monitor_cb
class apb_ram_monitor extends uvm_monitor;

uvm_analysis_port#(apb_ram_seq_item) mon_aport;
apb_ram_seq_item tr;

`uvm_component_utils(apb_ram_monitor)

virtual apb_ram_interface vif;

extern function new( string name = "apb_ram_monitor",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);

endclass //apb_ram_monitor

function apb_ram_monitor::new(string name,uvm_component parent);
	super.new(name,parent);
	mon_aport=new("mon_aport", this);
endfunction : new

function void apb_ram_monitor::build_phase(uvm_phase phase);
 super.build_phase(phase);

 `uvm_info(get_type_name(),"In Build Phase ...",UVM_NONE)	if(!uvm_config_db#(virtual apb_ram_interface)::get(this, "", "vif", vif))
		begin
		`uvm_fatal("NO_MON_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
		end
endfunction : build_phase

task apb_ram_monitor::run_phase(uvm_phase phase);
	//super.run_phase(phase);

 `uvm_info(get_type_name(),"In Run Phase ...",UVM_NONE)

	tr=apb_ram_seq_item::type_id::create("tr",this);
	forever begin //{
      @(posedge vif.pclk);
		//Monitor Logic
      if(!vif.presetn) begin 
        tr.presetn = 0;
        mon_aport.write(tr);
      end //reset 
      else if (vif.presetn && vif.pwrite) begin
        //@(negedge vif.pready);
        tr.presetn = 1;
        tr.paddr = vif.paddr;
        tr.pwrite = vif.pwrite;
        tr.pwdata = vif.pwdata;
        tr.pslverr = vif.pslverr;
        tr.pready = vif.pready;

        mon_aport.write(tr);
      end //write
      else if (vif.presetn && !vif.pwrite) begin
        //@(posedge vif.pready);
                tr.presetn = 1;
        tr.paddr = vif.paddr;
        tr.pwrite = vif.pwrite;
        tr.prdata = vif.prdata;
        tr.pslverr = vif.pslverr;
        tr.pready = vif.pready;
                mon_aport.write(tr);

      end //write
		uvm_report_info(get_type_name(), $sformatf("Printing Transaction %s",tr.convert2string()));
	end //}

endtask: run_phase
