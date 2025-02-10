class apb_ram_scoreboard extends uvm_scoreboard;

virtual apb_ram_interface vif;
uvm_analysis_imp#(apb_ram_seq_item,apb_ram_scoreboard) sb_export;
apb_ram_seq_item recv_trans_q[$];
int mem [32];
  apb_ram_seq_item rx;

`uvm_component_utils(apb_ram_scoreboard)

extern function new( string name = "apb_ram_scoreboard",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);
extern virtual function void write(apb_ram_seq_item pkt);
endclass //apb_ram_scoreboard

function apb_ram_scoreboard::new(string name,uvm_component parent);
	super.new(name,parent);
	sb_export=new("sb_export", this);
  rx= apb_ram_seq_item::type_id::create("rx");
endfunction : new
  

function void apb_ram_scoreboard::build_phase(uvm_phase phase);
 super.build_phase(phase);

 `uvm_info(get_type_name(),"In Build Phase ...",UVM_NONE)

endfunction : build_phase

task apb_ram_scoreboard::run_phase(uvm_phase phase);
	//super.run_phase(phase);

 `uvm_info(get_type_name(),"In Run Phase ...",UVM_NONE)
forever begin
  wait(recv_trans_q.size()>0);
  if(recv_trans_q.size()>0) begin
    rx = recv_trans_q.pop_front();
    if(!rx.presetn) begin //reset 
      `uvm_info(get_type_name(), "SYS is in RESET state", UVM_LOW)      
    end
    else if (rx.presetn && rx.pwrite && rx.pready) begin //write
     mem[rx.paddr] = rx.pwdata; 
    end
    else if (rx.presetn && !rx.pwrite && rx.pready) begin //read
      
      if (mem[rx.paddr] == rx.prdata) 
        `uvm_warning(get_type_name(), $sformatf("addr:%d %d != %d",rx.paddr,mem[rx.paddr],rx.prdata  ), UVM_LOW)
      else
        `uvm_error(get_type_name(), $sformatf("addr:%d %d != %d",rx.paddr,mem[rx.paddr],rx.prdata  ))
    end

  end 

        end


endtask: run_phase

function void apb_ram_scoreboard::write(apb_ram_seq_item pkt);
	pkt.print();
  recv_trans_q.push_back(pkt);
endfunction : write
