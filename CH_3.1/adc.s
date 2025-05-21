	.data
string: .asciz "the result is %08X%X \n"

	.text
	.global main
	.extern printf

main:
	push {lr}
	
	mov r5, #0xFFFFFFFF
	mov r6, #0xFFFFFFFF
    ADD    r7, r5, r6

    MOV r8, #0xFF
    MOV r9, #0xFF
    adc r10, r8, r9

	ldr r0, =string
	mov r1, r10
    mov r2, r7  

	bl printf
	pop {pc}

.section .note.GNU-stack,"",%progbits


