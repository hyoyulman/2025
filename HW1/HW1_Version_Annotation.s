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
                                @ %08X: 부호 없는 32비트 정수 (예: 0000FFFF)
                                @ 8자리 대문자 16진수, 왼쪽은 0으로 채움

    .text
    .global main
    .extern printf, scanf

main:
    push {lr}

@ Give instruction
    ldr r0,=string1
    bl printf

@ Get input numbers (스켈레톤 getNumber는 DataN(1)->dataX[0], DataN(2)->dataX[1], DataN(3)->dataX[2] 저장)
    mov r4,#NUM
    mov r0,#1
    ldr r5,=data1
    bl getNumber        @ r4는 getNumber 내부에서 NUM부터 1까지 감소함

    mov r4,#NUM         @ 두 번째 호출을 위해 r4 재설정
    mov r0,#2
    ldr r5,=data2
    bl getNumber

@ Print the input values (스켈레톤 printValues는 dataX[0]을 MSW, dataX[2]를 LSW로 표시)
    bl printValues

@ -------------------------------------------------
@ (Add two 96-bit data: Total 10pts)
@ INSTRUNTION: Write code below to add two 96-bit data and print the result (+5pts)
    bl addBits          @ 96비트 덧셈 수행

    @ 덧셈 결과 출력 (sum[0]이 MSW합계, sum[2]가 LSW합계임)
    ldr r0, =result
    ldr r12, =sum
    ldr r1, [r12, #0]      @ r1 = sum[0] (MSW 합계)
    ldr r2, [r12, #4]      @ r2 = sum[1] (MID 합계)
    ldr r3, [r12, #8]      @ r3 = sum[2] (LSW 합계)
    bl printf
@ INSTRUNTION: Use a loop (addBits) and a subroutine (checkCarry) (+5pts)
@ addBits:
@   [ Write codes ] @ 아래 addBits 함수 정의
@   bl checkCarry   @ addBits 루프 내에서 checkCarry 호출
@   [ Write codes ] @ 아래 addBits 함수 정의
@ -------------------------------------------------

    pop {pc}


@ Subroutines  (getNumber, printValues, checkCarry)

@ --------------------- addBits ------------------------
addBits:
    @ 스켈레톤 getNumber/printValues에 따라 dataX[0]=MSW, dataX[1]=MID, dataX[2]=LSW.
    @ 덧셈은 LSW(dataX[2])부터 MSW(dataX[0]) 순서로 진행.
    @ r8: 루프 카운터 (0, 1, 2)
    @ r4: 실제 배열 인덱스 (2, 1, 0)
    push {r4-r11, lr}

    mov r8, #0                   @ 루프 카운터 (0 -> LSW처리, 1 -> MID처리, 2 -> MSW처리)
    mov r11, #0                  @ 현재 캐리 (carry_in), 초기값 0

    ldr r5, =data1
    ldr r6, =data2
    ldr r7, =sum

add_loop:
    cmp r8, #NUM                 @ 루프 카운터가 NUM에 도달하면 종료
    beq done_add_loop

    @ 실제 배열 인덱스 계산: index = (NUM - 1) - loop_counter
    rsb r4, r8, #NUM             @ r4 = NUM - r8 (3, 2, 1 순서)
    sub r4, r4, #1               @ r4 = 배열 인덱스 (2, 1, 0 순서 -> LSW, MID, MSW)

    ldr r0, [r5, r4, LSL #2]     @ r0 = data1[index] (피연산자 A)
    ldr r1, [r6, r4, LSL #2]     @ r1 = data2[index] (피연산자 B)
    mov r2, r11                  @ r2 = current_carry_in

    bl checkCarry                @ checkCarry(A, B, Cin) 호출
                                 @ 반환: r0 = sum_word, r1 = new_carry_out

    str r0, [r7, r4, LSL #2]     @ 계산된 sum_word를 sum[index]에 저장
    mov r11, r1                  @ 다음 반복을 위해 new_carry_out을 r11에 저장

    add r8, r8, #1               @ 루프 카운터 증가
    b add_loop

done_add_loop:
    pop {r4-r11, lr}
    bx lr

@ -------------------------------------------------
@ INSTRUCTION: Use checkCarry for a subroutine
@ checkCarry:
@ 입력: r0=Operand A, r1=Operand B, r2=Carry_In
@ 출력: r0=Sum_Word, r1=New_Carry_Out
@ 임시 레지스터: r3, r12 (ip)
checkCarry:
    push {r3, r12, lr}           @ r12는 callee-saved (ip)

    adds r12, r0, r2             @ r12 = A + Cin. CPSR.C는 이제 C1 = Carry(A+Cin).
    mov r3, #0
    adc r3, r3, #0               @ r3 = C1 (0 또는 1).

    adds r0, r12, r1             @ r0 (Sum_Word) = (A+Cin) + B.
                                 @ CPSR.C는 이제 C2 = Carry((A+Cin)_sum_word + B).
    mov r12, #0
    adc r12, r12, #0             @ r12 = C2 (0 또는 1).

    orr r1, r3, r12              @ r1 (New_Carry_Out) = C1 OR C2.

    pop {r3, r12, pc}
@ -------------------------------------------------

getNumber:  @ 스켈레톤 코드 - 변경 없음
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

printValues: @ 스켈레톤 코드 - 변경 없음
    stmfd sp!, {r0-r12,lr}

    ldr r0, =string2
    ldr r12, =data1
    ldmia r12, {r1-r3}      @ r1=data1[0], r2=data1[1], r3=data1[2]
    ldr r12, =data2
    ldmia r12, {r4-r6}      @ r4=data2[0], r5=data2[1], r6=data2[2]
    stmfd sp!, {r4-r6}      @ 스택에 r4,r5,r6 순으로 푸시 (r4가 가장 낮은 주소)
                            @ printf는 arg5=r4값, arg6=r5값, arg7=r6값 사용
    bl printf
    add sp, sp, #12
    ldr r0, =string3
    bl printf

    ldmfd sp!, {r0-r12,pc}

@ End of the program
    .end