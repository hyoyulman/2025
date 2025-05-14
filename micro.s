.data
.equ NUM, 3
data1:  .word 0, 0, 0
data2:  .word 0, 0, 0
sum:    .word 0, 0, 0

hex:    .asciz "%X"
dec:    .asciz "Data%d (%d). "
string1: .asciz "Enter 6 numbers in hexadecimal (0~FFFFFFFF):\n"
string2: .asciz "\t0x(%08X)(%08X)(%08X)\n +\t0x(%08X)(%08X)(%08X)\n"
string3: .asciz " ----------------------------------------\n"
result: .asciz " =\t0x(%08X)(%08X)(%08X)\n\n"

.text
.global main
.extern printf, scanf

main:
    push {lr}

    ldr r0, =string1
    bl printf

    mov r4, #NUM
    mov r0, #1
    ldr r5, =data1
    bl getNumber

    mov r4, #NUM
    mov r0, #2
    ldr r5, =data2
    bl getNumber

    bl printValues
    bl addBits

    ldr r0, =result
    ldr r12, =sum
    ldr r1, [r12, #8]     @ MSB
    ldr r2, [r12, #4]     @ MID
    ldr r3, [r12, #0]     @ LSB
    bl printf

    pop {pc}

@ ----------------------------------------
addBits:
    push {r4-r11, lr}
    mov r4, #0
    mov r11, #0                @ 초기 carry-in = 0

    ldr r5, =data1
    ldr r6, =data2
    ldr r7, =sum

add_loop:
    cmp r4, #NUM
    beq done

    ldr r8, [r5, r4, LSL #2]
    ldr r9, [r6, r4, LSL #2]

    cmp r4, #0
    beq no_carry_in

    @ --- carry-in 반영 덧셈 ---
    add r10, r8, r9
    cmp r11, #1
    addeq r10, r10, #1     @ 이전 carry가 1일 때만 +1
    b store

no_carry_in:
    adds r10, r8, r9       @ LSB는 캐리-in 없음

store:
    str r10, [r7, r4, LSL #2]
    bl checkCarry

    add r4, r4, #1
    b add_loop

done:
    pop {r4-r11, lr}
    bx lr


@ ----------------------------------------
checkCarry:
    mov r11, #0
    adc r11, r11, #0
    bx lr

@ ----------------------------------------
getNumber:
    stmfd sp!, {r0-r12,lr}
    mov r11, r0
    add r5, r5, #(NUM - 1) * 4

get_loop:
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
    bne get_loop
    ldmfd sp!, {r0-r12,pc}

@ ----------------------------------------
printValues:
    stmfd sp!, {r0-r12,lr}

    ldr r0, =string2
    ldr r12, =data1
    ldmia r12, {r1-r3}
    mov r4, r3     @ MSB
    mov r5, r2     @ MID
    mov r6, r1     @ LSB

    ldr r12, =data2
    ldmia r12, {r1-r3}
    mov r7, r3
    mov r8, r2
    mov r9, r1

    mov r1, r4
    mov r2, r5
    mov r3, r6
    push {r7, r8, r9}
    bl printf
    add sp, sp, #12

    ldr r0, =string3
    bl printf

    ldmfd sp!, {r0-r12,pc}

.end
.section .note.GNU-stack,"",%progbits
