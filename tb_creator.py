#Sample Result: https://www.edaplayground.com/x/hpt2
import pyslang
import argparse
import re
import logging
from tabulate import tabulate
import os
import shutil

port_list          = list()  #Store list of all Ports
input_list         = list()  #Store list of in Ports
input_declarators  = list()  #Stroe list of input declarators
output_list        = list()  #Store list of out Ports
output_declarators = list()  #Stroe list of output declarators
all_declarators    = list()  #Contains both input and output declarators
clk_rst_list       = list()  #Stroe list of output declarators
cr_list            = list()  #List with Clock and reset
only_clk           = list()  #List only with Clock signal
only_rst           = list()  #List Only with reset signal
ex_cr              = list()  #List without Clock and Reset 
param_list         = list()  #List of parameters available
cp_in_list         = list()
'''
Creating a "tb" folder to save the generated UVM testbench
'''
folder_name ="tb"
if not os.path.exists(folder_name):
  os.makedirs(folder_name)
elif os.path.exists(folder_name):
  shutil.rmtree(folder_name) #Remove if there is an existing folder/files
  os.makedirs(folder_name)

"""
Collects port data from the Verilog design.

This function logs debug information about each port found in the design,
including direction, declarators, and data width. It then appends the port
data to the port_list and categorizes it as input or output.

Args:
  None

Returns:
  None
"""
def collect_port_data():
  logging.debug("Port found in the design: " + str(m_i)) #List of ports used in the verilog file Eg: input [DATA_WIDTH-1:0]din;
  logging.debug("Port Direction          : " + str(m_i.header.direction))#Eg: input
  logging.debug(m_i.header.direction)
  logging.debug("Port Declarators        : " + str(m_i.declarators)) #Eg: din
  logging.debug("Port Data width         : " + str(m_i.header.dataType)) #[DATA_WIDTH-1:0]
  logging.debug(dir(m_i.kind)) 
  logging.debug(dir(m_i.kind.name.format))
  logging.debug(m_i)
  port_list.append(m_i)
  if(m_i.header.direction.kind.name == 'InputKeyword'):
    input_list.append(str(m_i))
    input_declarators.append(str(m_i.declarators))
    all_declarators.append(str(m_i.declarators))
  elif(m_i.header.direction.kind.name == 'OutputKeyword'):
    output_list.append(m_i)
    output_declarators.append(str(m_i.declarators))
    all_declarators.append(str(m_i.declarators))

def collect_param_data():
  #Print the parameters
  logging.debug(m_i)
  param_list.append(str(m_i))

def pyslint_argparse():
  """
  Parses command-line arguments using argparse.

  This function creates an ArgumentParser, adds a required test argument,
  and returns the parsed arguments.

  Args:
    None

  Returns:
    args (argparse.Namespace): Parsed command-line arguments
  """
  # Create the parser
  parser = argparse.ArgumentParser()
  # Add an argument
  parser.add_argument('-t', '--test', type=str, required=True)
  # Parse the argument
  args = parser.parse_args()
  return args

def create_interface(port_list,dut_name):
  """
  Creates a SystemVerilog interface file based on the provided port data.

  This function iterates through the port list, replaces 'input' and 'output'
  with 'logic', and writes the modified port data to a file.

  Args:
    port_list (list): List of port data objects
    dut_name (str): Name of the Design Under Test (DUT)

  Returns:
    None
  """
  l_intf_file_name=f"{dut_name.strip()}_interface.sv"
  global interface_name
  interface_name =f"{dut_name.strip()}_interface"
  l_intf_path =os.path.join(folder_name,l_intf_file_name)
  for j in input_declarators:
    if re.search(r".*.(clk|reset|rst|clock).*",str(j), re.IGNORECASE):
      cr_list.append(j)
    if re.search(r".*.(clk|clock).*",str(j) , re.IGNORECASE):
      only_clk.append(j)
  ports = ", ".join(cr_list)
  with open(l_intf_path,"a+") as file:
    file.write("\ninterface "+interface_name+" (input logic "+ports+");\n")
    if(param_flag):
      for parameter_i in param_list:
        file.write(parameter_i)
    for l_ports in port_list:
      if l_ports not in cr_list:
        tb_interface_input = str(l_ports).replace("input","logic").replace("output","logic");
        if not re.search(r".*.(clk|reset|rst|clock).*",str(tb_interface_input), re.IGNORECASE):
          file.write(tb_interface_input)
    file.write("\n//--------------------------------------")
    file.write("\n//Driver Clocking Block")
    file.write("\n//--------------------------------------")
    single_clk = None
    for clk_i in only_clk:    
      single_clk = clk_i.strip()
      file.write("\nclocking driver_cb @(posedge "+single_clk+");")
      
    
    file.write("\n\tdefault input #1 output #1;\n")
    out_drv_ports = ""
    in_drv_ports = ""
    for drv_ports in input_declarators:
      if drv_ports not in cr_list:
        in_drv_ports += f"\toutput {drv_ports};\n"
    for drv_out_ports in output_declarators:
      out_drv_ports += f"\tinput {drv_out_ports};\n"
    file.write(in_drv_ports)
    file.write(out_drv_ports)
    file.write("\nendclocking //driver_cb")

    file.write("\n//--------------------------------------")
    file.write("\n//Monitor Clocking Block")
    file.write("\n//--------------------------------------")
    file.write("\nclocking monitor_cb @(posedge "+single_clk+");")
    file.write("\ndefault input #1 output #1;\n")
    all_mon_ports = ""
    for mon_ports in all_declarators:
      if mon_ports not in cr_list:
        all_mon_ports+= f"\tinput {mon_ports};\n"
    file.write(all_mon_ports)
    file.write("\nendclocking //monitor_cb")

    file.write("\n//--------------------------------------")
    file.write("\n//Driver Modport")
    file.write("\n//--------------------------------------")
    file.write("\nmodport DRIVER  (clocking driver_cb,input "+ports+");\n")
    file.write("\n//--------------------------------------")
    file.write("\n//Monitor Modport")
    file.write("\n//--------------------------------------")
    file.write("\nmodport MONITOR (clocking monitor_cb,input "+ports+");\n")

    file.write("\nendinterface //" +interface_name)
  logging.info(f"Successfully Created -> {l_intf_path}")
