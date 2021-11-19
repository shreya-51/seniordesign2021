# seniordesign2021
## 32 Bit Instruction: STATIC DATA 
||(MSB) 1 SWE | 1 RESET | DATA| CHANNEL | PADDED(LSB)|
| -------------| -------------| ------------- | ------------- | ------------- | ------------- | 
32 Bit Instruction| 1|1|12|3|15|
CHAN1:VOLT 2.2|0|0|001110000101|000|000000000000000|
CHAN3:VOLT 9.9|0|0|111111010111|010|000000000000000| 
CHAN2:VOLT 9.99|0|0|111111111011|001|000000000000000|
CHAN3:VOLT 3.4|0|0|010101110000|010|000000000000000|
CHAN2:OUT:STOP|0|0|000000000000|001|000000000000000|
*RST|0|1|000000000000|000|000000000000000|


From This: The First Bit Received is SWE and last is the padded

## 64 Bit Instruction: SWEEP DATA 
||(MSB) 1 SWE | 1 RESET | Frequency|Step |Data Stop | Data Start | CHANNEL | PADDED(LSB)|
| -------------| -------------| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | 
64 Bit Instruction| 1|1|12|12|12|12|3|11|
CHAN1:SWE: 1,2,3,4|0|0|000000000100|000010001000|001100110011|000110011001|000|00000000000|
CHAN1:SWE: 1,2,3,4|1|0|000000000100|000010001000|001100110011|000110011001|000|00000000000|

From This: The First Bit Received is SWE and last is the padded
CHAN1:SWE 1,2,3,4 sets Start Voltage to 1, Sets end voltage to 2, Number of Steps, with frequency 4 

Steps: 3 from 1 to 2 means 0.33 steps so 0.33/10*4096 is what is sent
