	.data
string: .asciz "Resuilt : %d \n"
x:  .word   3
y:  .word   7
z:  .word   0

	.text
	.global main
    .extern printf

main:
	push {lr}

    ldr r1, =x
    LDR r5,[r1]
    ldr r2, =y
    ldr r6,[r2]
    
    add r7,r5,r6
    ldr r3, =z
    str r7,[r3]

    ldr r0, =string
    ldr r1,[r3]

    bl printf
	pop {pc}

.section .note.GNU-stack,"",%progbits


