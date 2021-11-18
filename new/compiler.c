//Senior_design_COMP_Main Function
#include "msp.h"
#include "driverlib.h"
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define DAC_CS (*((volatile uint8_t *)(0x42000000+32*0x4C82+4*4)))

//adding to see if okay
#include <stdint.h>
void ADC_Init(void);
//void current_protection(double current, float voltage, int channel);
uint32_t ii;
uint64_t send;
double x[8];

struct Token {
    int operation;
    int type;
    float value1;
    float value2;
    int channel;
    uint16_t stepsize;
    uint16_t frequency;
    struct Token* next;
};

//head of linked list
struct Token* head;
struct Token* cur; // actual current
struct Token* current;


//STORE CURRENT VALUES OF VOLTAGE AND CURRENT!!
int onArray[8] = {0,0,0,0,0,0,0,0};
float voltageSet[8] = {0,0,0,0,0,0,0,0};
float currentSet[8] = {16,16,16,16,16,16,16,16};
float currentRead[8] = {2,0,0,0,0,0,0,1};
char inputstr[255];

//configuring the interrupt
const eUSCI_UART_Config uartConfig =
{
        EUSCI_A_UART_CLOCKSOURCE_SMCLK,          // SMCLK Clock Source
        78,                                     // BRDIV = 78
        2,                                       // UCxBRF = 2
        0,                                       // UCxBRS = 0
        EUSCI_A_UART_NO_PARITY,                  // No Parity
        EUSCI_A_UART_LSB_FIRST,                  // LSB First
        EUSCI_A_UART_ONE_STOP_BIT,               // One stop bit
        EUSCI_A_UART_MODE,                       // UART mode
        EUSCI_A_UART_OVERSAMPLING_BAUDRATE_GENERATION  // Oversampling
};
//Sending out signals
void DAC_Out(uint16_t code){
    DAC_CS =0;
    //normal protocol send out 24 bytes
    int i=0;
    EUSCI_A3->TXBUF = code>>8;
    while((EUSCI_A3->IFG&0x0001) == 0x0000){}; //8
    //added
    EUSCI_A3->TXBUF = code;
    while((EUSCI_A3->IFG&0x0001) == 0x0000){}; //16
    DAC_CS = 1;
}

//pin 9.5 is clock!, 9.7 -- data,, 9.4 enable
void DAC_Init(uint16_t data){
    P9->SEL0 &= ~0x10;  //
    P9->SEL1 &= ~0x10;  //make 9.4 output
    P9->DIR |= 0x10;    //
    DAC_CS = 1; //P9.4 active low
    EUSCI_A3->CTLW0 = 0x0001; //hold eUSCI module in reset mode
    EUSCI_A3->CTLW0 = 0xAD83; //synchronous master mode
    EUSCI_A3->BRW = 100000000;        //smclk/2  (NORMALLY  2)
    EUSCI_A3->MCTLW = 0;      //no modulation
    P9->SEL0 |= 0xA0;
    P9->SEL1 |= ~0xA0;  //9.7 and 9.5 module (9.7 data, 9.5 clock 9.4 enable)
    EUSCI_A3->CTLW0 &= ~0x0001;//enable eUSCI module
    EUSCI_A3->IE &= ~0x0003; //disable interrupts
    DAC_Out(data);
}

main(void)
{
       /* Halting WDT  */
       MAP_WDT_A_holdTimer();
       ADC_Init();

       /* Selecting P1.2 and P1.3 in UART mode */
       MAP_GPIO_setAsPeripheralModuleFunctionInputPin(GPIO_PORT_P1,
               GPIO_PIN2 | GPIO_PIN3, GPIO_PRIMARY_MODULE_FUNCTION);

       /* Setting DCO to 12MHz */
       CS_setDCOCenteredFrequency(CS_DCO_FREQUENCY_12);

       //![Simple UART Example]
       /* Configuring UART Module */
       MAP_UART_initModule(EUSCI_A0_BASE, &uartConfig);

       /* Enable UART module */
       MAP_UART_enableModule(EUSCI_A0_BASE);

       /* Enabling interrupts */
       MAP_UART_enableInterrupt(EUSCI_A0_BASE, EUSCI_A_UART_RECEIVE_INTERRUPT);
       MAP_Interrupt_enableInterrupt(INT_EUSCIA0);
     //  MAP_Interrupt_enableSleepOnIsrExit(); --  not added for that
       MAP_Interrupt_enableMaster();
       //![Simple UART Example]
       //
       __enable_interrupt(); //always should be the last thing before infinite
       while(1)
       {
        __WFI();// this is WAIT FOR INTERRUPT -- see if can READ from the port constantly ??
       }
}

