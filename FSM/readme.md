# VHDL FSM

fsm_tb.tcl is test bench

***THIS IMPLEMENTATION ASSUMES THAT THE DATA IS PADDED WITH 2 BITS RATHER THAN 1***
Ex: MCU Instruction:
| (MSB) PADDED | DATA | SWE| RESET|CHANNEL|PADDED(LSB)|
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| 13 | 12 | 1 |1 | 3 | 2 |

This Means When we are Sending Instructions the data sent is as follows in the TCL File: 
|| (MSB) PADDED | DATA | SWE| RESET|CHANNEL|PADDED(LSB)|
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
|Instruction| 13 | 12 | 1 |1 | 3 | 2 |
|RST| 0000 0000 0000 0 | 0000 0000 0000 | 0 |1 | 000 | 00 |
