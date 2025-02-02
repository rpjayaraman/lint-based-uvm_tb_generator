run:
	python3 tb_creator.py -t FIFO_memory.sv -m edaplayground
	python3 tb_creator.py -t FIFO_memory.sv -m verilator -c 
