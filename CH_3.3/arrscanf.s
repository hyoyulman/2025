	.data
    .equ    SIZE, 5
arr:   .space   4*SIZE
string1:    .asciz  "정수입력하셈"
string2:    .asciz  "%d"
string3:    .asciz  "배열 저장은 다음임 \n"
string4:    .asciz  "%d\n"   

	.text
	.global main
    .extern scanf, printf

main:
	push {lr}

    mov r4, #0
    ldr r5, =arr
scanfloop:
    ldr r0, =string1
    bl printf

    ldr r0, =string2
    mov r1, r5
    bl scanf

    add r5, r5, #4
    add r4, r4, #1
    cmp r4, #SIZE
    blt scanfloop

    ldr r0, =string3
    bl printf

    mov r4, #0
    ldr r5, =arr
printloop:
    ldr r0, =string4
    ldr r1, [r5], #4
    bl printf

    add r4, r4, #1
    cmp r4, #SIZE
    blt printloop


	pop {pc}

.section .note.GNU-stack,"",%progbits


