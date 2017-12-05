	.data
	.type	v, %object
	.size	v, 8

v:
	.xword 7, 3, 19, 5, 17, 11, 1, 13

	.text
	.global main
	.arch armv8-a+fp+simd
	.type main, %function

Prefix:
	CMP X2, X3			//compare i and 56
	B.NE Continue			//if i != #56
	LDR X5, [X0, X2] 		//load Array[i] into X5
	BR X30					//branch to address

Continue:
	SUB SP, SP, #16			//set space in stack pointer for 2 values
	STUR X2, [SP, #8]		//store i to SP
	STUR X30, [SP, #0]		//store return address to SP
	ADD X2, X2, #8			//i++
	BL Prefix				//call prefix again unless i == 56
	LDUR X2, [SP, #8]		//load i from stack
	LDUR X30, [SP, #0]		//load return address from stack
	ADD SP, SP, #16			//SP+2 to next set of elements
	LDR X4, [X0, X2]		//load V[i] into temp
	ADD X5, X5, X4			//Sum = Sum + temp
	BR X30					//go back

main:
	ADRP X0, v
	ADD X0, X0, :lo12:v
	SUB X2, X2, X2			//set i to zero
	SUB X3, X3, X3			//set n to 0
	ADD X3, X3, #56			//Set X3 to N address (56 meaning 0-7 with increase of 8 per turn)
	SUB X5, X5, X5			//set sum to zero
	BL Prefix				//call prefix

Exit:
