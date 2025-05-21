	.data
string: .asciz  "Result is %p, %p  \n" 
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

    ldr r0, =string
    MOV r1, r5
    MOV r2, r6 

    bl printf

	pop {pc}

.section .note.GNU-stack,"",%progbits