#End of create_interface

def create_seqitem(port_list,dut_name):
  #http://www.sunburst-design.com/papers/CummingsSNUG2014SV_UVM_Transactions.pdf
  #Defining the excluded signal list
  excluded_signals = ["clk", "reset", "clock", "rst"]
  l_seq_file_name=f"{dut_name.strip()}_seq_item.sv"
  global seq_item_name #TODO Move this outside of the function
  seq_item_name =f"{dut_name.strip()}_seq_item"
  l_seq_path =os.path.join(folder_name,l_seq_file_name)
  with open(l_seq_path,"a+") as file:
    file.write("//(0) Create a class extending from uvm_sequence_item\n")
    file.write("//(1) Register class with Factory\n")
    file.write("//(2) Declare transaction varaiable\n")
    file.write("//(3) Construct the created class with new()\n") 
    file.write("//(4) Add constraints [if any]\n")
    file.write("class "+ seq_item_name + " extends uvm_sequence_item;\n")
    file.write("\n`uvm_object_utils("+seq_item_name+")\n")
    if(param_flag):
      for parameter_j in param_list:
        file.write(parameter_j)
    for l_ports in port_list:
      if any(excluded_signal.lower() in str(l_ports).lower() for excluded_signal in excluded_signals):
        logging.debug(f"Excluding signal: {l_ports}")
        continue
      tb_seq_input = str(l_ports).replace("input","rand bit").replace("output","bit");
      file.write(tb_seq_input)

    file.write("\n")
    file.write("\nextern function new( string name = \""+seq_item_name +"\");\n")
    file.write("//extern constraint WRITE_YOUR_OWN_CONSTRAINT;")    
    file.write("\nextern function string input2string();")
    file.write("\nextern function string output2string();")
    file.write("\nextern function string convert2string();\n")
    file.write("\nendclass //" +seq_item_name)

    file.write("\n")
    file.write("\nfunction "+seq_item_name+"::new(string name);")
    file.write("\n super.new( name );")
    file.write("\nendfunction : new")
    file.write("\n")
    file.write("\n//constraint "+ seq_item_name+"::WRITE_YOUR_OWN_CONSTRAINT{ a!= b; };\n")
    #Input to String
    file.write("\nfunction string "+seq_item_name+"::input2string();\n")
    in_first_half = ""
    for seq_i_ports in input_declarators:
      if seq_i_ports not in cr_list:
        ex_cr.append(seq_i_ports.strip())
    in_first_half='=%0h,'.join(ex_cr)
    in_first_half += "=%0h"
    second_half =','.join(ex_cr)
    file.write(" return $sformatf(\""+in_first_half+"\","+second_half+");")
    file.write("\nendfunction : input2string\n")
    #Output to String
    file.write("\nfunction string "+seq_item_name+"::output2string();\n")
    out_first_half='=%0h,'.join(output_declarators) 
    out_first_half += "=%0h"
    out_second_half =','.join(output_declarators)
    file.write(" return $sformatf(\""+out_first_half+"\","+out_second_half+");")
    file.write("\nendfunction : output2string\n")
    #Convert to string
    file.write("\nfunction string "+seq_item_name+"::convert2string();\n")
    file.write(" return ({input2string(), \" \", output2string()});")
    file.write("\nendfunction : convert2string")
  logging.info(f"Successfully Created -> {l_seq_path}")