//reseting state to start accepting commands
int i=0;
int head_inst=0;

void EUSCIA0_IRQHandler(void)
{
    inputstr[i]  =  UART_receiveData(EUSCI_A0_BASE); // Recieve data
    i = i+1;
    int j =0;
    int k=0;

    while((UCA0IFG & 0x02)==0){};
    //Waiting until a you get to END of SCPI Command (\0 or \n)
    if(inputstr[i-1] == '\0' || inputstr[i-1] == '\n') {    //creating a linked list of these commands (Change to \n when adding the NEW LINE !)
        //Check if Special UPDATE!!!
        if((inputstr[0] == 'U') && (inputstr[1] == 'P')) {  //Special command sent from GUI that will update the Voltage and Current Values
          print_state();
        }
        else{
        current = lexer(inputstr); // Start tokenizing string to see if a correct scpi command or not
        if(current != NULL) {       //if proper instruction and have an instruction node add to list
            if(head_inst==0){       //if first instruction node add to head of list
                head = current;
                cur = head;
                head_inst = 1;
                head->next = NULL;
            }
            else{               //add to the end of the linked list of instructions.
                cur->next = current;
                //test = cur->operation;
                current->next = NULL;
                cur = current;
            }
        }
        else {  //if not a SCPI command return to user not a valid command
        UART_transmitData(EUSCI_A0_BASE, 'N'); //send out the command entered
        UART_transmitData(EUSCI_A0_BASE, 'O'); //send out the command entered
        UART_transmitData(EUSCI_A0_BASE, 'T'); //send out the command entered
        UART_transmitData(EUSCI_A0_BASE, 'V'); //send out the command entered
        UART_transmitData(EUSCI_A0_BASE, 'A'); //send out the command entered
        UART_transmitData(EUSCI_A0_BASE, 'L'); //send out the command entered
        UART_transmitData(EUSCI_A0_BASE, 'I'); //send out the command entered
        UART_transmitData(EUSCI_A0_BASE, 'D'); //send out the command entered
        UART_transmitData(EUSCI_A0_BASE, ' '); //send out the command entered

        UART_transmitData(EUSCI_A0_BASE, ' '); //send out the command entered
        for(j=0;j<i-1;j++){
            UART_transmitData(EUSCI_A0_BASE, inputstr[j]); //send out the command entered
        }
        UART_transmitData(EUSCI_A0_BASE,'\n');
        }

        //If DONE with compiling ALL SCPI Commands now go through linked list execute commands and delete them from the list
        float ret;
        if(inputstr[i-1] == '\0'){
            struct Token* tmp;
            while (head != NULL)
                {
                    //print_instruction(); //For Testing purposes now this will be commented out later
                    ret = execute_instruction();    //this is executing instruction (some need to be sent to FPGA
                    tmp = head;
                    head = head->next;
                    free(tmp);                      //freeing node from linked list
                }
            head_inst =0;                           //reseting state
        }

        }
        i=0;                                       //reseting state
    }
}

/*
 * This prints the current state of the system
 * outputs All Set Voltage Values
 * outputs All Set Current Values
 * outputs All On/Off Channels
 * GUI reads this and can output to user accordingly
 */
