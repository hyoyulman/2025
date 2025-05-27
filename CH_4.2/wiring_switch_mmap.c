// #include <wiringPi.h> //DO not include
#include <stdio.h> // Standard input/output Library
#include <time.h> // Standard time Library
#include <stdlib.h> // Standard Library functions (malloc, free, exit, etc.)
#include <unistd.h>  // POSIX operating system API (close, read, write, etc.)
#include <fcntl.h> // File control operations (open, O_RDWR, etc.)
#include <sys/mman.h> // Memory management functions (mmap, munmap, etc.)
#include "gpio.h" // Custom GPIO Library header

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
    while(difftime(time(NULL), start)<30){
        
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