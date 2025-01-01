@ Stopwatch_Part_2
@
@ ECSE 4235 - Embedded Systems II
@ Property of Samuel Brewster and Simline Gijo	
@ Created 18SEP2024
@
@ To Compile, Use: gcc -o Stopwatch_Part_2 Stopwatch_Part_2.s -lc


	.text
    .global main
    .include "./E4235_KYBdeblock.s"

@ Main Function -Initializes Variabes and Calls Deblock.
main:
	mov r5, #0
	mov r6, #0
	mov r7, #0
    b _deblock

@ Deblock Function - Calls Deblock from Class Library.
_deblock:  
    mov r0, #1				@ when r0 = 1, calling deblock enables it
    bl  E4235_KYBdeblock	@ call Class Library Deblock
    b _start				@ Begin Program

@ Read Function - Read Input from STDIN and Store in a variable in =input.
_read:
	mov r0, #0				@ file descriptor for stdin
	mov r2, #1				@ allocates bytes to read
	mov r7, #3				@ svc read
	ldr r1, =input			@ load the address of the =input variable
	str r0, [r1]			@ reset input
	svc 0
	ldrb r1, [r1]			@ read byte in input
	bx lr
  
@ Check Function - Checks if the user input is valid and branches accordingly.  
_check:
	cmp r1, #'R'    		@ Run
	beq _run
	cmp r1, #'L'    		@ Lap
	beq _lap
    cmp r1, #'S'    		@ Stop
    beq _stop
    cmp r1, #'C'    		@ Clear
    beq _clear
	bx   lr					@ Return to tracking time
      
@ Run Function - Sets the program to run and stop lapping.
_run:
	mov r5, #1				@ Set Run Flag = 1
	mov r6, #0				@ Set Lap Flag = 1
	bx lr					@ Return to tracking time
      
@ Lap Function - Makes the Program Start Lapping, aka, stop printing.
_lap:
	mov r6, #1				@ Set Lap Flag = 1
	bx   lr					@ Return to tracking time
  
@ Stop Function - Stops the Program from tracking time, basically just stops the run function.  
_stop:
	mov r5, #0				@ Set Run Flag = 0
	mov r7, #1
	bx lr					@ Return to tracking time
	
_stop_print:
	mov r7, #0
	b print
	