void print_state(){
    uint32_t val;
    uint32_t send;
    int j =0;
    int k=0;
    //handle current protection ( > 150 and or > current set value will SHUT OFF CHANNEL!! )
    for(j=0;j<8;j++){
        if(x[j] > currentSet[j] || x[j]*voltageSet[j] > 150){
            onArray[j] = 0;
            send = 0x0000;
            val = 0x0000;                        //make sure send is all 0.
            send <<= 0x05;                    //shift up 5 spots reset and sweep are 0!
            val = head->channel;
            send |= (val & 0x4);
            send |= (val & 0x2);
            send |= (val & 0x1);               //first 3 bits are channel
  //          print_Send(send);                   //send this out to FPGA
            //TODO: FIX THIS!
            DAC_Init(send);                   //TEST THIS!!
        }
    }
    //Now want to send out the voltage values -- sending it out in values that can be read by python UI
    for(j=0;j<8;j++){
        char charVal1[20];
        sprintf(charVal1,"%f",voltageSet[j]);
        for(k=0; k<8;k++)
            UART_transmitData(EUSCI_A0_BASE, charVal1[k]); //send out the command entered
     }
    for(j=0;j<8;j++){
        char charVal1[20];
        sprintf(charVal1,"%f",currentSet[j]);
    for(k=0; k<8;k++)
        UART_transmitData(EUSCI_A0_BASE, charVal1[k]); //send out the command entered
    }
    //Display the Current as well!
    for(j=0;j<8;j++){
            char charVal1[20];
            sprintf(charVal1,"%f",x[j]);
        for(k=0; k<8;k++)
            UART_transmitData(EUSCI_A0_BASE, charVal1[k]); //send out the command entered
    }

    for(k=0;k<8;k++) {
        UART_transmitData(EUSCI_A0_BASE, onArray[k]+'0');
    }


}

/*
 * This function is ultimately for testing purposes -- just responds
 * To User the parsed Instruction Node version of the command. Note
 * This will not be used in final output
 * */
void print_instruction(){
    current = head;
    int j =0;
    int k=0;
    char charChannel = head->channel + '0';
    UART_transmitData(EUSCI_A0_BASE, charChannel);      //send out Channel Value
    char charOperation = head->operation + '0';
    UART_transmitData(EUSCI_A0_BASE, charOperation);    //send out Operation
    char chartype = head->type + '0';
    UART_transmitData(EUSCI_A0_BASE, chartype);         //send out the type of operation
    UART_transmitData(EUSCI_A0_BASE, ' ');              //send out space
    char charVal1[20];
    sprintf(charVal1,"%f",head->value1);
    for(k=0; k<8;k++)
       UART_transmitData(EUSCI_A0_BASE, charVal1[k]);   //send out VALUE1
    UART_transmitData(EUSCI_A0_BASE,' ');               //send out space
    char charVal2[20];
    sprintf(charVal2,"%f",head->value2);
    for(k=0; k<8;k++)
        UART_transmitData(EUSCI_A0_BASE, charVal2[k]); //send out VALUE2
    UART_transmitData(EUSCI_A0_BASE,'\n');             //send out new line value
}
/*
 * Strictly used to test out sending
 */
void print_Send(uint32_t data){
    UART_transmitData(EUSCI_A0_BASE, 'S'); //send out the command entered
    UART_transmitData(EUSCI_A0_BASE, 'E'); //send out the command entered
    UART_transmitData(EUSCI_A0_BASE, 'N'); //send out the command entered
    UART_transmitData(EUSCI_A0_BASE, 'D'); //send out the command entered
    UART_transmitData(EUSCI_A0_BASE, ' '); //send out the command entered

    int k;
    int out = (int) data;
    char vals[12];
    sprintf(vals,"%d",out);
    for(k=0; k<8;k++){
        if((vals[k] <= 0x39) && (vals[k] >= 0x30))               //break once done
            UART_transmitData(EUSCI_A0_BASE, vals[k]); //send out VALUE2
    }
    UART_transmitData(EUSCI_A0_BASE,'\n');             //send out new line value
}

/*For Cases of a 64 bit sweep*/
void print_SendSweep(uint64_t data){
    UART_transmitData(EUSCI_A0_BASE, 'S'); //send out the command entered
    UART_transmitData(EUSCI_A0_BASE, 'E'); //send out the command entered
    UART_transmitData(EUSCI_A0_BASE, 'N'); //send out the command entered
    UART_transmitData(EUSCI_A0_BASE, 'D'); //send out the command entered
    UART_transmitData(EUSCI_A0_BASE, ' '); //send out the command entered

    int k;
    int out = (unsigned long long ) data;
    char vals[15];
    sprintf(vals,"%llu",out);
    for(k=0; k<14;k++){
        if((vals[k] <= 0x39) && (vals[k] >= 0x30))               //break once done
            UART_transmitData(EUSCI_A0_BASE, vals[k]); //send out VALUE2
    }
    UART_transmitData(EUSCI_A0_BASE,'\n');             //send out new line value
}


/*
 * This function prints the output that will be sent to SHREYA to the terminal for now.
 * PROTOCOL:
 * 3 bits for channel
 * 1 bit - reset (1 for reset)
 * 1 bit - type: 0 is static 1 is sweep
 * 12 bits - of voltage
 * **TBD number points and step size.
 */


