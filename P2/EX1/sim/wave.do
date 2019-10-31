onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /processor_tb/i_processor/Reset
add wave -noupdate /processor_tb/i_processor/Clk
add wave -noupdate /processor_tb/i_processor/IAddr
add wave -noupdate /processor_tb/i_processor/instruccion_ex
add wave -noupdate /processor_tb/i_processor/puerto_wt_mem
add wave -noupdate /processor_tb/i_processor/puerto_wt_wb
add wave -noupdate /processor_tb/i_processor/rd2_id
add wave -noupdate /processor_tb/i_processor/rd2_ex
add wave -noupdate /processor_tb/i_processor/rd2_mem
add wave -noupdate /processor_tb/i_processor/rd1_id
add wave -noupdate /processor_tb/i_processor/rd1_ex
add wave -noupdate /processor_tb/i_processor/op2
add wave -noupdate /processor_tb/i_processor/res_alu_mem
add wave -noupdate /processor_tb/i_processor/write_data
add wave -noupdate /processor_tb/i_processor/enable_1
add wave -noupdate /processor_tb/i_processor/enable_2
add wave -noupdate /processor_tb/i_processor/inst_regbank/regs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {179 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 341
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {136 ns} {224 ns}
