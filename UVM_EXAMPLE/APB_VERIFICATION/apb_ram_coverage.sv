class apb_ram_coverage extends uvm_subscriber#(apb_ram_seq_item);

`uvm_component_utils(apb_ram_coverage)
apb_ram_seq_item item;
uvm_analysis_imp#(apb_ram_seq_item,apb_ram_coverage) cov_export;
covergroup cg_apb_ram_coverage;

	option.per_instance = 1;
	option.name="Coverage for  apb_ram";
	option.comment="Add your comment";
	option.goal=100;

	cp_psel: coverpoint (item.psel)
	{
		option.auto_bin_max = 2;
	}
	cp_penable: coverpoint (item.penable)
	{
		option.auto_bin_max = 2;
	}
	cp_pwrite: coverpoint (item.pwrite)
	{
		option.auto_bin_max = 2;
	}
	cp_paddr: coverpoint (item.paddr)
	{
		option.auto_bin_max = 2;
	}
	cp_pwdata: coverpoint (item.pwdata)
	{
		option.auto_bin_max = 2;
	}

	cross_cp: cross cp_psel, cp_penable, cp_pwrite, cp_paddr, cp_pwdata;

endgroup: cg_apb_ram_coverage
extern function new( string name = "apb_ram_coverage",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);
extern virtual function void write(apb_ram_seq_item t);
extern function void report_phase(uvm_phase phase);

endclass //apb_ram_coverage

function apb_ram_coverage::new(string name,uvm_component parent);
	super.new(name,parent);
	cg_apb_ram_coverage=new();
endfunction : new

function void apb_ram_coverage::build_phase(uvm_phase phase);
 super.build_phase(phase);
	cov_export=new("cov_export", this);

 `uvm_info(get_type_name(),"In Build Phase ...",UVM_NONE)

endfunction : build_phase

function void apb_ram_coverage::connect_phase(uvm_phase phase);
	super.connect_phase(phase);

 `uvm_info(get_type_name(),"In Connect Phase ...",UVM_NONE)

endfunction: connect_phase

task apb_ram_coverage::run_phase(uvm_phase phase);
	super.run_phase(phase);

 `uvm_info(get_type_name(),"In Run Phase ...",UVM_NONE)

endtask: run_phase

function void apb_ram_coverage::write(apb_ram_seq_item t);
	item=t;
	cg_apb_ram_coverage.sample();
endfunction : write

function void apb_ram_coverage:: report_phase(uvm_phase phase);
	super.report_phase(phase);
	`uvm_info(get_full_name(),$sformatf("Coverage is %f",cg_apb_ram_coverage.get_coverage()),UVM_LOW);
endfunction: report_phase