#End of create_seqitem

def create_sequence(dut_name):
  l_sequence_file_name=f"{dut_name.strip()}_base_sequence.sv"
  global seq_name
  seq_name=f"{dut_name.strip()}_base_sequence"
  l_sequence_path =os.path.join(folder_name,l_sequence_file_name)
  with open(l_sequence_path,"a+") as file:
    file.write("class "+ seq_name+ " extends uvm_sequence#("+seq_item_name+");\n")
    file.write("\n`uvm_object_utils("+seq_name+")\n")
    file.write(seq_item_name+" req;\n")
    file.write("\nextern function new( string name = \""+seq_name+"\");")
    file.write("\nextern task body();\n")
    file.write("\nendclass //" +seq_name)
    file.write("\n")
    file.write("\nfunction "+seq_name+"::new(string name);")
    file.write("\n super.new( name );")
    file.write("\nendfunction : new\n")
    file.write("\ntask "+seq_name+"::body();\n")
    file.write("`uvm_info(get_type_name(), $sformatf(\"Start of " +seq_name + " Sequence\"), UVM_LOW)")
    file.write("\nreq = "+seq_item_name+":: type_id :: create(\"req\");\n")
    file.write("repeat(5) begin //{\n")
    file.write("\t`uvm_do(req)\n")
    file.write("end //}\n")
    file.write("`uvm_info(get_type_name(), $sformatf(\"End of " +seq_name + " Sequence\"), UVM_LOW)\n")
    file.write("\nendtask //"+seq_name)

  logging.info(f"Successfully Created -> {l_sequence_path}")

#End of create_sequence


def create_seqr(dut_name):
  seqr_file_name=f"{dut_name.strip()}_sequencer.sv"
  global seqr_name
  seqr_name=f"{dut_name.strip()}_sequencer"
  l_seqr_path =os.path.join(folder_name,seqr_file_name)
  with open(l_seqr_path,"a+") as file:
    file.write("class "+ seqr_name + " extends uvm_sequencer#("+seq_item_name+");\n")
    file.write("\n`uvm_component_utils("+seqr_name+")\n")
    file.write("\nextern function new( string name = \""+seqr_name+"\",uvm_component parent=null);\n")
    file.write("extern function void build_phase(uvm_phase phase);\n")
    file.write("\nendclass //" +seqr_name)
    file.write("\n")
    file.write("\nfunction "+seqr_name+"::new(string name,uvm_component parent);")
    file.write("\n super.new(name,parent);")
    file.write("\nendfunction : new\n")
    file.write("\nfunction void "+seqr_name+"::build_phase(uvm_phase phase);")
    file.write("\n super.build_phase(phase);")
    file.write("\n `uvm_info(get_type_name(),\"In Build Phase ...\",UVM_NONE)")
    file.write("\nendfunction : build_phase\n")
  logging.info(f"Successfully Created -> {l_seqr_path}")
#End of create_seqr

def create_driver(dut_name):
  driver_file_name=f"{dut_name.strip()}_driver.sv"
  global driver_name
  driver_name=f"{dut_name.strip()}_driver"
  l_driver_path =os.path.join(folder_name,driver_file_name)
  with open(l_driver_path,"a+") as file:
    file.write("`define DRIV_VIF vif.DRIVER.driver_cb\n")
    file.write("\nclass "+ driver_name+ " extends uvm_driver#("+seq_item_name+");\n")
    file.write("\n`uvm_component_utils("+driver_name+")\n")
    file.write("\nvirtual "+interface_name+" vif;\n")
    file.write("\nextern function new( string name = \""+driver_name+"\",uvm_component parent);\n") 
    file.write("extern function void build_phase(uvm_phase phase);\n")
    file.write("extern virtual task run_phase(uvm_phase phase);\n")
    file.write("\nendclass //" +driver_name)
    file.write("\n")
    file.write("\nfunction "+driver_name+"::new(string name,uvm_component parent);")
    file.write("\n super.new(name,parent);")
    file.write("\nendfunction : new\n")
    file.write("\nfunction void "+driver_name+"::build_phase(uvm_phase phase);")
    file.write("\n super.build_phase(phase);\n")
    file.write("\n `uvm_info(get_type_name(),\"In Build Phase ...\",UVM_NONE)\n")
    file.write("\tif(!uvm_config_db#(virtual "+interface_name+")::get(this, \"\", \"vif\", vif))\n")
    file.write("\t\tbegin\n")
    file.write("\t\t`uvm_fatal(\"NO_VIF\",{\"virtual interface must be set for: \",get_full_name(),\".vif\"});\n")
    file.write("\t\tend")
    file.write("\nendfunction : build_phase\n")
    file.write("\ntask "+driver_name+"::run_phase(uvm_phase phase);\n")
    file.write("\tsuper.run_phase(phase);\n")
    file.write("\n `uvm_info(get_type_name(),\"In Run Phase ...\",UVM_NONE)\n")
    file.write("\tforever begin //{\n")
    file.write("\t\t"+seq_item_name +" tr;\n")
    file.write("\t\tseq_item_port.get_next_item(tr);\n")
    file.write("\t\tuvm_report_info(get_type_name(), $sformatf(\"Got Input Transaction %s\",tr.input2string()));\n")
    file.write("\t\t//Driver Logic\n")
    file.write("\t\tuvm_report_info(get_type_name(), $sformatf(\"Got Response %s\",tr.output2string()));\n")
    file.write("\t\tseq_item_port.item_done(tr);\n")
    file.write("\tend //}\n")
    file.write("\nendtask: run_phase\n")

  logging.info(f"Successfully Created -> {l_driver_path}")