float execute_instruction(){
    int k;
    uint64_t val;
    uint16_t bottom;
    uint16_t top;
    uint16_t mid1;
    uint16_t mid2;
    int n = 15;
    if(head->operation == 1){                   //RETURN TO USER: MEASURED VOLTAGE or CURRENT
        float ret;
        if(head->type == 0)
            ret = voltageSet[head->channel-1];
        else
            ret = x[head->channel-1];
        char charVal1[20];
           sprintf(charVal1,"%f",ret);
           for(k=0; k<8;k++)
              UART_transmitData(EUSCI_A0_BASE, charVal1[k]); //RETURN TO USER THE DESIRED OUTPUT
           UART_transmitData(EUSCI_A0_BASE,'\n');
    }
    else if(head->operation == 2){              //TODO: SENDING VOLTAGE TO FPGA
       if(head->type ==0) {
           voltageSet[head->channel-1] = head->value1;  //have device keep track of voltage being set

           if(onArray[head->channel-1] == 1) {             //means can send out to FPGA
               send = 0x0000;
               val = 0x0000;
               send = (head->value1 / 10) * 4096;   //convert to proper value to send
               send = send << 0x03;                    //shift up 3 spots to SET CHANNEL
               val = head->channel-1;
               send |= (val & 0x4);
               send |= (val & 0x2);
               send |= (val & 0x1);
               send = send << 0x0F;                 //TODO SHIFT UP TO 15
               print_Send(send);                   //will send out to FPGA this value.
               bottom = send & 0xFFFF;               //bottom of 16
               send = send >>16;
               top = send;              //top of 16
               DAC_Init(top);                   //2 is for sending out data
               for(i=0;i<50000;i++){
                               //comment
                       }
               DAC_Init(bottom);
           }

       }
    }
    else if(head->operation == 4){              //TURNING ON AND OFF VOLTAGE OUTPUTS
        if(head->type == 3){ // means start
            onArray[head->channel-1] = 1;       //TODO: SEND OUT VOLTAGE SET TO FPGA
            if(voltageSet[head->channel-1] != 0) {
                send = 0x0000;
                val = 0x0000;
                send = (voltageSet[head->channel-1]/ 10) * 4096;   //convert to proper value to send
                send = send << 0x03;                    //shift up 5 spots reset and sweep are 0!
                val = head->channel-1;
                send |= (val & 0x4);
                send |= (val & 0x2);
                send |= (val & 0x1);
                print_Send(send);
                send = send << 0x0F;                  //will send out to FPGA this value.
                bottom = send & 0xFFFF;               //bottom of 16
                send = send >>16;
                top = send;              //top of 16
                DAC_Init(top);                   //2 is for sending out data
                for(i=0;i<50000;i++){
               }
               DAC_Init(bottom);
        }
        } if(head->type ==2) {// means stop        //TODO: SEND OUT VOLTAGE OFF TO FPGA
           onArray[head->channel-1] = 0;
           //send to FPGA turn OFF
           send = 0x0000;
           val = 0x0000;                        //make sure send is all 0.
           send <<= 0x05;                    //shift up 5 spots reset and sweep are 0!
           val = head->channel-1;
           send |= (val & 0x4);
           send |= (val & 0x2);
           send |= (val & 0x1);               //first 3 bits are channel
           print_Send(send);                   //send this out to FPGA
           send = send << 0x0F;
           bottom = send & 0xFFFF;               //bottom of 16
           send = send >>16;
           top = send;
           DAC_Init(top);
           for(i=0;i<50000;i++){
           }
           DAC_Init(bottom);
           //TODO: TURN OFF CHANNEL!
        }

    }
    else if(head->operation ==0){               //This is the reset of the device
        for(k=0;k<8;k++){                       //TODO: SEND COMMAND TO FPGA TO TURN OFF CHANNELS
          voltageSet[k]=0;
          currentSet[k] = 16;
          onArray[k]=0;
        }
        top = 0x4000;
        bottom =0x0000;
        DAC_Init(top);
        for(i=0;i<50000;i++){
        }
        DAC_Init(bottom);
   //     print_Send(send);   //send this to FPGA
        //need to send to DAC!!!
    }
    else if(head->operation == 3){              //This is the voltage sweep output.
        send = 0x0000;                      //make sure send is all 0.
        send = head->channel-1;               //first 3 bits are channel
        val = (head->value1 / 10) * 4096;   //convert to proper value to send
        val <<= 0x03; // change to only shift up by 3 instead of 5
        send |= val;
        val=0;
        val = (head->value2/10)*4096;
        val <<= 0x0F;                       //shift 15
        send |= val;                       //Adding STOP Voltage
        val=0;
        val = head->stepsize;
        val <<= 0x1b;                               //need to add step size -- (now default is 0.5 but will need to add this functionality.
        send |= val;
        val =0;
        val = head->frequency;
        val <<= 0x027;                               //need to add step size -- (now default is 0.5 but will need to add this functionality.
        send |= val;
        send = send;
        send = send << 0x0B;
        //add sweep bit
        send |= 0x8000000000000000;                       //adding a sweep bit
        //TODO : CHANGE THIS TO 4 16 bit times !!
        //need to split this up 4 x to get 16 bits at a time.  -- Check if the For loop 16 is enough!!

         bottom = send & 0xFFFF;               //bottom of 16
         send = send >>16;
         mid2 = send & 0xFFFF;
         send = send >> 16;
         mid1 = send & 0xFFFF;
         send = send >> 16;
         top = send;
          DAC_Init(top);
           for(i=0;i<50000;i++){
           }
           DAC_Init(mid1);
           for(i=0;i<50000;i++){
           }
           DAC_Init(mid2);
           for(i=0;i<50000;i++){
           }
           DAC_Init(bottom);

       //print_SendSweep(send);
    }

}

