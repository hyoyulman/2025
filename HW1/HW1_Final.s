    .data
    .equ NUM, 3
data1:   .word 0, 0, 0
data2:   .word 0, 0, 0
sum:     .word 0, 0, 0

hex:         .asciz "%X"
dec:         .asciz "Data%d (%d). "
string1:     .asciz "Enter 6 numbers in hexadecimal (0~FFFFFFFF):\n"
string2:     .asciz "\t0x(%08X)(%08X)(%08X)\n +\t0x(%08X)(%08X)(%08X)\n"
string3:     .asciz " ----------------------------------------\n"
result: .asciz " =\t0x(%08X)(%08X)(%08X)\n\n"

    .text
    .global main
    .extern printf, scanf

main:
    push {lr}

    ldr r0,=string1
    bl printf

    mov r4,#NUM
    mov r0,#1
    ldr r5,=data1
    bl getNumber     

    mov r4,#NUM       
    mov r0,#2
    ldr r5,=data2
    bl getNumber


    bl printValues

    bl addBits          

    ldr r0, =result
    ldr r12, =sum
    ldr r1, [r12, #0]      
    ldr r2, [r12, #4]      
    ldr r3, [r12, #8]      
    bl printf


    pop {pc}

addBits:
    push {r4-r11, lr}

    mov r8, #0                   
    mov r11, #0                  

    ldr r5, =data1
    ldr r6, =data2
    ldr r7, =sum

add_loop:
    cmp r8, #NUM                 
    beq done_add_loop

    rsb r4, r8, #NUM             
    sub r4, r4, #1               

    ldr r0, [r5, r4, LSL #2]     
    ldr r1, [r6, r4, LSL #2]     
    mov r2, r11                  

    bl checkCarry              
                                 

    str r0, [r7, r4, LSL #2]     
    mov r11, r1                  

    add r8, r8, #1            
    b add_loop

done_add_loop:
    pop {r4-r11, lr}
    bx lr


checkCarry:
    push {r3, r12, lr}           

    adds r12, r0, r2             
    mov r3, #0
    adc r3, r3, #0               

    adds r0, r12, r1            
                                 
    mov r12, #0
    adc r12, r12, #0            

    orr r1, r3, r12              

    pop {r3, r12, pc}

getNumber:  
    stmfd sp!, {r0-r12,lr}
    mov r11, r0
    getNumberLoop:
        ldr r0,=dec
        mov r1,r11
        rsb r2,r4,#NUM
        add r2,r2,#1
        bl printf
        ldr r0,=hex
        mov r1,r5
        bl scanf
        add r5,r5,#4
        subs r4,r4,#1
        bne getNumberLoop
    ldmfd sp!, {r0-r12,pc}

printValues: 
    stmfd sp!, {r0-r12,lr}

    ldr r0, =string2
    ldr r12, =data1
    ldmia r12, {r1-r3}     
    ldr r12, =data2
    ldmia r12, {r4-r6}      
    stmfd sp!, {r4-r6}                      
    bl printf
    add sp, sp, #12
    ldr r0, =string3
    bl printf

    ldmfd sp!, {r0-r12,pc}

    .end
    