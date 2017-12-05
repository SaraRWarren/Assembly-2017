	.data
	.type	v, %object
	.type	pos, %object
	.type	n, %object
	.size	v, 8

v:
	.xword 17, 12, 3, 7, 31, 27, 5, 19

	.text
	.global main
	.arch armv8-a+fp+simd
	.type main, %function
main:

	ADRP X0, v
	ADD X0, X0, :lo12:v
	SUB X20, X20, X20 		//Zero and always for comparison
	SUB X18, X18, X18		//X18 is while loop counter; Used for breaking in last swap
	ADD X18, X18, #4		//should run while loop 4 times with an array of size 8
	SUB X3, X3, X3			//set n to 0
	ADD X3, X3, #56			//Set X3 to N address
	SUB X2, X2, X2			//set i to 0 - X2 = i

While:
	LDR X4, [X0, X2] 		//load Array[i] into X4 - Smallest
	LDR X5, [X0, X3] 		//load Array[N] into X5 - Largest
	MOV X7, X2				//load i into X7 = index1
	MOV X8, X3				//load n into X8 = index2
	MOV X9, X2				//load i into X9 = j

Loop:

	LDR X10, [X0, X9]		//V[j]
	CMP X10, X4 			//compare V[J] and Smallest
	B.GE Greater 			//If V[J] > Smallest
	MOV X4, X10				//If V[J] < Smallest, Smallest = V[j]
	MOV X7, X9				//index1 = j

Greater:
	CMP X10, X5				//compare V[J] and Largest
	B.LE For 				//If V[J] < Largest
	MOV X5, X10 			//If V[J] > Largest, Largest = V[j]
	MOV X8, X9				//index2 = j

For:
	ADD X9, X9, #8          //j++
	SUB x11, X3, X9			//is j < n?
	CMP X11, X20			//is X11 less than zero
	B.GE Loop 				//loop j < n

Swap:
	SUB X18, X18, #1		//While loop counter--
	LDR X13, [X0, X2]		//Temp = V[i]
	STR X4, [X0, X2]		//V[i] = Smallest
	STR X13, [X0, X7]		//V[index1] = temp

	CMP X18, X20			//if while loop counter == 0
	B.EQ Break				//break out

	LDR X13, [X0, X3]		//Temp = V[N]
	STR X5, [X0, X3]		//V[N] = Largest
	STR X13, [X0, X8]		//V[index2] = temp

	ADD X2, X2, #8			//i = i+1
	SUB X3, X3, #8			//n = n-1

	SUB X12, X3, X2			//is i < n?
	CMP X12, X20			//is X12 > 0?
	B.GE While				//While i < n

Break:
//The only purpose of this code forward is to read out array values to address X19
	SUB X2, X2, X2			//set i to 0
	SUB X3, X3, X3			//set n to 0
	ADD X3, X3, #56			//Set X3 to N=7
Final_loop:					//for i<n; i++
	LDR X19, [X0, X2]		//X19 = V[i]
	ADD X2, X2, #8			//i++
	CMP X3, X2				//i < n
	B.GE Final_loop

exit:
