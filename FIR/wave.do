onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test/nrst
add wave -noupdate /test/clk
add wave -noupdate -format Analog-Step -height 80 -max 7.0 -min -7.0 -radix decimal /test/src
add wave -noupdate -format Analog-Step -height 80 -max 3000.0 -min -3000.0 -radix decimal /test/shape0
add wave -noupdate -format Analog-Step -height 80 -max 3000.0 -min -3000.0 -radix decimal /test/shape1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {109 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 105
configure wave -valuecolwidth 44
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
WaveRestoreZoom {3 ns} {574 ns}
