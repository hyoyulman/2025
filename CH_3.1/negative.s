	.data
string: .asciz "the result is %08X \n"

	.text
	.global main
	.extern printf

main:
	push {lr}
	
	mov r5, #3
	mov r6, #6

	sub r7, r5, r6

	ldr r0, =string
	mov r1, r7

	bl printf
	pop {pc}

.section .note.GNU-stack,"",%progbits


