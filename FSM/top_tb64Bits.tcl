# restart the simulation
restart

#forcing a clock with 10 ns period
add_force clk 1 {0 5ns} -repeat_every 10ns
#Testing for the RESET FUNCTIONALITY OF THE BITS!
add_force reset 1
run 10 ns
add_force reset 0
run 10 ns
#Testing RESET: 100000000 111111111111 000000000000 000000000000 0000000000 00 000 00  ( adding 2 dummy bits)
#SWE BIT
add_force data 1
run 20 ns
#8 BITS OF DUMMY DATA
add_force data 0
run  70 ns
#12 BITS OF FREQUENCY
add_force data 1
run  120 ns
#REST ARE 0
add_force data 0
run  430 ns

#TESTING THE STEP data
#SWE BIT ( 2 high )
add_force data 1
run 20 ns
#7 BITS OF DUMMY DATA
add_force data 0
run  70 ns
#12 BITS OF FREQUENCY
add_force data 0
run  120 ns
#12 BITS OF STEP
add_force data 1
run  120 ns
#REST ARE 0
add_force data 0
run  310 ns

#TESTING THE DATA1 data
#SWE BIT ( 2 high )
add_force data 1
run 20 ns
#7 BITS OF DUMMY DATA
add_force data 0
run  70 ns
#12 BITS OF FREQUENCY
add_force data 0
run  120 ns
#12 BITS OF STEP
add_force data 0
run  120 ns
#12 BITS OF VOLTAGE
add_force data 1
run  120 ns
#REST ARE 0
add_force data 0
run  190 ns