//This is compiler that is taking data and putting it into a binary format that can be read.
struct Token* lexer(char* teststr) {
    struct Token* head = (struct Token*)malloc(sizeof(struct Token));   //creating instruction node
    int counter = 1;                                                    //counter -- where in SCPI COMMAND
    int k;
    int isOkay = 0;                                                     //isOkay is if it is valid grammar of command
    int done_flag = 0;                                                  //This is done flag -- if reach end of SCPI Command
    char* tokenc;                                                       //This is the parsed SCPI Command
    tokenc = strtok(teststr, ":*");
    do {

        isOkay = helper_lexer(tokenc, counter); //Send to helper_lexer to check if proper spelling of command in proper location
        if (isOkay >= 1 && done_flag == 0) {    //if a valid part of command put into the instruction node
            switch (counter) {
            case 1:
                head->channel = isOkay; //setting to a channel value
                head->type = 9;         //default have 3 -- means unassigned
                head->operation = 0;    //operation defaulted
                head->value1 = -1;      //default value -1
                head->value2 = -1;      //default value -1
                head->frequency = -1;
                head->stepsize =-1;
                break;
            case 2:
               head->operation = isOkay; //1 - measure, 2 - set, 3 - sweep, 4 - out
               //adding types of voltage or current
               if ((tokenc[0] == 'V') && (tokenc[1] == 'O') && (tokenc[2] == 'L')) {
                   head->type = 0;
               }
               else if (tokenc[0] == 'C' && tokenc[1] == 'U' && tokenc[2] == 'R') {
                   head->type = 1;
               }
               else if(isOkay == 1){    //? commands are completed now
                    done_flag = 1;
                }
                else{
                    head->type = 3;
                }
                break;
            case 3:
                if((isOkay == 2) && (head->operation == 2)){ //Setting Float value of voltage source
                    head->value1 = atof(tokenc);
                    done_flag = 1;
                }else if(isOkay == 2){
                    head->value1 = atof(tokenc);
                }
                else if (isOkay == 1) { //current protection setting head->type = 1 (current)
                    head->type = isOkay;
                }
                else if (isOkay == 3) { // turning on voltage source
                    head->type = isOkay;
                    done_flag = 1;
                }
                else if (isOkay == 4) { //turning off voltage source
                    head->type = 2;
                    done_flag = 1;

                }
                break;
            case 4:
                if (isOkay == 1 && head->type == 3) {   //This is for Voltage sweep -- 2nd voltage sweep value
                    head->type = 0;
                    head->value2 = atof(tokenc);
                 }
                if((isOkay == 1 && head->type == 1 ))
                    head->value1 = atof(tokenc); //This is current protection value
                    currentSet[head->channel-1] = head->value1;
                break;
            case 5: //This is for  the number of steps
                if(isOkay==1){
                    //calculate step size:
                    float step_size = 0;
                    step_size = (head->value2 - head->value1)/atof(tokenc);
                    head->stepsize = step_size/10*4096;
                }

                break;
            case 6:  // This is for the output frequency
                if(isOkay==1){
                    head->frequency = atof(tokenc);

                 done_flag = 1;
                }
               break;
            }
        }
        else if (isOkay == -1) { // if a reset or CLS command need to reset the code
            head->operation = 0;
            head->channel = 0;
            head->value1 = 0;
            head->value2 = 0;
            if (tokenc[0] == 'R' && tokenc[1] == 'S' && tokenc[2] == 'T') {
                head->type = 0;
                //for(k=0;k<8;k++){
                //    voltageSet[k]=0;
                //    currentSet[k]=0;
                //}
            }
            else if (tokenc[0] == 'C' && tokenc[1] == 'L' && tokenc[2] == 'S') {
                head->type = 1;
            }
            done_flag = 1;
        }
        else { //IF NOT VALID -- delete node and will return not a valid command
            free(head);
            return NULL;
        }
        tokenc = strtok(NULL, ": ,");   //parse through next instruction
        counter++;                      //next phase in the SCPI Command
    } while (tokenc != NULL && done_flag ==0);  //check if still valid

