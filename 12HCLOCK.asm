; ASSESSMENT 2 - 12H DIGITAL CLOCK
; JACK DU BOULAY - 32712899
; DATE DUE - 02/11/25

; /// PROGRAM INFORMATION ///
; INSTRUCTIONS:	
; For the program to run correctly, the user is required to input the following values:
; 		- seconds 	values: (0-9) 
; 		- minutes 	values: (0-9)
; 		- hours 	values: (0-9)
; 		- ANY/ALL	values: (Q or q) <- if q is detected in variables then quit program early.
; 
; ABOUT:
; Upon insertion of valid values, the clock will run for 12 hours (43199 seconds) printing each increment into the console.
;
; Users of CLI programs can/will make mistakes so i've implemented a rudimentary try-catch solution
; providing an error message that requests the user to re-insert the valid values or enter 'q' to quit.
;
; The AX & DX register values in my program are not typically 'preserved'
;
; USEFUL INFO:
; https://www.commfront.com/pages/ascii-chart
; https://www.eecg.utoronto.ca/~amza/www.mindsec.com/files/x86regs.html 

TITLE DIGITAL_CLOCK_12H
.MODEL SMALL					; Code segment: 1, 		Data segment: 1
.STACK 100H						; Workspace: 256 bytes 

.DATA
	; CONSTANTS
	CONST_MIN0 				equ 0						; EQU (equate) is ideal for constants as its
	CONST_MAX9 				equ 9						; not stored in memory and can be inherited directly
	CONST_MAX5				equ 5
	CONST_MAX1				equ 1
	CONST_TIME				equ 43199					; 12 hours = 43200 seconds, but they want: "start time 01:02:01, the clock will stop at 01:02:00"

	; /// GLOBAL VARIABLES ///
	global_clock_display 	db 	"0h:0m:0s$" 			; [0Z:0Y:0X]
	
	; input function vars
	var_order_input			db 	0						; 0 = sec, 1 = min, 2 = hr
	var_user_input 			db 	2, 0, 3 DUP('$')		; User input variable -> detects for 3 characters [xy(enter)]
	var_terminate_program	db	0						; Determines program to terminate at value >= 1	"user chose to quit"			

	; clock function vars
	var_clock_second 		db 	1						; Applied right to left
	var_clock_max			db 	0						; This variable controls limits for the clock function

	; /// MESSAGES
	msg_nextline 			db 	13, 10, '$'
	msg_prgrm_strt			db 	"<<< DIGITAL CLOCK PROGRAM >>>", 13, 10, '$'
	msg_prgrm_abt			db 	"  Please insert the following:", 13, 10
								db	"    -> Numeric values  (0-9) to set start time.", 13, 10
								db	"    -> Character values 'q'  to quit program.", 13, 10, '$'
	msg_prgrm_exit			db	"<<< Program exited successfully >>>$"
	msg_prgrm_term			db	" -> User has chosen to quit program.$"
	msg_seconds   			db 	"Enter seconds (0-9):$"
	msg_minutes   			db 	"Enter minutes (0-9):$"
	msg_hours    			db 	"Enter hours   (0-9):$"
	msg_input_error   		db 	"INVALID VALUES - Please insert valid values or enter 'q' to quit.$"
	
	; /// DEBUG
	debug_error				db 	"An error has occurred.$"  ; not used in final product
	
.CODE
main PROC
	MOV AX,@DATA										; load data segment address 
	MOV DS,AX											; initialise DS with data segment

	CALL MSGProgramStart								
	CALL MSGProgramAbout	
	CALL GetUserInputs
	
	MOV AH, var_terminate_program
	CMP AH, 1
		JE ExitEarly
		
	CALL ClockFunction
	JMP Exit
	
	ExitEarly:
		CALL MSGQuitProgram
	
	Exit:    
		CALL MSGProgramExit
		MOV AH,4Ch                              
		INT 21h  
main ENDP

; ############################
; ##### PROGRAM MESSAGES #####
; ############################
; MESSAGE: Program start
MSGProgramStart PROC				
	CALL 	MSGNextLine				; Move cursor to next line before displaying current message
	LEA 	DX, msg_prgrm_strt		; Get message (Load Effective Address of string into DX)
	MOV 	AH, 09h					; Display string at DS:DX
	INT 	21h						; Interrupt to print string 
	RET								; Return to caller
MSGProgramStart ENDP				

; MESSAGE: About program
MSGProgramAbout PROC
	LEA 	DX, msg_prgrm_abt
	MOV 	AH, 09h				
	INT 	21h			
	RET						
MSGProgramAbout ENDP

; MESSAGE: Program Exit
MSGProgramExit PROC
	CALL 	MSGNextLine
	CALL 	MSGNextLine
	LEA 	DX, msg_prgrm_exit	
	MOV 	AH, 09h				
	INT 	21h			
	RET						
MSGProgramExit ENDP

; MESSAGE: Program terminate early
MSGQuitProgram PROC
	CALL 	MSGNextLine
	CALL 	MSGNextLine
	LEA 	DX, msg_prgrm_term	
	MOV 	AH, 09h				
	INT 	21h			
	RET						
MSGQuitProgram ENDP

; MESSAGE: Next line
MSGNextLine PROC
	LEA 	DX, msg_nextline	
	MOV 	AH, 09h				
	INT 	21h					
	RET						
MSGNextLine ENDP

; MESSAGE: GET SECONDS
MSGGetSeconds PROC
	CALL 	MSGNextLine
	LEA 	DX,msg_seconds			
	MOV 	AH,09h				
	INT 	21h					
	RET						
MSGGetSeconds ENDP

; MESSAGE: GET MINUTES
MSGGetMinutes PROC
	CALL 	MSGNextLine
	LEA 	DX,msg_minutes			
	MOV 	AH,09h				
	INT 	21h					
	RET						
MSGGetMinutes ENDP

; MESSAGE: GET HOURS
MSGGetHours PROC
	CALL 	MSGNextLine
	LEA 	DX,msg_hours	
	MOV 	AH,09h				
	INT 	21h					
	RET						
MSGGetHours ENDP

; MESSAGE: INPUT ERROR
MSGInputError PROC
	CALL 	MSGNextLine	
	CALL 	MSGNextLine	
	LEA 	DX, msg_input_error
	MOV 	AH, 09h				
	INT 	21h		
	RET						
MSGInputError ENDP

; MESSAGE: CLOCK 
DisplayClock PROC 
	CALL 	MSGNextLine	
	LEA 	DX, global_clock_display		
	MOV 	AH, 09h				
	INT 	21h				
	RET		
DisplayClock ENDP

; #######################
; ##### USER INPUTS #####
; #######################

GetUserInputs PROC
	check_order_position:
		MOV 	SI, OFFSET global_clock_display
		MOV 	AL, var_order_input	
		
		; If position >= 3 {return} - program received 3 valid user inputs
		CMP AL, 3
			JGE	return_to_main			
		
		; Determines jump by order position value 
		; Positions: 0 = sec, 1 = min, 2 = hr
		CMP AL, 1						
			JL	position_seconds
			JE	position_minutes
			JG	position_hours
	
	position_seconds:	
		ADD		SI, 7						; [hh:mm:sX]
		CALL 	MSGGetSeconds
			JMP validate_input
	
	position_minutes:
		ADD		SI, 4						; [hh:mY:ss]
		CALL 	MSGGetMinutes
			JMP validate_input
		
	position_hours:
		ADD		SI, 1						; [hZ:mm:ss]
		CALL 	MSGGetHours
			JMP validate_input
	
	validate_input:
		CALL 	UserInput					; Get the user input
		CALL 	UserInputValidator			; Validate the user input
		
		MOV 	AL, var_terminate_program	; Check to quit program before accepting input
		CMP AL, 1							; If AL = 1 -> exit 
			JE 	return_to_main			
		
		MOV [SI], AH						; Insert AH value to cell [SI] in clock string
			JMP check_order_position		
	
	return_to_main:
		RET
	
GetUserInputs ENDP

; Get user input
UserInput PROC
	LEA 	DX, var_user_input
	MOV 	AH, 0Ah   					; Line Feed  
	INT 	21h 				
	RET
UserInput ENDP

