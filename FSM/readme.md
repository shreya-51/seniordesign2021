# VHDL FSM

fsm_tb.tcl is test bench

***THIS IMPLEMENTATION ASSUMES THAT THE DATA IS PADDED WITH 2 BITS RATHER THAN 1***
Ex: MCU Instruction:
| (MSB) PADDED | DATA | SWE| RESET|CHANNEL|PADDED(LSB)|
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| Content Cell  | Content Cell  |
| Content Cell  | Content Cell  |
