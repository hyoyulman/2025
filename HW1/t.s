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

    ldr r0,=string1
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
    ldr r1, [r12, #8]    
    ldr r2, [r12, #4]    
    ldr r3, [r12, #0]     
    bl printf

    pop {pc}

@ --------------------- addBits ------------------------
addBits:
    push {r4-r12, lr}
    mov r4, #0
    mov r11, #0              @ 초기 carry 값

    ldr r5, =data1
    ldr r6, =data2
    ldr r7, =sum

add_loop:
    cmp r4, #NUM
    beq done

    ldr r8, [r5, r4, LSL #2]
    ldr r9, [r6, r4, LSL #2]

    adds r10, r8, r9          @ 기본 합 계산 (carry 포함 전)

    cmp r11, #0
    addeq r10, r10, #0        @ carry가 없을 때
    addne r10, r10, #1        @ carry가 있을 때 추가

    @ carry 계산: 다음 루프에 전달
    mov r0, r8
    adds r0, r0, r9
    adc r11, r11, #0          @ carry 발생 여부 r11에 저장

    str r10, [r7, r4, LSL #2]
    add r4, r4, #1
    b add_loop

done:
    bl checkCarry              @ r11 최종 carry 출력용
    pop {r4-r12, lr}
    bx lr

@ ------------------- checkCarry ------------------------
checkCarry:
    mov r11, r0
    bx lr

@ ------------------- getNumber -------------------------
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

@ ------------------ printValues ------------------------
printValues:
    stmfd sp!, {r0-r12,lr}
    ldr r0, =string2
    ldr r12, =data1
    ldmia r12, {r1-r3}
    mov r4, r3     
    mov r5, r2   
    mov r6, r1     
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
