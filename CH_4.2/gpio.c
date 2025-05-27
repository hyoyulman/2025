#include <stdio.h> // Standard input/output Library
#include <stdlib.h> // Standard Library functions (malloc, free, exit, etc.)
#include <unistd.h>  // POSIX operating system API (close, read, write, etc.)
#include <fcntl.h> // File control operations (open, O_RDWR, etc.)
#include <sys/mman.h> // Memory management functions (mmap, munmap, etc.)
#include "gpio.h" // Custom GPIO Library header

// Global variables
volatile char *nmap_addr = NULL;
int mmap_fd = -1;

// Set GPIO pin as input
void set_gpio_input(int gpio_no, char *mmap_addr) { 
    volatile unsigned int *gpio_reg = NULL;
    int reg_idx = gpio_no / 10;    // Calculate GPFSEL#
    int bit = (gpio_no % 10) * 3; // Calculate the bit position
    
    gpio_reg = (volatile unsigned int *)(mmap_addr + (reg_idx * 4));
    *gpio_reg &= ~(0b111 << bit); // Set the bits to 000 (input mode)
}

// Set GPIO pin as output
void set_gpio_output (int gpio_no, char *mmap_addr) {
    volatile unsigned int *gpio_reg = NULL;
    int reg_idx = gpio_no / 10;     // Calculate GPFSEL#
    int bit = (gpio_no % 10) * 3;   // Calculate bit position

    gpio_reg = (volatile unsigned int *)(mmap_addr + (reg_idx * 4));
    *gpio_reg &= ~(0b111 << bit);   // Clear the bits to 000
    *gpio_reg |= (0b001 << bit);    // Set the bits to e01 (output mode)
}

// Read GPIO pin Level
int gpio_lev(int gpio_no, char *nmap_addr) {
    volatile unsigned int *gpio_reg = NULL;
    int reg_idx= gpio_no / 32;    // Calculate SET#
    int bit = gpio_no % 32;         // Calculate the bit position

    gpio_reg = (volatile unsigned int *) (mmap_addr + GPLEV0_OFFSET + (reg_idx * 4));
    return *gpio_reg & (1 << bit);
}

// Set GPIO pin to HIGH
void gpio_set(int gpio_no, char *mmap_addr) {
    volatile unsigned int *gpio_reg = NULL;
    int reg_idx= gpio_no / 32;      // Calculate SET#
    int bit = gpio_no % 32;         // Calculate the bit position
    
    gpio_reg = (volatile unsigned int *) (mmap_addr + GPSET0_OFFSET + (reg_idx * 4));
    *gpio_reg = (1 << bit);
}

// Set GPIO pin to LOW
void gpio_clear (int gpio_no, char *mmap_addr) {
    volatile unsigned int *gpio_reg = NULL;
    int reg_idx = gpio_no / 32;       // Calculate SET#
    int bit = gpio_no % 32;            // Calculate the bit position
    
    gpio_reg = (volatile unsigned int *)(mmap_addr + GPCLR0_OFFSET + (reg_idx * 4));
    *gpio_reg = (1 << bit);
}

// GPIO initialization function
int wiringPiSetupGpio (void) {
    // Open /dev/mem file for physical memory access
    mmap_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (mmap_fd < 0) {
        printf("Error: Cannot open /dev/mem. Try running as root (e.g., $ sudo ./program).\n"); 
        return -1;
    }

    // Map GPIO registers to memory
    mmap_addr= (char *) mmap(NULL, GPIO_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, mmap_fd, GPIO_BASE);
    if (mmap_addr == MAP_FAILED) {
        printf("Error: mmap failed\n");
        close(mmap_fd);
        return -1;
    }

    return 0;
}

// GPIO error check function
int checkGpioError(int pin_no){
    if (mmap_addr == NULL) {
    printf("Error: GPIO not initialized. Call wiringPiSetupGpio() first.\n"); 
    return -1;
    }
    if (pin_no < 2 || pin_no > 28 ) {
        printf("Error: Invalid pin number %d. Use 2-26\n", pin_no);
        return -1;
    }

    return 0;
}

// GPIO pin mode setting function 
int pinMode(int pin_no, int direction) { 
    if (checkGpioError (pin_no)) return -1;

    if (direction == INPUT) {
        set_gpio_input(pin_no, (char *) mmap_addr); 
    } else if (direction == OUTPUT) {
        set_gpio_output (pin_no, (char *)mmap_addr);
    } else {
        printf("Error: Invalid direction. Use INPUT (0) or OUTPUT (1).\n");
        return -1;
    }

    return 0;
}

// Digital read function
int digitalRead(int pin_no) {
    if (checkGpioError (pin_no)) return -1;

    return (gpio_lev(pin_no, (char *)mmap_addr) != 0) ? 1 : 0;
}

// Digital write function
int digitalWrite(int pin_no, int value) {
    if (checkGpioError (pin_no)) return -1;

    if (value == HIGH) {
        gpio_set(pin_no, (char *)mmap_addr);
    } else if (value == LOW) {
        gpio_clear (pin_no, (char *)mmap_addr); 
    } else {
        printf("Error: Invalid value. Use HIGH (1) or LOW(0).\n"); 
        return -1;
    }
    
    return 0;
}

//Millisecond dealy function
void delay(int msec) {
    usleep(msec*1000);
}