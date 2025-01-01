# lint-based-uvm_tb_generator
This python based tb_creator script uses pyslang module to parse design file and collects input,output and parameter information. Based on the data, the tb_creator script will generate full functional UVM based testbench except driver/monitor/scoreboard logic. 

#Steps to be followed:
1. Clone the repo
2. Import module such as pyslang, re, logging, tabulate
3. Provide the path to your dut top file
4. make run
5. Now you will have full functional UVM testbench inside tb/
6. Add driver/monitor/scorboard logic in the generated file.

currently this version supports dut file which uses port declaration. Next version will support Header declaration. 
please refer test_module.v for sample DUT.

EDA link to the generated testbench: https://www.edaplayground.com/x/hpt2
