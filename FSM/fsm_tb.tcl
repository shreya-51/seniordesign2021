# restart the simulation
restart

#forcing a clock with 10 ns period
add_force clk 1 {0 5ns} -repeat_every 10ns
#Testing for the RESET FUNCTIONALITY OF THE BITS!

#Testing RESET: 00000000 00000000 00000000 00100000  ( adding 2 dummy bits)
#First 8 Bits are 0
add_force data 0
run  80 ns
#Second 8 bits are 0
add_force data 0
run  80 ns
#third 8 bits are 0
add_force data 0
run 80 ns
#fourth 8 bits
run 20 ns
add_force data 1
run 10 ns
add_force data 0
run 40 ns
run 10 ns
#Testing SET CHANNEL 1: 00000000 00000010 00111010 100000 00  ( adding 2 dummy bits)
add_force data 0
run  80 ns
run  60 ns
add_force data 1
run 10 ns
add_force data 0
run 10 ns
run 20 ns
add_force data 1
run 30 ns
add_force data 0
run 10 ns
add_force data 1
run 10 ns
add_force data 0
run 10 ns
add_force data 1
run 10 ns
add_force data 0
run 70 ns

#TESTING SET CHANNEL 2:  00000000 00000011 00111010 100001 00
add_force data 0
run  80 ns
run  60 ns
add_force data 1
run 20 ns
run 20 ns
add_force data 1
run 30 ns
add_force data 0
run 10 ns
add_force data 1
run 10 ns
add_force data 0
run 10 ns
add_force data 1
run 10 ns
add_force data 0
run 40 ns
add_force data 1
run 10 ns
add_force data 0
run 20 ns
#Testing RESET: 00000000 00000000 00000000 00100000  ( adding 2 dummy bits)
#First 8 Bits are 0
add_force data 0
run  80 ns
#Second 8 bits are 0
add_force data 0
run  80 ns
#third 8 bits are 0
add_force data 0
run 80 ns
#fourth 8 bits
run 20 ns
add_force data 1
run 10 ns
add_force data 0
run 40 ns
run 10 ns
#TESTING SET CHANNEL 3:  00000000 00000011 00111010 100010 00 
add_force data 0
run  80 ns
run  60 ns
add_force data 1
run 20 ns
run 20 ns
add_force data 1
run 30 ns
add_force data 0
run 10 ns
add_force data 1
run 10 ns
add_force data 0
run 10 ns
add_force data 1
run 10 ns
add_force data 0
run 30 ns
add_force data 1
run 10 ns
add_force data 0
run 10 ns
add_force data 0
run 20 ns