@ Clear Function - Stops the Program with the Run Flag and Sets Variables to 0.
_clear:
	mov r5, #0 				@ Set Run Flag = 0
	mov r7, #1
	ldr r3, =iterations		@ Loads the Address of the Variables into r3
    
    str r5, [r3]			@ Stores 0 in the X0:00:00 Variable
    str r5, [r3, #4]		@ Stores 0 in the 0X:00:00 Variable
    str r5, [r3, #8]		@ Stores 0 in the 00:X0:00 Variable
    str r5, [r3, #12]		@ Stores 0 in the 00:0X:00 Variable
    str r5, [r3, #16]		@ Stores 0 in the 00:00:X0 Variable
    str r5, [r3, #20]		@ Stores 0 in the 00:00:0X Variable
    
	bx  lr					@ Return to tracking time
    
@ Start Function - Main Loop that will continually run, it only leaves to h1 when the Run Flag is Set to 1.
_start:	
	LDR 	r4, =iterations	@ Loads address of the variables
	MOV 	r3, #0			
	STR 	r3, [r4]		@ Sets Decaminutes Variable to Zero (Edge Case)

l1:	ldr	r3, =8900000		@ r3 = 8,900,000 
l2:	subs	r3, r3, #1		@ r3 = r3 – 1, decrement r1 
	bne	l2					@ repeat it until r3 = 0 
	
	bl _read				@ Poll the User
	bl _check				@ Check User Input
	cmp r5, #1				@ Checks if the program is running
	beq _h1					@ Branch if so
	cmp r7, #1
	beq _stop_print
	b l1					@ Loop again if not so
   
@ H1 Function - Increments the centisecond variable (00:00:0X) until it reaches 10 and then branches to _h2.
_h1:
    ldr 	r3, =iterations		@ Loads the Address of the Variables into R1
    ldr 	r3, [r3, #20]		@ Loads the Centisecond Variable into R1
    adds 	r3, #0x1			@ Increments R1
    ldr 	r4, =iterations		
    str 	r3, [r4, #20]       @ Stores the incremented value of R1 into the Centiseconds Variable
        
	CMP 	r3, #10				@ Sees if it has reached 10 loops.
    beq 	_h2					@ If so, branches to _h2.
        
    cmp 	r6, #1				@ Is it lapping?
	beq 	l1					@ If so, branch and do not print.
    b		print				@ Prints 
        
@ H2 Function - Increments the decisecond variable (00:00:X0) until it reaches 6 and then branches to _s1.
_h2:
	mov 	r3, #0				
	str 	r3, [r4, #20]		@ Stores the value Zero in the Centiseconds Variable (00:00:0X)
		
	ldr	    r3, =iterations			
    ldr 	r3, [r3, #16]		@ Loads the Value in the Decisecond Variable into r3
    adds 	r3, #0x1
    ldr 	r4, =iterations
    str 	r3, [r4, #16]       @ Stores the incremented value of r3 into the Deciseconds Variable
        
	cmp 	r3, #10
    beq 	_s1
        
	cmp 	r6, #1				@ Is it lapping?
	beq 	l1					@ If so, branch and do not print.
    b		print				@ Prints 
	
	
@ The _s1 function resets the decisecond variable, increments the second variable until it reaches 10, and then branches to _s2.
_s1:

	mov 	r3, #0
	str 	r3, [r4, #16]		@ Stores the value Zero in the Deciseconds Variable
	
	ldr 	r3, =iterations
    ldr 	r3, [r3, #12]		@ Loads the Second into R1
    adds 	r3, #0x1			
    ldr 	r4, =iterations
    str 	r3, [r4, #12]       @ Stores the incremented value of r3 into the Seconds Variable
        
	cmp 	r3, #10
    beq 	_s2
        
	cmp 	r6, #1				@ Is it lapping?
	beq 	l1					@ If so, branch and do not print.
    b		print				@ Prints 

@ The _s2 function resets the second variable, increments the decasecond variable until it reaches 10, and then branches to _m1.
_s2:
	mov 	r3, #0
	str 	r3, [r4, #12]		@ Stores the value Zero in the Seconds Variable
	
	ldr 	r3, =iterations
    ldr 	r3, [r3, #8]		@ Loads the Decasecond into R1
    adds 	r3, #0x1			
    ldr 	r4, =iterations
    str 	r3, [r4, #8]        @ Stores the incremented value of R1 into the Decaseconds Variable
        
	cmp 	r3, #6
    beq 	_m1
        
	cmp 	r6, #1				@ Is it lapping?
	beq 	l1					@ If so, branch and do not print.
    b		print				@ Prints 

@ The _m1 function resets the decasecond variable, increments the hectosecond variable until it reaches 10, and then branches to _start.
_m1:
	mov 	r3, #0
	str 	r3, [r4, #8]		@ Stores the value Zero in the Decaseconds Variable  
	
	ldr 	r1, =iterations
    ldr 	r1, [r1, #4]		@ Loads the minutes variable into R1
    adds 	r1, #0x1			
    ldr 	r2, =iterations
    str 	r1, [r2, #4]        @ Stores the incremented value of R1 into the Hectoseconds Variable
        
	cmp 	r1, #10	 
	beq 	_m2
	
	cmp 	r6, #1				@ Is it lapping?
	beq 	l1					@ If so, branch and do not print.
    b		print				@ Prints 

@ The _m2 function resets the minutes variable, increments the decaminutes variable until it reaches 6, and then branches to _start.
_m2:
	mov 	r3, #0
	str 	r3, [r4, #4]		@ Stores the value Zero in the Minutes Variable  
	
	ldr 	r1, =iterations
    ldr 	r1, [r1]			@ Loads the decaminutes variable into R1
    adds 	r1, #0x1			
    ldr 	r2, =iterations
    str 	r1, [r2, #4]        @ Stores the incremented value of R1 into the Hectoseconds Variable
        
	cmp 	r1, #6	 
	beq 	_start
	
	cmp 	r6, #1				@ Is it lapping?
	beq 	l1					@ If so, branch and do not print.
    b		print				@ Prints 


print: 
@ print time

	ldr 	r0, =string         	@ Load the String Format Location in R0
    ldr 	r1, =iterations		@ Load Address of the Variables into R1
    ldr 	r1, [r1]            	@ Load the Decaminutes variable
    bl 	    printf			@ Print and wipe the Registers
	
	ldr 	r0, =string         	
    ldr 	r1, =iterations		
    ldr 	r1, [r1, #4]        	@ Load the minutes variable
    bl 	    printf

	ldr 	r0, =colon          	@ Load the Colon String in R0
    bl 	    printf

	ldr 	r0, =string         	
    ldr 	r1, =iterations		
    ldr 	r1, [r1, #8]            @ Load the deaseconds variable
    bl   	printf
	
	ldr 	r0, =string         	
    ldr 	r1, =iterations		
    ldr 	r1, [r1, #12]           @ Load the seconds variable
    bl 	    printf
	
	ldr 	r0, =colon         	@ Load the Colon String in R0
    bl 	    printf
	
	ldr 	r0, =string         	
    ldr 	r1, =iterations		
    ldr 	r1, [r1, #16]           @ Load the deciseconds variable
    bl 	    printf

    ldr 	r0, =string         	
    ldr 	r1, =iterations		
    ldr 	r1, [r1, #20]           @ Load the centiseconds variable
    bl   	printf
    
	ldr 	r0, =newline         	@ Load the newline character in R0
    bl 	    printf
    
	b 	l1


@ Used to exit but will never be reached	
_exit:
        mov r7, #1
        svc 0


@ Data and Variables
.data
string:
        .asciz "%d"			@ Printable Number Format
colon:
	.asciz ":"			@ Printable Colon
newline:
	.asciz "\n"			@ Printable New Line Character
iterations:
        .word 0, 0, 0, 0, 0, 0  	@ Variables for Clock in order of: MM:SS:HH
inputform:
        .asciz "%d"
input:
        .word 0
