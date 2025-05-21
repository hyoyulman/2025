	.data
string: .asciz "the result is %16X (AND) %X (BIC) \n"

	.text
	.global main
	.extern printf

main:
	push {lr}
	
	mov r7, #0x000000FF 
	mov r8, #0xFFFFFFFF

	and r5, r7, r8
	bic r6, r7, r8

	ldr r0, =string
	mov r1, r5
	mov r2, r6

	bl printf
	pop {pc}

.section .note.GNU-stack,"",%progbits