#End of create_driver

def create_monitor(dut_name):
  monitor_file_name=f"{dut_name.strip()}_monitor.sv"
  global monitor_name
  monitor_name=f"{dut_name.strip()}_monitor"
  l_monitor_path =os.path.join(folder_name,monitor_file_name)
  with open(l_monitor_path,"a+") as file:
    file.write("`define MON_VIF vif.MONITOR.monitor_cb")
    file.write("\nclass "+ monitor_name+ " extends uvm_monitor;\n")
    file.write("\nuvm_analysis_port#("+seq_item_name+") mon_aport;")
    file.write("\n"+seq_item_name +" tr;\n")
    file.write("\n`uvm_component_utils("+monitor_name+")\n")
    file.write("\nvirtual "+interface_name+" vif;\n")
    file.write("\nextern function new( string name = \""+monitor_name+"\",uvm_component parent);\n") 
    file.write("extern function void build_phase(uvm_phase phase);\n")
    file.write("extern virtual task run_phase(uvm_phase phase);\n")
    file.write("\nendclass //" +monitor_name)
    file.write("\n")
    file.write("\nfunction "+monitor_name+"::new(string name,uvm_component parent);\n")
    file.write("\tsuper.new(name,parent);\n")
    file.write("\tmon_aport=new(\"mon_aport\", this);")
    file.write("\nendfunction : new\n")
    file.write("\nfunction void "+monitor_name+"::build_phase(uvm_phase phase);")
    file.write("\n super.build_phase(phase);\n")
    file.write("\n `uvm_info(get_type_name(),\"In Build Phase ...\",UVM_NONE)")
    file.write("\tif(!uvm_config_db#(virtual "+interface_name+")::get(this, \"\", \"vif\", vif))\n")
    file.write("\t\tbegin\n")
    file.write("\t\t`uvm_fatal(\"NO_MON_VIF\",{\"virtual interface must be set for: \",get_full_name(),\".vif\"});\n")
    file.write("\t\tend")
    file.write("\nendfunction : build_phase\n")
    file.write("\ntask "+monitor_name+"::run_phase(uvm_phase phase);\n")
    file.write("\tsuper.run_phase(phase);\n")
    file.write("\n `uvm_info(get_type_name(),\"In Run Phase ...\",UVM_NONE)\n")
    file.write("\n\ttr="+seq_item_name+"::type_id::create(\"tr\",this);\n")
    file.write("\t//forever begin //{\n")
    file.write("\t\t//Monitor Logic\n")
    file.write("\t\tuvm_report_info(get_type_name(), $sformatf(\"Printing Transaction %s\",tr.convert2string()));\n")
    file.write("\t\t//mon_aport.write(tr);\n")
    file.write("\t//end //}\n")
    file.write("\nendtask: run_phase\n")

  logging.info(f"Successfully Created -> {l_monitor_path}")

