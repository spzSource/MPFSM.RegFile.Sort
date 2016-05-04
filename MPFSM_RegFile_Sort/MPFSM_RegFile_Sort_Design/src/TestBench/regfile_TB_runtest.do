SetActiveLib -work
comp -include "$dsn\src\RegFile.vhd" 
comp -include "$dsn\src\TestBench\regfile_TB.vhd" 
asim +access +r TESTBENCH_FOR_regfile 
wave 
wave -noreg init
wave -noreg write_data_port
wave -noreg write_address
wave -noreg read_data_port_1
wave -noreg read_data_port_2
wave -noreg read_address_1
wave -noreg read_address_2
wave -noreg write_enabled
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\regfile_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_regfile 
