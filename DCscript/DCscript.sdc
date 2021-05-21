# setup the lib
## the standard library name:std.db, memory library name: ram.db
set search_path " $search_path ./lib ./rtl"
set target_library "std.db" 
set link_library "* $target_library ram.db"
set synthetic_library {dw_foundation.sldb}

# design entry
## according to the figure, every module corresponds to a *.v file
analyze -format verilog $RTL_PATH/mul.v
analyze -format verilog $RTL_PATH/alu.v
analyze -format verilog $RTL_PATH/ldst.v
analyze -format verilog $RTL_PATH/config_reg.v
analyze -format verilog $RTL_PATH/dataregfile.v
analyze -format verilog $RTL_PATH/dataram.v
analyze -format verilog $RTL_PATH/biu.v
analyze -format verilog $RTL_PATH/dmafifo.v
analyze -format verilog $RTL_PATH/top.v
elaborate top

# set current design and link
current_design top
Link
uniquify

# set clk and reset
## CLK: T = 4ns，DMAclk: T = 5ns
create_clock -period 4 -waveform {0 2} CLK
create_clock -period 5 -waveform {0 2.5} DMAclk 
## PCLK: the DFF divides the CLK by 2
create_generated_clock -name "PCLK" \
                       -divide_by 2 \
                       -source CLK \
                       [get_pins DFF1/Q]
set_clock_uncertainty $CLK_UNCERTAINTY all_clocks
## In DC, clocks are all ideal network
set_ideal_network {all_clocks nrst}
set_dont_touch_network {all_clocks nrst}
set_false_path –from nrst

# set input drives and output loads
## Input drives: D Flip-Flop "DFF1"; 
## Clocks are ideal network
set_driving_cell -lib_cell "DFF1" -pin Z [all_inputs]
set_drive 0 {all_clocks nrst}
## Output loads: 20 Inverters my_lib_name/INV/A
set_load [expr 20 * [load_of my_lib_name/INV/A]] [all_outputs]

# set input output delay
## In/Outs are all synchronized signals in their clock domain, 
## marked by 2 different colors, CLK: Red, DMAclk: Yellow
set_input_delay $CLK_INPUT_DELAY -clock CLK [get_ports[list OP opdata*]]
set_input_delay $DMA_INPUT_DELAY -clock DMAclk [get_ports[list DMAwdata DMAen DMArwn]]
set_output_delay $CLK_OUTPUT_DELAY -clock CLK [get_ports BIUwdata]
set_output_delay $DMA_OUTPUT_DELAY -clock DMAclk [get_ports DMArdata]

# set design rule
## MUL logic: max delay = 2 * 4ns = 8ns
set_max_delay 8 –from [get_pins unitMUL/Ain] –to [get_pins unitMUL/Mul_data]
## Other unspecified design rules 
set_max_transition $MAX_TRANSITION top
set_max_fanout $FANOUT top
set_max_capacitance $MAX_CAP top

# compile the design
compile_ultra

# report the design
## report constraint, timing, area information
report_area -hierarchy
report_constraint > $LOG_PATH/constraint.rpt
report_timing -max_paths 2

