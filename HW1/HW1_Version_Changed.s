    .data
    .equ NUM, 3
data1:   .word 0, 0, 0
data2:   .word 0, 0, 0
sum:     .word 0, 0, 0

hex:     .asciz "%X"
dec:     .asciz "Data%d (%d). "
string1: .asciz "Enter 6 numbers in hexadecimal (0~FFFFFFFF):\n"
string2: .asciz "\t0x(%08X)(%08X)(%08X)\n +\t0x(%08X)(%08X)(%08X)\n"
string3: .asciz " ----------------------------------------\n"
result:  .asciz " =\t0x(%08X)(%08X)(%08X)\n\n"

    .text
    .global main
    .extern printf, scanf

main:
    push {lr}

    ldr r0,=string1
    bl printf

    mov r4, #NUM
    mov r0, #1
    ldr r5, =data1
    bl getNumber

    mov r0, #2
    ldr r5, =data2
    bl getNumber

    bl printValues


    bl addBits      @ After this, r11 is not directly used by main,
                    @ but addBits will call checkCarry to print its final r11.

    ldr r0, =result
    ldr r12, =sum
    ldr r1, [r12, #8]      @ sum[2] (MSW)
    ldr r2, [r12, #4]      @ sum[1] (Mid)
    ldr r3, [r12, #0]      @ sum[0] (LSW)
    bl printf

    pop {pc}

@ --------------------- addBits ------------------------
addBits:
    push {r0, r4-r12, lr}        @ Save r0 and r12 as they are now used as scratch/temp
    mov r4, #0                   @ Loop counter/index i = 0
    mov r11, #0                  @ Initial carry_in (Cin) = 0 for the LSW addition

    ldr r5, =data1               @ Base address of data1
    ldr r6, =data2               @ Base address of data2
    ldr r7, =sum                 @ Base address of sum

add_loop:
    cmp r4, #NUM
    beq done_add_loop

    ldr r8, [r5, r4, LSL #2]     @ r8 = data1[i] (Operand A)
    ldr r9, [r6, r4, LSL #2]     @ r9 = data2[i] (Operand B)
                                 @ r11 is current carry_in (Cin)

    @ Calculate Sum Word (r10) and New Carry_Out (for next stage, into r11)
    @ Step 1: r10 = A + Cin. Get C1.
    adds r10, r8, r11            @ r10 = A + Cin. CPSR.C is now C1 = Carry(A+Cin).
    mov r12, #0                  @ Using r12 (callee-saved) to store C1.
    adc r12, r12, #0             @ r12 = C1 (0 or 1).

    @ Step 2: r10 = (A+Cin) + B. Get C2. r10 becomes the final sum_word.
    adds r10, r10, r9            @ r10 = (A+Cin) + B. This is the final sum_word for this position.
                                 @ CPSR.C is now C2 = Carry((A+Cin)_sum_word + B).
    mov r0, #0                   @ Using r0 (caller-saved, fine as scratch here) to store C2.
    adc r0, r0, #0               @ r0 = C2 (0 or 1).

    @ Step 3: New Carry_Out for next stage (r11) = C1 OR C2.
    orr r11, r12, r0             @ r11 (new Cin for next iteration) = C1 OR C2.

    str r10, [r7, r4, LSL #2]    @ Store the final sum_word into sum[i]
    add r4, r4, #1               @ Increment loop counter/index
    b add_loop

done_add_loop:
    pop {r0, r4-r12, lr}         @ Restore r0 and r12 as well
    bx lr

@ ------------------- checkCarry ------------------------
@ Prints the final carry bit, which is expected to be in r11.
checkCarry:
    push {r1, lr}          @ Save r0, r1 (used by printf) and link register

    mov r1, r11                @ Move the carry bit from r11 into r1 (second argument for printf)
    bl printf                  @ Call printf

    pop {r1, lr}           @ Restore registers
    bx lr

@ --- getNumber and printValues functions remain the same as in your original code ---
getNumber:
    stmfd sp!, {r0-r12,lr}
    mov r11, r0
    add r5, r5, #(NUM - 1) * 4
    getNumberLoop:
        ldr r0,=dec
        mov r1,r11
        rsb r2,r4,#NUM
        add r2,r2,#1
        bl printf
        ldr r0,=hex
        mov r1,r5
        bl scanf
        sub r5,r5,#4
        subs r4,r4,#1
        bne getNumberLoop
    ldmfd sp!, {r0-r12,pc}

printValues:
    stmfd sp!, {r0-r12,lr}
    
    ldr r0, =string2
    ldr r12, =data1
    ldmia r12, {r1-r3} @ r1=data1[0], r2=data1[1], r3=data1[2]
    mov r4, r3         @ r4=MSW1 (data1[2])
    mov r5, r2         @ r5=Mid1 (data1[1])
    mov r6, r1         @ r6=LSW1 (data1[0])
    ldr r12, =data2
    ldmia r12, {r1-r3} @ r1=data2[0], r2=data2[1], r3=data2[2]
    mov r7, r3         @ r7=MSW2 (data2[2])
    mov r8, r2         @ r8=Mid2 (data2[1])
    mov r9, r1         @ r9=LSW2 (data2[0])
    
    @ Arguments for printf (MSW, Mid, LSW order for each number)
    mov r1, r4         @ Arg2: MSW1
    mov r2, r5         @ Arg3: Mid1
    mov r3, r6         @ Arg4: LSW1
    push {r9}          @ Arg7: LSW2 (innermost on stack)
    push {r8}          @ Arg6: Mid2
    push {r7}          @ Arg5: MSW2 (outermost on stack for this group)
    bl printf
    add sp, sp, #12    @ Clean up stack (3 words * 4 bytes)
    
    ldr r0, =string3
    bl printf
    ldmfd sp!, {r0-r12,pc}

    .end