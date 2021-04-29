onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider Input_Data
add wave -noupdate -label Distance -color "steel blue" -radix decimal	/HC_SR04_tb/distance
add wave -noupdate -label Trigger -color "steel blue" -radix binary	/HC_SR04_tb/trig

add wave -noupdate -divider Output_Data
add wave -noupdate -label Echo -color "cyan" -radix binary	/HC_SR04_tb/echo