    return head;
}

/*
 * Implements helper to check that things are spelled correctly and in proper order
 * Takes Token as an input and takes in the counter which is the spot in the SCPI command
 * Returns the correct value if a valid command or not
 */
int helper_lexer(char* teststr, int counter) {
    float myfloat;
    switch (counter)
    {
    case 1: //Source, RST, CLS commands
        if ((teststr[0] == 'R' && teststr[1] == 'S' && teststr[2] == 'T')|| (teststr[0] == 'C' && teststr[1] == 'L' && teststr[2] == 'S')){ return -1; }//handling the EXCEPTION token !!
        if ((teststr[0] == 'C' && teststr[1] == 'H' && teststr[2] == 'A' && teststr[3] == 'N')) { if(((teststr[4] - '0')>0 )&&((teststr[4] - '0') < 9 ))return (teststr[4]- '0'); else return 0;}
        else {
            return 0;
        }
        break;
    case 2: //THIS IS EITHER VOLTAGE or CURRENT or SWE, VOLT?, or CUR?, Out
        if (((teststr[0] == 'V') && (teststr[1] == 'O') && (teststr[2] == 'L') && (teststr[3] == 'T'))||(teststr[0] == 'C' && teststr[1] == 'U' && teststr[2] == 'R')){
            if((teststr[4] == '?') || (teststr[3] == '?')) return 1;
            return 2;
        }
        if ((teststr[0] == 'S' && teststr[1] == 'W' && teststr[2] == 'E')){return 3;} // Voltage Sweep
        if ((teststr[0] == 'O' && teststr[1] == 'U' && teststr[2] == 'T')){return 4;} //OUT Command
        return 0;
        break;
    case 3: //This is either a FLOAT, PROT, START, STOP
        if (sscanf(teststr, "%f", &myfloat) == 1) {
            if(atof(teststr) > 10) return 0; //making sure that the voltage is below accepted value
            return 2; }
        else if ((teststr[0] == 'S' && teststr[1] == 'T' && teststr[2] == 'A' && teststr[3] == 'R' && teststr[4] == 'T')) { return 3; }
        else if ((teststr[0] == 'S' && teststr[1] == 'T' && teststr[2] == 'O' && teststr[3] == 'P')) { return 4;}
        else if ((teststr[0] == 'P' && teststr[1] == 'R' && teststr[2] == 'O' && teststr[3] == 'T')) { return 1;}
        else{return 0;}
        break;
    case 4: //Setting a float value (either current protection or voltage sweep
        if (sscanf(teststr, "%f", &myfloat) == 1) { return 1; }
            return 1;
        break;
    case 5: //This is for  the number of steps
        if (sscanf(teststr, "%d", &myfloat) == 1) { return 1; }
         return 1;
    break;
    case 6:  // This is for the output frequency
        if (sscanf(teststr, "%f", &myfloat) == 1) { return 1; }
        return 1;
    break;
    default: // code to be executed if n doesn't match any cases
        break;
    }
    return 0;

}
void ADC_Init()
{
    TIMER_A2->CTL &= ~0x0030; //stop timer to program
    TIMER_A2->CTL = 0x0202; //SMCLK input, /1, Up-mode, enable interrupts
    TIMER_A2->EX0 = 0x0004; //further clock divide by 5 - clock is now 600kHz
    TIMER_A2->CCTL[1] = 0x0070; //Compare Mode, Set-Reset, enable interrupt
    TIMER_A2->CCR[0] = 29; //period is 30 clock cycles
    TIMER_A2->CCR[1] = 15; //~50% duty cycle
    while(REF_A->CTL0&0x0400){};
    REF_A->CTL0 = 0x0039; //sets static & buffered 2.5V reference; REFOUT (0x0002) is currently disabled
    while((REF_A->CTL0&0x1000) == 0){};
    ADC14->CTL0 &= ~0x00000002; //disable ADC to program
    while(ADC14->CTL0&0x00010000){};
    ADC14->CTL0 = 0x04026690; //sample for 128 25MHz clock cycles per channel, use SC bit to trigger, multiple conversion single sweep, turn on
    ADC14->CTL1 = 0x00000030; //no use of internal modules, normal power, 14-bit resolution, write results starting at ADC->MEM[0], conversions are unsigned 0-16384 from 0V to 2.5V
    ADC14->MCTL[0] = 0x00000100; //tells submodule 0 to look at A0, not last submodule to check
    ADC14->MCTL[1] = 0x00000101; //tells submodule 1 to look at A1, not last submodule to check
    ADC14->MCTL[2] = 0x00000102;
    ADC14->MCTL[3] = 0x00000103;
    ADC14->MCTL[4] = 0x00000104;
    ADC14->MCTL[5] = 0x00000105;
    ADC14->MCTL[6] = 0x00000106;
    ADC14->MCTL[7] = 0x00000187; //tells submodule 7 to look at A7, last submodule to check
    ADC14->IER0 = 0x00000080; //Allows submodule 7 to signal interrupt
    ADC14->IER1 = 0;
    //configure pins to be analog inputs. Uses A0-A7
    P4->SEL0 |= 0xC0;
    P4->SEL1 |= 0xC0;
    P5->SEL0 |= 0x3F;
    P5->SEL1 |= 0x3F;
    //P5->DIR |= 0x40; //testing
    //P5->SEL0 |= 0x40; //testing
    //P5->SEL1 &= ~0x40; //testing
    ADC14->CTL0 |= 0x00000002; //re-enable ADC
    NVIC->IP[6] = (NVIC->IP[6]&0xFFFFFF00)|0x00000040; //set priority of ADC interrupt to 2
    NVIC->IP[3] = (NVIC->IP[3]&0xFFFF00FF)|0x00004000; //set priority of Timer interrupt to 2
    NVIC->ISER[0] |= 0x01002000; //enable ADC and TA2.1 interrupts to be seen by CPU
    TIMER_A2->CTL |= 0x0014; //reset timer and start
}


