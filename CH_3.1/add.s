	.data 									//data section, program에 쓸 data를 저장함
string: .asciz "the result is %d \n"  		//string이라는 라벨을 정의

	.text									//실제 코드 section
	.global main							//전역함수로 main을 정의 -> 프로그램 시작점
	.extern printf							//printf는 외부함수(라이브러리)이기에 미리 정의 + linker가 나중에 libc 연결

main:
	push {lr}								//link register(r14)

	mov r5, #3								//mov도 Instruction이다
	mov r6, #7

	ADD r7, r5, r6							
	
	ldr r0, =string							// = 의 의미는 주소를 의미한다(data를 저장하는 것이 아님)
	mov r1, r7								// 1번 주소만 저장하는 이유 : 문자열이 늘어나면 32-bit에 저장 불가, 시작 address만 있으면 굿

	bl printf								//printf 가 순차적으로 데이터를 넣어서 %d를 통해 출력
	pop {pc}								//main이 돌아갈 자리

.section .note.GNU-stack,"",%progbits