#End of create_monitor
def create_agent(dut_name):
  agent_file_name=f"{dut_name.strip()}_agent.sv"
  global agent_name
  agent_name=f"{dut_name.strip()}_agent"
  l_agent_path =os.path.join(folder_name,agent_file_name)
  with open(l_agent_path,"a+") as file:
    file.write("class "+ agent_name+ " extends uvm_agent;\n")
    file.write("\n`uvm_component_utils("+agent_name+")\n")
    file.write(seqr_name+" u_sqr;\n")
    file.write(driver_name+" u_driver;\n")
    file.write(monitor_name+" u_monitor;\n")
    file.write("\nvirtual "+interface_name+" vif;\n")
    file.write("\nextern function new( string name = \""+agent_name+"\",uvm_component parent);\n")
    file.write("extern function void build_phase(uvm_phase phase);\n")
    file.write("extern function void connect_phase(uvm_phase phase);\n")
    file.write("\nendclass //" +agent_name)
    file.write("\n")
    file.write("\nfunction "+agent_name+"::new(string name,uvm_component parent);\n")
    file.write("\tsuper.new(name,parent);\n")
    file.write("endfunction : new\n")
    file.write("\nfunction void "+agent_name+"::build_phase(uvm_phase phase);")
    file.write("\n super.build_phase(phase);\n")
    file.write("\n `uvm_info(get_type_name(),\"In Build Phase ...\",UVM_NONE)\n")
    file.write("\tu_sqr     ="+seqr_name+"   ::type_id::create(\"u_sqr\",this);\n")
    file.write("\tu_driver  ="+driver_name+" ::type_id::create(\"u_driver\",this);\n")
    file.write("\tu_monitor ="+monitor_name+"::type_id::create(\"u_monitor\",this);")
    file.write("\nendfunction : build_phase\n")
    file.write("\nfunction void "+agent_name+"::connect_phase(uvm_phase phase);")
    file.write("\n super.connect_phase(phase);")
    file.write("\n `uvm_info(get_type_name(),\"In Connect Phase ...\",UVM_NONE)\n")
    file.write("\n u_driver.seq_item_port.connect(u_sqr.seq_item_export);")
    file.write("\n `uvm_info(get_type_name(),\"CONNECT_PHASE:Connected Driver and Sequencer\",UVM_NONE)")
    file.write("\nendfunction : connect_phase\n")
  logging.info(f"Successfully Created -> {l_agent_path}")


#End of create_agent

def create_sb(dut_name):
  sb_file_name=f"{dut_name.strip()}_scoreboard.sv"
  global sb_name
  sb_name=f"{dut_name.strip()}_scoreboard"
  l_sb_path =os.path.join(folder_name,sb_file_name)
  with open(l_sb_path,"a+") as file:
    file.write("class "+ sb_name+ " extends uvm_scoreboard;\n")
    file.write("\nvirtual "+interface_name+" vif;\n")
    file.write("uvm_analysis_imp#("+seq_item_name+","+sb_name+") sb_export;\n")
    file.write("\n`uvm_component_utils("+sb_name+")\n")
    file.write("\nextern function new( string name = \""+sb_name+"\",uvm_component parent);\n")
    file.write("extern function void build_phase(uvm_phase phase);\n")
    file.write("extern virtual task run_phase(uvm_phase phase);\n")
    file.write("extern virtual function void write("+seq_item_name+" pkt);")
    file.write("\nendclass //" +sb_name)
    file.write("\n")
    file.write("\nfunction "+sb_name+"::new(string name,uvm_component parent);\n")
    file.write("\tsuper.new(name,parent);\n")
    file.write("\tsb_export=new(\"sb_export\", this);\n")
    file.write("endfunction : new\n")
    file.write("\nfunction void "+sb_name+"::build_phase(uvm_phase phase);")
    file.write("\n super.build_phase(phase);\n")
    file.write("\n `uvm_info(get_type_name(),\"In Build Phase ...\",UVM_NONE)\n")
    file.write("\nendfunction : build_phase\n")
    file.write("\ntask "+sb_name+"::run_phase(uvm_phase phase);\n")
    file.write("\tsuper.run_phase(phase);\n")
    file.write("\n `uvm_info(get_type_name(),\"In Run Phase ...\",UVM_NONE)\n")
    file.write("\nendtask: run_phase\n")
    file.write("\nfunction void "+sb_name+"::write("+seq_item_name+" pkt);\n")
    file.write("\tpkt.print();\n")
    file.write("endfunction : write\n")


  logging.info(f"Successfully Created -> {l_sb_path}")
#End of create_sb

