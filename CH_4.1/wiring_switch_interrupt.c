#include <wiringPi.h>
#include <stdio.h>

#define LED 18
#define SW 24

void isr_sw(void);

int main(void){

    unsigned int sec = 0;
    wiringPiSetupGpio();
    pinMode(LED, OUTPUT);
    pinMode(SW, INPUT);
    wiringPiISR(SW, INT_EDGE_BOTH, isr_sw);
    
    while(sec<30){
        printf("%d sec. \r\n, sec");
        sec = sec + 1;
        delay(1000);
    }
    return 0;
}

void isr_sw(void){

    if(digitalRead(SW) == LOW){
        digitalWrite(LED, 1);
    }
    else{
        digitalWrite(LED, 0);
    }
}