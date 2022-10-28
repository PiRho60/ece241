vlib work

vlog alu.v hex_decoder.v adder_8bit.v

vsim part3

log {*/}

add wave {/*}

force {A} 1111
force {B} 1111
force {Function} 000
run 10ns

force {A} 0000
force {B} 0001
force {Function} 000
run 10ns

force {A} 0000
force {B} 0001
force {Function} 100
run 10ns

force {A} 0000
force {B} 0001
force {Function} 100
run 10ns