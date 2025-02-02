# lint-based-uvm_tb_generator

This Python-based `tb_creator` script uses the `pyslang` module to parse a design file and collect input, output, and parameter information. Based on this data, the `tb_creator` script generates a fully functional UVM-based testbench (excluding driver/monitor/scoreboard logic).

**Key Features:**

*   **Automated Testbench Generation:** Quickly generate the skeleton of a UVM testbench.
*   **RTL Parsing:** Leverages `pyslang` to extract vital information from your Verilog/SystemVerilog design.
*   **UVM Framework:** Generates a UVM-compliant testbench structure.
*   **Verilator Support:** Creates a Verilator-compatible UVM testbench along with a `Makefile`.
*   **Flexible Output:** Can generate a UVM testbench for both EDA tools and Verilator.

**Steps to Use:**

1.  **Clone the Repository:**

    ```bash
    git clone <https://github.com/rpjayaraman/lint-based-uvm_tb_generator.git>
    cd <lint-based-uvm_tb_generator>
    ```

2.  **Install Dependencies:**

    Install Verilator, pyslang and Verilator-uvm from https://github.com/antmicro/uvm-verilator/tree/master

3.  **Prepare Your Design:**
    *   Ensure your Design Under Test (DUT) Verilog or SystemVerilog file is ready.
    *   For example a simple design is provided `FIFO_memory.sv`

4.  **Run the Testbench Generator:**

    ```bash
    python tb_creator.py -t path/to/your_design.sv
    ```
    *   Replace `tb_creator.py` with the actual name of the python script, and  `path/to/your_design.sv` with the actual path to your design file.
    *   For Verilator, use the `-m verilator -c` option
        ```bash
        python tb_creator.py -t path/to/your_design.sv -m verilator -c
        ```
    *  For EDAPlayground, use the `-m edaplayground` option with your python script
       ```bash
        python tb_creator.py -t path/to/your_design.sv -m edaplayground
        ```

5.  **Generated Testbench:**
    *  The script will create a folder named `tb` and it will have the generated files.
    *  For Verilator, it will create a folder named `{DUT_NAME}_verilator` which will include the makefile and a sub folder `tb` which has the testbench and design files.

6.  **Add custom Logic:**
    *   The generated testbench includes all the required files except the driver/monitor/scoreboard logic.
    *   You will have to add the driver/monitor/scoreboard logic in the generated file, based on your needs.
7.  **Run Simulations:**

   *  For EDA tools, you would use the generated files in https://www.edaplayground.com/

   *   For Verilator:

        1.  Navigate to the `{DUT_NAME}_verilator` folder (created when using -m verilator) and execute:

            ```bash
            make all
            ```
