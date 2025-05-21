	.data
string: .asciz  "Result is %d, %d, %d  \n" 
    .align
TABLE1: .word   10, 20, 30
TABLE2: .word   0, 0, 0

	.text
	.global main
    .extern  printf

main:
	push {lr}
    
    mov r4, #0
    ldr r5, =TABLE1
    ldr r6, =TABLE2

loop:
    ldr r7, [r5], #4
    str r7, [r6], #4

    add r4, r4, #1
    cmp r4, #3
    bne loop

    sub r6, r6, #12

    ldr r0, =string
    ldr r1, [r6]
    ldr r2, [r6,#4]
    ldr r3, [r6,#8]

    bl printf
	pop {pc}

.section .note.GNU-stack,"",%progbits


