#include <stdio.h>      // Standard input/output Library
#include <time.h>       // Standard time library
#include <stdlib.h>     // Standard library functions
#include <unistd.h>     // POSIX API (close, read, write, etc.)
#include <fcntl.h>      // File control operations (open, O_RDWR, etc.)
#include <sys/mman.h>   // Memory management functions (mmap, munmap, etc.)
#include "gpio.h"       // Custom GPIO library header

// Constants
#define SW_NUM 4
#define SW_ON 26
#define SW_OFF 19
#define SW1 13
#define SW2 6

#define LED_NUM 3
#define LED0 21
#define LED1 20
#define LED2 16

#define RUNTIME 30      // Program runtime in seconds

// Type Definitions
typedef struct {
    const int *pins;
    int count;
} GpioList;

// Function Prototypes
void setGPIO(GpioList inputs, GpioList outputs);  // Initializes input and output GPIO pins
void handleInputs(GpioList inputs, int state[]);  // Handles switch inputs and detects press (rising edge)
void handleStatus(int pin_no);                    // Executes predefined actions based on switch input
void clearOutputs(GpioList outputs);              // Turns off all output GPIO pins (sets to LOW)

int main(void) {
    // Initialize switch state tracking (all initially HIGH)
    int prev_states[SW_NUM] = {HIGH, HIGH, HIGH, HIGH};

    // Define GPIO pin lists for switches and LEDs
    const int switch_pins[SW_NUM] = {SW_ON, SW_OFF, SW1, SW2};
    const int led_pins[LED_NUM] = {LED0, LED1, LED2};

    // Wrap pin arrays into GpioList structures
    GpioList inputs = {switch_pins, SW_NUM};
    GpioList outputs = {led_pins, LED_NUM};

    // Set GPIO modes and turn on LED0 as status indicator
    setGPIO(inputs, outputs);
    digitalWrite(LED0, HIGH);

    // Start runtime loop for fixed duration
    time_t start = time(NULL);
    while (difftime(time(NULL), start) < RUNTIME) {
        handleInputs(inputs, prev_states);
    }

    // Turn off all outputs on exit
    clearOutputs(outputs);
    return 0;
}

// Function Definitions
void setGPIO(GpioList inputs, GpioList outputs) {
    wiringPiSetupGpio();  // Initialize wiringPi with BCM GPIO numbering

    // Set input pin modes
    for (int i = 0; i < inputs.count; i++) {
        pinMode(inputs.pins[i], INPUT);
    }

    // Set output pin modes
    for (int i = 0; i < outputs.count; i++) {
        pinMode(outputs.pins[i], OUTPUT);
    }
}

void clearOutputs(GpioList outputs) {
    // Set all output pins to LOW
    for (int i = 0; i < outputs.count; i++) {
        digitalWrite(outputs.pins[i], LOW);
    }
}

void handleInputs(GpioList inputs, int state[]) {
    // Poll each input switch and detect edge transition (HIGH -> LOW)
    for (int i = 0; i < inputs.count; i++) {
        int curr = digitalRead(inputs.pins[i]);
        if (state[i] == HIGH && curr == LOW) {
            handleStatus(inputs.pins[i]);  // Handle action on press
        }
        state[i] = curr;  // Update stored state
    }
    delay(50);  // Debouncing
}

void handleStatus(int pin_no) {
    // Perform predefined actions
    if (pin_no == SW_ON) {
        digitalWrite(LED1, HIGH);
        digitalWrite(LED2, HIGH);
    } else if (pin_no == SW_OFF) {
        digitalWrite(LED1, LOW);
        digitalWrite(LED2, LOW);
    } else if (pin_no == SW1) {
        digitalWrite(LED1, digitalRead(LED1) ? LOW : HIGH);  // Toggle LED1
    } else if (pin_no == SW2) {
        digitalWrite(LED2, digitalRead(LED2) ? LOW : HIGH);  // Toggle LED2
    }
}