def create_coverage(dut_name):
  cov_file_name=f"{dut_name.strip()}_coverage.sv"
  global cov_name
  cov_name=f"{dut_name.strip()}_coverage"
  l_cov_path =os.path.join(folder_name,cov_file_name)
  with open(l_cov_path,"a+") as file:
    file.write("class "+ cov_name+ " extends uvm_subscriber#("+seq_item_name+");\n")
    file.write("\n`uvm_component_utils("+cov_name+")\n")
    file.write(seq_item_name+" item;\n")
    file.write("uvm_analysis_imp#("+seq_item_name+","+cov_name+") cov_export;\n")
    file.write("covergroup cg_"+cov_name+";\n")
    file.write("\n\toption.per_instance = 1;")
    file.write("\n\toption.name=\"Coverage for "+dut_name+"\";")
    file.write("\n\toption.comment=\"Add your comment\";")
    file.write("\n\toption.goal=100;\n")
    file.write("\n")
    for cp_iter in ex_cr:
      file.write("\tcp_"+cp_iter+": coverpoint (item."+cp_iter+")\n")
      file.write("\t{\n")
      file.write("\t\toption.auto_bin_max = 2;")
      file.write("\n\t}\n")
      cp_in_list.append("cp_"+cp_iter)
    cross_cp= ", ".join(cp_in_list)
    file.write("\n\tcross_cp: cross "+cross_cp+";\n")
    file.write("\nendgroup: cg_"+cov_name)
    file.write("\nextern function new( string name = \""+cov_name+"\",uvm_component parent);\n")
    file.write("extern function void build_phase(uvm_phase phase);\n")
    file.write("extern function void connect_phase(uvm_phase phase);\n")
    file.write("extern virtual task run_phase(uvm_phase phase);\n")
    file.write("extern virtual function void write("+seq_item_name+" t);\n")
    file.write("extern function void report_phase(uvm_phase phase);\n")
    file.write("\nendclass //" +cov_name)
    file.write("\n")
    file.write("\nfunction "+cov_name+"::new(string name,uvm_component parent);\n")
    file.write("\tsuper.new(name,parent);\n")
    file.write("\tcg_"+cov_name+"=new();\n")
    file.write("endfunction : new\n")
    file.write("\nfunction void "+cov_name+"::build_phase(uvm_phase phase);")
    file.write("\n super.build_phase(phase);\n")
    file.write("\tcov_export=new(\"cov_export\", this);\n")
    file.write("\n `uvm_info(get_type_name(),\"In Build Phase ...\",UVM_NONE)\n")
    file.write("\nendfunction : build_phase\n")
    file.write("\nfunction void "+cov_name+"::connect_phase(uvm_phase phase);\n")
    file.write("\tsuper.connect_phase(phase);\n")
    file.write("\n `uvm_info(get_type_name(),\"In Connect Phase ...\",UVM_NONE)\n")
    file.write("\nendfunction: connect_phase\n")
    file.write("\ntask "+cov_name+"::run_phase(uvm_phase phase);\n")
    file.write("\tsuper.run_phase(phase);\n")
    file.write("\n `uvm_info(get_type_name(),\"In Run Phase ...\",UVM_NONE)\n")
    file.write("\nendtask: run_phase\n")
    file.write("\nfunction void "+cov_name+"::write("+seq_item_name+" t);\n")
    file.write("\titem=t;\n")
    file.write("\tcg_"+cov_name+".sample();\n")
    file.write("endfunction : write\n")
    file.write("\nfunction void "+cov_name+":: report_phase(uvm_phase phase);\n")
    file.write("\tsuper.report_phase(phase);\n")
    file.write("\t`uvm_info(get_full_name(),$sformatf(\"Coverage is %f\",cg_"+cov_name+".get_coverage()),UVM_LOW);\n")
    file.write("endfunction: report_phase")


  logging.info(f"Successfully Created -> {l_cov_path}")

#End of create_cov
def create_env(dut_name):
  env_file_name=f"{dut_name.strip()}_env.sv"
  global env_name
  env_name=f"{dut_name.strip()}_env"
  l_env_path =os.path.join(folder_name,env_file_name)
  with open(l_env_path,"a+") as file:
    file.write("class "+ env_name+ " extends uvm_env;\n")
    file.write("\n`uvm_component_utils("+env_name+")\n")
    file.write(agent_name+" u_agent;\n")
    file.write(sb_name+" u_sb;\n")
    file.write(cov_name+" u_cov;\n")
    file.write("\nextern function new( string name = \""+env_name+"\",uvm_component parent);\n")
    file.write("extern function void build_phase(uvm_phase phase);\n")
    file.write("extern function void connect_phase(uvm_phase phase);\n")
    file.write("\nendclass //" +env_name)
    file.write("\n")
    file.write("\nfunction "+env_name+"::new(string name,uvm_component parent);\n")
    file.write("\tsuper.new(name,parent);\n")
    file.write("endfunction : new\n")
    file.write("\nfunction void "+env_name+"::build_phase(uvm_phase phase);")
    file.write("\n super.build_phase(phase);\n")
    file.write("\n `uvm_info(get_type_name(),\"In Build Phase ...\",UVM_NONE)\n")
    file.write("\tu_agent="+agent_name+"::type_id::create(\"u_agent\",this);")
    file.write("\tu_sb="+sb_name+"::type_id::create(\"u_sb\",this);")
    file.write("\tu_cov="+cov_name+"::type_id::create(\"u_cov\",this);")
    file.write("\nendfunction : build_phase\n")
    file.write("\nfunction void "+env_name+"::connect_phase(uvm_phase phase);")
    file.write("\n super.connect_phase(phase);")
    file.write("\n `uvm_info(get_type_name(),\"Connecting monitor and Scoreboard\",UVM_NONE)\n")
    file.write("\tu_agent.u_monitor.mon_aport.connect(u_sb.sb_export);")
    file.write("\tu_agent.u_monitor.mon_aport.connect(u_cov.cov_export);")
    file.write("\nendfunction : connect_phase\n")
  logging.info(f"Successfully Created -> {l_env_path}")


#End of create_env

def create_test(dut_name):
  test_file_name=f"{dut_name.strip()}_test.sv"
  global test_name
  test_name=f"{dut_name.strip()}_test"
  l_test_path =os.path.join(folder_name,test_file_name)
  with open(l_test_path,"a+") as file:
    file.write("class "+ test_name+ " extends uvm_test;\n")
    file.write("\nvirtual "+interface_name+" vif;\n")
    file.write(env_name+" u_env;\n")
    file.write("\t\t"+seq_name +" u_seq;\n")
    file.write("\n`uvm_component_utils("+test_name+")\n")
    file.write("\nextern function new( string name = \""+test_name+"\",uvm_component parent);\n")
    file.write("extern function void build_phase(uvm_phase phase);\n")
    file.write("extern virtual task run_phase(uvm_phase phase);\n")
    file.write("\nendclass //" +test_name)
    file.write("\n")
    file.write("\nfunction "+test_name+"::new(string name,uvm_component parent);")
    file.write("\n super.new(name,parent);")
    file.write("\nendfunction : new\n")
    file.write("\nfunction void "+test_name+"::build_phase(uvm_phase phase);")
    file.write("\n super.build_phase(phase);\n")
    file.write("\n `uvm_info(get_type_name(),\"In Build Phase ...\",UVM_NONE)\n")
    file.write("\tu_env="+env_name+"::type_id::create(\"u_env\",this);")
    file.write("\nendfunction : build_phase\n")
    file.write("\ntask "+test_name+"::run_phase(uvm_phase phase);\n")
    file.write("\tsuper.run_phase(phase);\n")
    file.write("\n\t\t`uvm_info(get_type_name(),\"In Run Phase ...\",UVM_NONE)\n")
    file.write("\t\tu_seq="+seq_name+"::type_id::create(\"u_seq\",this);\n")
    file.write("\t\tphase.raise_objection( this, \"Starting phase objection\");\n")
    file.write("\n")
    file.write("\t\t`uvm_info(get_type_name(), $sformatf(\"Starting Sequence\"), UVM_LOW)\n")
    file.write("\t\tuvm_top.print_topology();\n")
    file.write("\t\tu_seq.start(u_env.u_agent.u_sqr);\n")
    file.write("\n")
    file.write("\t\tphase.drop_objection( this, \"Dropping phase objection\");")
    file.write("\nendtask: run_phase\n")

  logging.info(f"Successfully Created -> {l_test_path}")

# End of create_test

