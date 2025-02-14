// Code your design here
module FIFO_memory(clk,
    reset,
    din,
    read,
    write,
    dout,
    empty,
    full,
    ale,
    alf
   ); 


parameter DATA_WIDTH=8;
parameter ADDR_WIDTH=4;

input clk; 
input reset; 
input [DATA_WIDTH-1:0]din;    
input read; 
input write; 


output [DATA_WIDTH-1:0]dout; 
output empty;      
output full; 
output ale; //almost empty
output alf; // almost full

parameter DEPTH=ADDR_WIDTH, MAX_COUNT=(1<<ADDR_WIDTH); 

/// parameter for almost full and almost empty conditions
parameter alf_value=14;
parameter ale_value=2;

//DEPTH is number of bits, 3 bits thus 2^3=8 memory locations and MAX_COUNT is the last memory location. 

reg [DATA_WIDTH-1:0]dout; 
reg empty; 
reg full;

/*head is write_pointer and tail is read_pointer*/ 
reg [(DEPTH-1):0]tail;     
// tail(3bits) defines memory pointer location for reading instructions(000 or 001....111) 
reg [(DEPTH-1):0]head;     
// head(3bits) defines memory pointer location for writing instructions(000 or 001....111) 

reg [(DEPTH):0]count;     
// 3 bits count register[000(0),001(1),010(2),....,111(7)] 
reg [DATA_WIDTH-1:0]fifo_mem[0:MAX_COUNT-1];  
// fifo memory is having DATA_WIDTH bits data and MAX_COUNT memory locations 
initial begin
$display("MAX_COUNT = %d",MAX_COUNT);
end
reg sr_read_write_empty;            // 1 bit register flag 


///////////////////////////////////////////////////////////////

assign alf=(count>=alf_value)?1'b1:1'b0;
assign ale=(count<=ale_value)?1'b1:1'b0;

///////// WHEN BOTH READING AND WRITING BUT FIFO IS EMPTY //////// 

always @(posedge clk) 
begin 
if(reset==1) 
//reset is pressed                                                             
 sr_read_write_empty <= 0; 
else if(read==1 && empty==1 && write==1)     
//when fifo is empty and read & write both 1 
 sr_read_write_empty <= 1; 
else 
 sr_read_write_empty <= 0; 
end 

//////////////////////// COUNTER OPERATION /////////////////////// 

always @(posedge clk) 
begin 
if(reset==1) 
//when reset, the fifo is made empty thus count is set to zero 
 count <= 3'b000;         
else 
 begin 
     case({read,write}) 
     //CASE-1:when not reading or writing     
         2'b00:    count <= count;                 
                 //count remains same 
     //CASE-2:when writing only 
         2'b01:    if(count!=MAX_COUNT)             
                     count <= count+1; 
                     //count increases 
     //CASE-3:when reading only                             
         2'b10:    if(count!=3'b000)                 
                     count <= count-1;                             
                    //count decreases 
     //CASE-4 
         2'b11:    if(sr_read_write_empty==1)     
                     count <= count+1; 
//(if) fifo is empty => only write, thus count increases             
                 else 
                     count <= count; 
//(else) both read and write takes place, thus no change                                             
     //DEFAULT CASE             
         default: count <= count; 
     endcase 
end 
end 
////////////////////// EMPTY AND FULL ALERT ///////////////////// 
// Memory empty signal 
always @(count) 
begin 
if(count==3'b000) 
 empty <= 1; 
else 
 empty <= 0; 
end 

// Memory full signal 
always @(count) 
begin 
if(count==MAX_COUNT) 
 full <= 1; 
else 
 full <= 0; 
end 
///////////// READ AND WRITE POINTER MEMORY LOCATION ///////////// 

// Write operation memory pointer 

always @(posedge clk) 
begin 
if(reset==1) 
//head moved to zero location (fifo is made empty) 
 head <= 3'b000;     
else 
 begin 
     if(write==1 && full==0)     
     //writing when memory is NOT FULL 
         head <= head+1; 
end 
end 

// Read operation memory pointer 
always @(posedge clk) 
begin 
 if(reset==1) 
 //tail moved to zero location (fifo is made empty) 
     tail <= 3'b000;     
 else 
     begin 
         if(read==1 && empty==0)     
         //reading when memory is NOT ZERO 
             tail <= tail+1; 
     end 
end 

//////////////////// READ AND WRITE OPERATION //////////////////// 

// Write operation 
always @(posedge clk) 
//IT CAN WRITE WHEN RESET IS USED AS FULL==0     
begin 
if(write==1 && full==0) 
//writing when memory is NOT FULL 
 fifo_mem[head] <= din; 
else                                     
//when NOT WRITING 
 fifo_mem[head] <= fifo_mem[head]; 
end 
// Read operation 

always @(posedge clk) 
begin 
if(reset==1)                       
//reset implies output is zero 
 dout <= 0; 
else if(read==1 && empty==0)     
//reading data when memory is NOT EMPTY 
 dout <= fifo_mem[tail]; 
else 
//no change 
 dout <= dout;  
end 
endmodule 