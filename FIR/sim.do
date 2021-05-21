#==============================================
# clear 
#==============================================
quit -sim
.main clear

#==============================================
# Create work library
#==============================================
vlib work
vmap work work

#================================================================
# Compile 
#   - Source files should be under the same dir
#   - Verlog-C Direct programming interface (DPI)
#================================================================
# Compile the HDL sources
vlog -sv test.v
vlog -sv -dpiheader fir.h fir.v
# Compile the C sources
gcc -c -I C:\modeltech64_10.4\include fir.c
gcc -shared -Bsymbolic -o fir.dll fir.o

#================================================================
# Simulation settings
#================================================================
# Set top and no optimization
vsim -novopt -c -sv_lib fir test
# Add waves
add wave /test/nrst
add wave /test/clk
add wave -analog -decimal -min -7 -max 7 -height 80 /test/src
add wave -analog -decimal -min -3000 -max 3000 -height 80 /test/shape0
add wave -analog -decimal -min -3000 -max 3000 -height 80 /test/shape1
# Run simulation
run 1000