def create_top(port_list,dut_name):
  top_file_name=f"{dut_name.strip()}_top.sv"
  global top_name
  top_name=f"{dut_name.strip()}_top"
  l_top_path =os.path.join(folder_name,top_file_name)
  with open(l_top_path,"a+") as file:
    file.write("import uvm_pkg:: *;\n")
    file.write("`include \"uvm_macros.svh\"\n")

    file.write("`include \""+seq_item_name+".sv\"\n")
    file.write("`include \""+seqr_name+".sv\"\n")
    file.write("`include \""+seq_name+".sv\"\n")
    file.write("`include \""+driver_name+".sv\"\n")
    file.write("`include \""+interface_name+".sv\"\n")
    file.write("`include \""+monitor_name+".sv\"\n")
    file.write("`include \""+agent_name+".sv\"\n")
    file.write("`include \""+sb_name+".sv\"\n")
    file.write("`include \""+cov_name+".sv\"\n")
    file.write("`include \""+env_name+".sv\"\n")
    file.write("`include \""+test_name+".sv\"\n")
    file.write("\nmodule "+ top_name+";\n")
    file.write("\n//--------------------------------------")
    file.write("\n//signal declaration: clock and reset")
    file.write("\n//--------------------------------------")
    for l_ports in input_list:
      replace_to_bit = str(l_ports).replace("input","bit")
      if re.search(r".*.(clk|reset|rst|clock).*", replace_to_bit, re.IGNORECASE):
        clk_rst_list.append(str(replace_to_bit)) #Containts clock and reset
    for i in clk_rst_list:
      file.write(i)
    file.write("\n")
    file.write("\ninitial begin\n")
    for j in input_declarators:
      #if re.search(r".*.(clk|reset|rst|clock).*",str(j) , re.IGNORECASE):
      #  cr_list.append(j)
      #if re.search(r".*.(clk|clock).*",str(j) , re.IGNORECASE):
      #  only_clk.append(j)
      if re.search(r".*.(reset|rst).*",str(j) , re.IGNORECASE):
        only_rst.append(j)
    clk_rst_initial = "=0;".join(cr_list)
    clk_rst_initial += "=0;"
    file.write(clk_rst_initial)
    file.write("\nend")
    file.write("\n//--------------------------------------")
    file.write("\n//clock Generation")
    file.write("\n//--------------------------------------")
    file.write("\nalways begin\n")
    for l in only_clk:
      only_clk_i = l.strip()
      file.write("\t#5 "+only_clk_i+" <= ~"+only_clk_i+";\n") #TODO Make the delay value as a parameter or configurable one
    file.write("end\n")
    file.write("\n//--------------------------------------")
    file.write("\n//Interface Instance")
    file.write("\n//--------------------------------------")
    ports = ", ".join(cr_list)
    file.write("\n"+interface_name+" intf("+ports+");\n")
    file.write("\n//--------------------------------------")
    file.write("\n//DUT Instance")
    file.write("\n//--------------------------------------")
    file.write("\n"+dut_name+" UUT(\n")
    intf_ports = []
    for iter_i in all_declarators:
      intf_ports.append(f"\t.{iter_i.lstrip()}(intf.{iter_i.lstrip()})")
    file.write(",\n".join(intf_ports))
    file.write("\n);\n")
    file.write("\ninitial begin\n")
    file.write("\tuvm_config_db#(virtual "+interface_name+")::set(uvm_root::get(), \"*\", \"vif\", intf);\n")
    file.write("\t//enable wave dump\n") #TODO Create EDA compatible switch , Verilator compatible switch 
    file.write("\t$dumpfile(\"dump.vcd\");\n") 
    file.write("\t$dumpvars;")
    file.write("\nend\n")
    file.write("\ninitial begin\n")
    file.write("\trun_test(\""+test_name+"\");")
    file.write("\nend\n")


    file.write("\nendmodule //"+ top_name+"\n")

  logging.info(f"Successfully Created -> {l_top_path}")


# End of create_top
def print_port_details(tree):
   """
   Prints detailed information about each port in the design.

   Args:
    tree (pyslang.SyntaxTree): The parsed syntax tree of the SystemVerilog code.
   """
   print("----------------------------------------")
   print("            Port Details                ")
   print("----------------------------------------")
   for scope_i in (tree.root.members):
    if(scope_i.kind.name != "ClassDeclaration"):
        dut_name=str(scope_i.header.name) #Used to embed with tb generated files
        #print(f"\nModule: {dut_name}")
        if (hasattr(scope_i, 'members')): #Check if the scope has the attribute called "members"
          for m_i in (scope_i.members):
              if(m_i.kind.name== "PortDeclaration"):
                port_direction = str(m_i.header.direction)
                port_name = str(m_i.declarators)
                port_data_type= str(m_i.header.dataType)
                print(f"    Direction: {port_direction}    Name: {port_name}   DataType: {port_data_type}")

args = pyslint_argparse()
inp_test_name = args.test
print("Reading RTL: " +inp_test_name)
logging.getLogger().setLevel(logging.INFO) #TODO: Make the verbose parameterized 

tree = pyslang.SyntaxTree.fromFile(inp_test_name)
mod = tree.root.members[0] #stores full file
param_flag = 0


for scope_i in (tree.root.members):
  if(scope_i.kind.name != "ClassDeclaration"):
    dut_name=str(scope_i.header.name) #Used to embed with tb generated files
    #print(scope_i.header.ports)
    #for j_port in scope_i.header.ports:
    #  print(j_port)
    if (hasattr(scope_i, 'members')): #Check if the scope has the attribute called "members"
      for m_i in (scope_i.members):
        #This will print the internal name for each and every line in verilog code
        logging.debug(m_i.kind.name)
        #This will print the verilog line corresponds to kind.name
        logging.debug(m_i)
        if(m_i.kind.name== "PortDeclaration"):
          collect_port_data()
        if(m_i.kind.name== "ParameterDeclarationStatement"):
          param_flag = 1
          collect_param_data()

print(f'Printing ALL port list: \n {tabulate(port_list)}')
#print(f'Printing ALL port list: \n {tabulate(input_list)}')
#print(f'Printing ALL port list: \n {tabulate(output_list)}')
'''
Calling a function to create interface
'''
create_interface(port_list,dut_name)
create_seqitem(port_list,dut_name)
create_sequence(dut_name)
create_seqr(dut_name)
create_driver(dut_name)
create_monitor(dut_name)
create_agent(dut_name)
create_sb(dut_name)
create_coverage(dut_name)
create_env(dut_name)
create_test(dut_name)
create_top(port_list,dut_name)
print(f'\n************ Successfully created the testbench for {dut_name} ************')
