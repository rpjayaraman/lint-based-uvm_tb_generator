//(0) Create a class extending from uvm_sequence_item
//(1) Register class with Factory
//(2) Declare transaction varaiable
//(3) Construct the created class with new()
//(4) Add constraints [if any]
class apb_ram_seq_item extends uvm_sequence_item;

`uvm_object_utils(apb_ram_seq_item)

    rand bit presetn;
    rand bit psel;
    rand bit penable;
    rand bit pwrite;
    rand bit [31:0] paddr;
    rand bit [31:0] pwdata;
    bit [31:0] prdata;
    bit pready;
    bit pslverr;

extern function new( string name = "apb_ram_seq_item");
//extern constraint WRITE_YOUR_OWN_CONSTRAINT;
extern function string input2string();
extern function string output2string();
extern function string convert2string();

endclass //apb_ram_seq_item

function apb_ram_seq_item::new( string name = "apb_ram_seq_item");
 super.new( name );
endfunction : new

//constraint apb_ram_seq_item::WRITE_YOUR_OWN_CONSTRAINT{ a!= b; };

function string apb_ram_seq_item::input2string();
 return $sformatf("psel=%0h,penable=%0h,pwrite=%0h,paddr=%0h,pwdata=%0h",psel,penable,pwrite,paddr,pwdata);
endfunction : input2string

function string apb_ram_seq_item::output2string();
 return $sformatf(" prdata=%0h, pready=%0h, pslverr=%0h", prdata, pready, pslverr);
endfunction : output2string

function string apb_ram_seq_item::convert2string();
 return ({input2string(), " ", output2string()});
endfunction : convert2string