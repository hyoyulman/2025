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

    ldr r5, =TABLE1
    ldr r6, =TABLE2

    ldr r7, [r5]
    str r7, [r6]

    ldr r7, [r5,#4]
    str r7, [r6,#4]

    ldr r7, [r5,#8]
    str r7, [r6,#8]

    ldr r0, =string
    ldr r1, [r6]
    ldr r2, [r6,#4]
    ldr r3, [r6,#8]

    bl printf

	pop {pc}

.section .note.GNU-stack,"",%progbits


