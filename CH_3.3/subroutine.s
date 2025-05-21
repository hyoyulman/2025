	.data
main_string:    .asciz "main\n"
sub1_string:    .asciz "subroutine 1\n"
sub2_string:    .asciz "subroutine 2\n"   

	.text
	.global main
    .extern printf

main:
    stmfd r13!, {r14}
    ldr r0, =main_string
    bl printf 
    bl sub1
    LDMFD r13!, {pc}
sub1:
    stmfd r13!, {r0-r12, r14}
    ldr r0, =sub1_string
    bl printf
    bl sub2
    ldmfd r13!, {r0-r12, pc}
sub2:
    stmfd r13!, {r0-r12, r14}
    ldr r0, =sub2_string
    bl printf
    ldmfd r13!, {r0-r12, pc}

    
.section .note.GNU-stack,"",%progbits


