#include <wiringPi.h>
#include <stdio.h>
#include <time.h>

#define LED 18
#define SW 24

int switchControl(void);

int main(void){

     wiringPiSetupGpio();
     switchControl();
      
     return 0;

}

int switchControl(void){
    time_t start, current;
    int count = 0;
    start = time(NULL);

    pinMode(LED, OUTPUT);
    pinMode(SW, INPUT);
    while(difftime(time(NULL), start)<60){
        
        if(digitalRead(SW)==LOW){
            digitalWrite(LED,1);
            printf("switch is pressed (count: %d)\r\n", ++count);
        }
        else{
            digitalWrite(LED, 0);
        }
        delay(10);
    }
}