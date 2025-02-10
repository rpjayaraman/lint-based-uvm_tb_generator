//(0) Create a class extending from uvm_sequence_item
//(1) Register class with Factory
//(2) Declare transaction varaiable
//(3) Construct the created class with new()
//(4) Add constraints [if any]
class FIFO_memory_seq_item extends uvm_sequence_item;

`uvm_object_utils(FIFO_memory_seq_item)
 
parameter DATA_WIDTH=8;
parameter ADDR_WIDTH=4; // almost full
parameter DEPTH=ADDR_WIDTH, MAX_COUNT=(1<<ADDR_WIDTH); 
/// parameter for almost full and almost empty conditions
parameter alf_value=14;
parameter ale_value=2; 
rand bit reset; 
rand bit [DATA_WIDTH-1:0]din;    
rand bit read; 
rand bit write; 
bit [DATA_WIDTH-1:0]dout; 
bit empty;      
bit full; 
bit ale; //almost empty
bit alf;

extern function new( string name = "FIFO_memory_seq_item");
//extern constraint WRITE_YOUR_OWN_CONSTRAINT;
extern function string input2string();
extern function string output2string();
extern function string convert2string();

endclass //FIFO_memory_seq_item

function FIFO_memory_seq_item::new( string name = "FIFO_memory_seq_item");
 super.new( name );
endfunction : new

//constraint FIFO_memory_seq_item::WRITE_YOUR_OWN_CONSTRAINT{ a!= b; };

function string FIFO_memory_seq_item::input2string();
 return $sformatf("din=%0h,read=%0h,write=%0h",din,read,write);
endfunction : input2string

function string FIFO_memory_seq_item::output2string();
 return $sformatf("dout=%0h, empty=%0h, full=%0h, ale=%0h, alf=%0h",dout, empty, full, ale, alf);
endfunction : output2string

function string FIFO_memory_seq_item::convert2string();
 return ({input2string(), " ", output2string()});
endfunction : convert2string