// PINS 5.0 - 5.5  each one connected to circuit (0-2.5V) (a0 - a7), 4.6 and 4.7 as well
//5.0 is channel 0.
void ADC14_IRQHandler(void)
{
    for(ii=0;ii<8;ii++)
    {
        x[ii] = (double)(ADC14->MEM[ii])*9.24775095e-4; //convert read signal to current in mA
    }

}
void TA2_N_IRQHandler(void)
{
    switch(TIMER_A2->IV) //Check the interrupt vector for TA2.1 thru TA2.4
    {
        case 2: //CCR1/TA2.1 Flags
            TIMER_A2->CCTL[1] &= ~0x0001; //Clear Interrupt Flag
            ADC14->CTL0 |= 0x00000001; //Start ADC Sample
            break;
        default:
            break;
    }
}


/*
void current_protection(double current, float voltage, int channel){
    if(current*voltage>150 || current > currentSet[channel]){
        //send out to turn channel OFF
        uint32_t val;
        onArray[head->channel-1] = 0;
        //send to FPGA turn OFF
        send = 0x0000;
        val = 0x0000;                        //make sure send is all 0.
        send <<= 0x05;                    //shift up 5 spots reset and sweep are 0!
        val = head->channel;
        send |= (val & 0x4);
        send |= (val & 0x2);
        send |= (val & 0x1);               //first 3 bits are channel
     //   print_Send(send);                   //send this out to FPGA
    }*/

//}