UserInputValidator PROC
	MOV 	BX, OFFSET var_user_input
	MOV 	AH, [BX + 2]
	
	CMP AH, 81							; 'Q'
		JE	return_to_inputs
	CMP AH, 113							; 'q'
		JE	return_to_inputs

	; subtract 48 to get true value
	SUB AH, 48							
	
	; if value is not between 0-9 inclusive, return with input error
	CMP AH, CONST_MIN0
		JL	return_invalid_input
	CMP AH, CONST_MAX9
		JG	return_invalid_input

	; Insert input into global_clock_display
	ADD AH, 48							; Revert back to char value
	INC var_order_input					; Move to next position
	RET

	return_invalid_input:
		CALL 	MSGInputError 				
		RET
	
	return_to_inputs:
		MOV 	var_terminate_program, 1
		RET
	
UserInputValidator ENDP

; ##########################
; ##### CLOCK FUNCTION #####
; ##########################

; For loop:  for(CONST_TIME > 0; i--) {update clock with +1 second}
; Formerly this loop used a cmp CX, 0 to exit the loop, using JNZ simplifies this logic
ClockFunction PROC
	MOV 	CX, CONST_TIME				; load total seconds to counter register
	ClockLoop:	
		MOV 	var_clock_second, 1		; Clock second set to 1
		PUSH AX
		PUSH SI
			CALL	ClockUpdate				; Go through each character position of the clock to add second
		POP SI
		POP AX
		CALL 	DisplayClock			; display clock in CLI after adding 1 second
		DEC 	CX						; decrement the total clock time
			JNZ ClockLoop				; better than using cmp to exit, JNZ (jump if not zero condition)
		RET
		
ClockFunction ENDP

; Function updates the global_clock_display -> char array value alteration 
; This function performs string manipulation based on position and value, from right to left 
ClockUpdate PROC
	MOV 	SI, OFFSET global_clock_display	; [SI] = cell 0
	ADD 	SI, 7							; [SI] = cell 7 <- Offset is now [SI+7]
	
	; Going right to left [hh:mm:ss]	cells: [01:34:67]
	CalculateSeconds:						
		MOV 	var_clock_max, CONST_MAX9		; cell [7] max = 9
		CALL 	Calculate					 
		MOV 	var_clock_max, CONST_MAX5		; cell [6] max = 5
		CALL 	Calculate	
		DEC 	SI								; skip cell [5]
		
	CalculateMinutes:
		MOV 	var_clock_max, CONST_MAX9		; cell [4] max = 9
		CALL 	Calculate					 
		MOV 	var_clock_max, CONST_MAX5		; cell [3] max = 5
		CALL 	Calculate	
		DEC		SI								; skip cell [2]
		
	CalculateHours:
		MOV 	AH, [SI - 1]				; get value at cell [0]
		SUB 	AH, 48						; get true value
		CMP AH, 1							; compare true value to 1
			JL 	BelowTen
			JGE AboveTen
		
		BelowTen:						
			MOV 	var_clock_max, CONST_MAX9	; cell [1] max = 1
			CALL 	Calculate
			JMP 	FirstPos
		
		AboveTen:						
			MOV 	var_clock_max, CONST_MAX1	; cell [1] max = 1
			CALL 	Calculate
	
		FirstPos:								
			MOV 	var_clock_max, CONST_MAX1	; cell [0] max = 1
			CALL 	Calculate					; tick over 11:59:59 -> 00:00:00
			RET

ClockUpdate	ENDP

Calculate PROC
	; If (clock second != 1) 
	MOV 	AL, var_clock_second
	CMP AL, 1
		JL	SkipToNextCell
		
	; If (clock second == 1) 
	MOV 	AH, [SI]
	SUB 	AH, 47		; sub 47 adds +1 to the true value						
	
	; If (AH + 1 > MAX) 
	CMP AH, var_clock_max	; the clock max value is determined, prior to the calculate call.
		JG	GoToNextCell		
	
	; If (AH + 1 <= MAX) 
	; {add char value to cell position and decrement clock second}
	ADD 	AH, 48
	DEC 	var_clock_second
	JMP 	UpdateString
	
	; If (AH + 1 > MAX) {set AH = 48} '0'
	GoToNextCell:					
		MOV 	AH, 48	
	
	UpdateString:
		MOV 	[SI], AH				; insert updated value to global_clock_display at offset 
		DEC 	SI						; decrement position offset 
		RET
	
	SkipToNextCell:
		RET
		
Calculate ENDP
END MAIN