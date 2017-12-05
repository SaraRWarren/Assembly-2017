	.data
	.type	v, %object
	.type	pos, %object
	.type	n, %object
	.size	v, 8

v:
	.xword 7, 3, 19, 5, 17, 11, 1, 13

	.text
	.global main
	.arch armv8-a+fp+simd
	.type main, %function
	//a). Compute the sum of the n positive integers. Store the result in X11.
	//b). Compute the average of n positive integers. Store the result in X1
	//c). Compute the smallest of array v. Store the result in X9
	//d). Compute the biggest of array v. Store the result in X10
main:

	ADRP X0, v
	ADD X0, X0, :lo12:v
	ADD X5, X5, #8			//Set X5 to 8 N (Array Length)
	SUB X11, X11, X11 		//set sum to 0 - X11 is sum
	SUB X2, X2, X2			//set pos to 0 - X2 is pos

	LDUR X9, [X0, #0] 		//load Array[0] into smallest - X9 is smallest
	LDUR X10, [X0, #0] 		//load Array[0] into biggest - X10 is biggest

loop:
	LDUR X4, [X0, #0] 		//load Array[pos] into X4 - X4 is array[pos]
	ADD X11, X11, X4  		//Sum = Sum + Array[pos]

	//check if Array[pos] X4 is L/E X9, and if so, set X4 to X9
	CMP X9, X4 				//compare X9 and X4

	B.LE Not_Less 			//If X4 not Less than X9
	MOV X9, X4				//If X4 IS less than or equal to X9, move X4 to X9

Not_Less:
//check if Array[pos] X4 is G/E X10, and if so, set X4 to X10
	CMP X10, X4
	B.GE Not_Greater 		//IF X4 not greater than X10
	MOV X10, X4 			//If X4 IS greater than or equal to X10, move X4 to X10

Not_Greater:
	ADD X0, X0, #8 			//pos++ to next array position
	ADD X2, X2, #1 			//increment pos by one

	SUB X8, X5, X2 			//if n-pos != 0, then...
	CBNZ X8, loop 			//loop until n-pos == 0
	// loop, loop, loop

	UDIV X1, X11, X5 		//Find the average

exit:
