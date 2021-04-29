#!/usr/bin/tclsh
quit -sim

# Clear the transcript window
.main clear

set DIR_ROOT "."

exec vlib work

set vhdls [list \
	"$DIR_ROOT/HC_SR04.vhd" \
	"$DIR_ROOT/HC_SR04_tb.vhd" \
	]
	
foreach src $vhdls {
	if [expr {[string first # $src] eq 0}] {puts $src} else {
		vcom -93 -work work $src
	}
}

vsim -voptargs=+acc work.HC_SR04_tb
do wave.do
run 100 ms