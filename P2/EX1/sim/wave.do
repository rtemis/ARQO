--------------------------------------------------------------------------------
# Arq2019-2020. En principio solo clk y reset. Agregar señales relevantes
--------------------------------------------------------------------------------

add wave -noupdate /processor_tb/i_processor/Reset
add wave -noupdate /processor_tb/i_processor/Clk
add wave -noupdate /processor_tb/i_processor/IAddr

add wave -noupdate /processor_tb/i_processor/inst_regbank/regs

add wave -noupdate /processor_tb/i_processor/inst_control
