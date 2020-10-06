if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work [pwd]/TestBench_asyncButton.sv
vlog -sv -work work [pwd]/asyncButton.sv
vsim TestBench_asyncButton

add wave *

view structure
view signals

run 20000