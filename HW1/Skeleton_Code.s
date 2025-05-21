	.data
	.equ NUM, 3
data1:	.word 0, 0, 0
data2:	.word 0, 0, 0

hex:		.asciz "%X"
dec:		.asciz "Data%d (%d). "
string1:	.asciz "Enter 6 numbers in hexadecimal (0~FFFFFFFF):\n"
string2:	.asciz "\t0x(%08X)(%08X)(%08X)\n +\t0x(%08X)(%08X)(%08X)\n"
string3:	.asciz " ----------------------------------------\n"
result:	.asciz " =\t0x(%08X)(%08X)(%08X)\n\n"  
                            @ %08X: an unsigned 32-bit integer (e.g. 0000FFFF)
                            @ in 8-digit uppercase hexadecimal, zero-padded on the left

	.text
	.global main
	.extern printf, scanf

main:
	push {lr}	

@ Give instruction
	ldr r0,=string1
	bl printf

@ Get input numbers
	mov r4,#NUM			
	mov r0,#1
	ldr r5,=data1
	bl getNumber
	mov r0,#2
	ldr r5,=data2
	bl getNumber

@ Print the input values
	bl printValues

@ -------------------------------------------------
@ (Add two 96-bit data: Total 10pts)
@ INSTRUNTION: Write code below to add two 96-bit data and print the result (+5pts)
@	 [ Write codes ]
@ INSTRUNTION: Use a loop (addBits) and a subroutine (checkCarry) (+5pts)
@ addBits:
@	 [ Write codes ]
@	 bl checkCarry 
@	 [ Write codes ]
@ -------------------------------------------------

	pop {pc}	


@ Subroutines  (getNumber, printValues, checkCarry)

@ -------------------------------------------------
@ INSTRUCTION: Use checkCarry for a subroutine
@ checkCarry:             
@	 [ write codes ]
@ -------------------------------------------------

getNumber:	
	stmfd sp!, {r0-r12,lr}		
	mov r11, r0
	getNumberLoop:				
		ldr r0,=dec
		mov r1,r11
		rsb r2,r4,#NUM
		add r2,r2,#1
		bl printf
		ldr r0,=hex
		mov r1,r5
		bl scanf
		add r5,r5,#4			
		subs r4,r4,#1
		bne	getNumberLoop
	ldmfd sp!, {r0-r12,pc}

printValues:
    stmfd sp!, {r0-r12,lr}	
	
	ldr r0, =string2
	ldr r12, =data1
	ldmia r12, {r1-r3}
	ldr r12, =data2
	ldmia r12, {r4-r6}
	stmfd sp!, {r4-r6}        
    bl printf                 
    add sp, sp, #12 
	ldr r0, =string3
	bl printf
    
	ldmfd sp!, {r0-r12,pc}

@ End of the program
	.end
