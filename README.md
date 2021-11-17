# seniordesign2021
## 32 Bit Instruction: STATIC DATA 
||(MSB) 1 SWE | 1 RESET | DATA| CHANNEL | PADDED(LSB)|
| -------------| -------------| ------------- | ------------- | ------------- | ------------- | 
32 Bit Instruction| 1|1|12|3|15|
CHAN1:VOLT 2.2|0|0|001110000101|000|000000000000000|
CHAN3:VOLT 10|0|1|000000000000|010|000000000000000|

From This: The First Bit Received is SWE and last is the padded

## 64 Bit Instruction: SWEEP DATA 
||(MSB) 1 SWE | 1 RESET | Frequency|Step |Data Stop | Data Start | CHANNEL | PADDED(LSB)|
| -------------| -------------| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | 
64 Bit Instruction| 1|1|12|12|12|12|3|11|

From This: The First Bit Received is SWE and last is the padded
