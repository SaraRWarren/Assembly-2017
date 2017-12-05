	.data
	.type	v, %object
	.type 	n, %object
	.size	v, 8
	.size	n, 1
v:
	.float 17.0, 12.1, 3.2, 7.3, 31.4, 27.5, 5.6, 19.7
n:
	.Xword 8
	.text
	.global main
	.arch armv8-a+fp+simd
	.type main, %function

PreAverage:
	cmp			X4, X3				//compare i and 28
	b.ne		Average				//if i != #28
	ldr			S1, [X1, X3] 		//load Array[i] into S1
	br			X30					//branch to address

Average:
	sub			SP, SP, #16			//set space in stack pointer for 2 values
	stur		X3, [SP, #8]		//store i to SP
	stur		X30, [SP, #0]		//store return address to SP
	add			X3, X3, #4			//i++
	bl			PreAverage			//call PreAverage again unless i == 28

	ldur		X2, [SP, #8]		//load i from stack
	ldur		X30, [SP, #0]		//load return address from stack
	add			SP, SP, #16			//SP+2 to next set of elements
	ldr			S3, [X1, X2]		//load V[i] into temp
	fadd		S1, S1, S3			//Sum = Sum + temp
	br			X30					//go back

PreVariance:
	cmp			X4, X3				//compare i and 28
	b.ne		Variance			//if i != #28

	ldr			S5, [X1, X3] 		//load Array[i] into S5
	fsub		S6, S5, S1			//V[i] - Average
	fmul		S6, S6, S6			//Square it
	fadd		S2, S2, S6			//add it to sum
	br			X30					//branch to address

Variance:
	sub			SP, SP, #16			//set space in stack pointer for 2 values
	stur		X3, [SP, #8]		//store i to SP
	stur		X30, [SP, #0]		//store return address to SP
	add			X3, X3, #4			//i++
	bl			PreVariance			//call prefix again unless i == 28

	ldur		X3, [SP, #8]		//load i from stack
	ldur		X30, [SP, #0]		//load return address from stack
	add			SP, SP, #16			//SP+2 to next set of elements
	ldr			S5, [X1, X3]		//load V[i] into temp
	fsub		S6, S5, S1			//V[i] - average
	fmul		S6, S6, S6			//Square it
	fadd		S2, S2, S6			//add it to sum
	br			X30					//go back

main:
	adrp		X1, v
	add			X1, X1, :lo12:v		//Array V
	adrp		X2, n
	add			X2, X2, :lo12:n		//N = 8
	ldur		X2, [X2, #0]

	sub			X3, X3, X3			//set i to zero
	sub			X4, X4, X4			//set n to 0
	add			X4, X4, #28			//Set X3 to N address (28 meaning 0-7 with increase of 4 per turn for float address @32bits)
	scvtf		S4, X2				//Convert 8 to float for 1/n

	bl			PreAverage			//call prefix
	//after Average is calculated
	sub			X3, X3, X3			//set i to zero
	fdiv		S1, S1, S4			//Sum / 8 = Average

	bl			PreVariance
	sub			X5, X5, X5			//set i to zero
	add			X5, X5, #1			//set i to 1 for 1/n
	scvtf		S3, X5				//Convert 1 to 1.0 for float divide
	fdiv		S3, S3, S4			//1/n
	fmul		S2, S2, S3			//Variance *(1/n)
	fsqrt		S2, S2				//Square of Variance = Standard Deviation
Exit:
