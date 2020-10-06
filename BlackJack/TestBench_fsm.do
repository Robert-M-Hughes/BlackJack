if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work [pwd]/TestBench_fsm.sv
vlog -sv -work work [pwd]/fsm.sv
vlog -sv -work work [pwd]/playerAI.sv
vsim TestBench_fsm

add wave TestBench_fsm/clk
add wave TestBench_fsm/fsm/state
add wave -unsigned TestBench_fsm/currentState

add wave -unsigned TestBench_fsm/p1_high
add wave -unsigned TestBench_fsm/p1_low
add wave -unsigned TestBench_fsm/p2_high
add wave -unsigned TestBench_fsm/p2_low
add wave -unsigned TestBench_fsm/d_high
add wave -unsigned TestBench_fsm/d_low

add wave TestBench_fsm/hold
add wave TestBench_fsm/hit
add wave TestBench_fsm/holdAI
add wave TestBench_fsm/hitAI

add wave TestBench_fsm/userSelect

view structure
view signals

run 30000