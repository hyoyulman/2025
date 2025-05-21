	.data
string: .asciz "the result is %d \n"

	.text
	.global main
	.extern printf

main:
	push {lr}
	
	@mov r5, #3
	ldr r5, =289

	ADD r7, r5, #20

	ldr r0, =string
	mov r1, r7

	bl printf
	pop {pc}

.section .note.GNU-stack,"",%progbits



