# VHDL FSM

fsm_tb.tcl is test bench

***THIS IMPLEMENTATION ASSUMES THAT THE DATA IS PADDED WITH 2 BITS RATHER THAN 1***
Ex: MCU Instruction:
| (MSB) PADDED | DATA | SWE| RESET|CHANNEL|PADDED(LSB)|
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| 13 | 12 | 1 |1 | 3 | 2 |


