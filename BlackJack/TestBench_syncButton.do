if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work [pwd]/TestBench_syncButton.sv
vlog -sv -work work [pwd]/syncButton.sv
vsim TestBench_syncButton

add wave *

view structure
view signals

run 20000