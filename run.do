# Functional coverage
vlib work
vlog list.svh
vsim -novopt -suppress 12110 top
add wave -position insertpoint sim:/top/pif/*
run -all

