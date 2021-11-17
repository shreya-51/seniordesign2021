# VHDL FSM

fsm_tb.tcl is test bench

***THIS IMPLEMENTATION ASSUMES THAT THE DATA IS PADDED WITH 2 BITS RATHER THAN 1***
Ex: MCU Instruction:
| 2 swe | (MSB) PADDED | DATA | SWE| PAD |CHANNEL|PADDED(LSB)|
| -------------| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
|2| 11 | 12 | 1 |1 | 3 | 2 |

This Means When we are Sending Instructions the data sent is as follows in the TCL File: 
||2 SWE | (MSB) PADDED | DATA | PAD| RESET|CHANNEL|PADDED(LSB)|
| -------------| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
|Instruction|2| 11 | 12 | 1 |1 | 3 | 2 |
|RST| 00|0000 0000 0000 0 | 0000 0000 0000 | 0 |1 | 000 | 00 |
|CHAN3:VOLT 4.9 | 00|0000 0000 0000 0 | 011111110101  | 0 |0 | 010 | 00 | 

Tested:
1. Updating voltages of all 3 channels simulation & IRL
2. RST all 3 channels in simulation & IRL 

NEXT TEST:
1. When get SWEEP counts to 64 Cycles 
2. Latches onto ALL Needed Data for SWE 

![image](https://user-images.githubusercontent.com/54678622/142094509-9a787975-b01e-477c-8ad6-d5c102bc357e.png)
 
SWEEP COMMAND: 
|SWE (MSB) | PADDED | FREQUENCY |Step Size | Value 2 | Value 1| PAD | RESET|CHANNEL|PADDED(LSB)|
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |------------- | ------------- | ------------- |
|2|7|12|12|12|12|1|1|3|2|
