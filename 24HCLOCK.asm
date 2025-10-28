; ASSESSMENT 2 - 24H DIGITAL CLOCK
; JACK DU BOULAY - 32712899
; DATE DUE - 02/11/25
;
; /// PROGRAM INFORMATION ///
; INSTRUCTIONS:	
; For the program to run correctly, the user is required to input the following values at variables:
; 		- seconds 	values: (00-59) 
; 		- minutes 	values: (00-59)
; 		- hours 	values: (00-23)
; 		- ANY/ALL	values: (q - Q) <- this detects at any position in all variables to quit the program early.
;
; ABOUT:
; Upon successful insertion of values, the clock will run for 12 hours or 43200 seconds printing each increment into the console.
;
; Users of CLI programs can make mistakes so i've implemented a rudimentary try-catch solution
; providing an error message that requests the user to re-insert the correct values or enter 'q' to quit.

; DEFINE PROGRAM 
TITLE DIGITAL_CLOCK_24H
.MODEL SMALL
.STACK 100H

; DEFINITIONS
.DATA
	; Debug
	debug_error				db 	"An error has occured$" 
	
	; Messages
	msg_nextline 			db 	13, 10, '$'	; '/n'
	msg_program_run			db 	"<<< DIGITAL CLOCK PROGRAM >>>", 						13, 10, '$'
	msg_program_about		db 	"  Please insert the following:", 						13, 10
								db	"    -> Numeric values  (0-9) to set start time.", 	13, 10
								db	"    -> Character values 'q'  to quit program.", 	13, 10, '$'
	msg_program_success		db	"<<< Program completed successfully >>>$"
	msg_terminate_program	db	" -> User has chosen to quit program.$"
	msg_seconds   			db 	"Enter seconds (00-59):$"
	msg_minutes   			db 	"Enter minutes (00-59):$"
	msg_hours    			db 	"Enter hours   (00-23):$"
	msg_input_error   		db 	"INVALID VALUES - Please insert correct values or enter 'q' to quit.$"
	
	; Variables
	var_order_position		db 	0						; 0 = seconds, 1 = minutes, 2 = hours
	var_input 				db 	3, 0, 4 DUP('$')		; User input variable -> detects for 3 characters [xy(enter)]
	var_string 				db 	"hh:mm:ss$" 			; 
	var_compare				db	9						; Comparison variable 
	var_string_position		db  0						; [hh:mm:ss$] = [01:34:67$]
	var_terminate_program	db	0						; Determines program to terminate at value >= 1	"user chose to quit"			
	var_input_error			db 	0						; Throws an error if var > 0 
	var_max					db 	0						; This variable controls limits for user input and the clock function
	var_clock_second 		db 	1						; This represent a second that is applied to cell positions going right to left
	var_program_time		dw	43200					; 12 hours in seconds
	
	; Constants
	CONST_MIN 				db 	0						; Comparison const - No negative values
	
.CODE
main PROC
	
	MOV AX,@DATA			; loads the address of data segment (AX 'Accumulator' temporarily holds it)
	MOV DS,AX				; Copies segment address from AX into DS (Data Segment register)
	
	CALL MSGProgramRun		
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
		CALL MSGProgramSuccess
		MOV AH,4Ch                              
		INT 21h  
main ENDP

; ############################
; ##### PROGRAM MESSAGES #####
; ############################

; MESSAGE: Program is running
MSGProgramRun PROC
	CALL MSGNextLine
	LEA DX, msg_program_run	
	MOV AH, 09h				
	INT 21h			
	RET						
MSGProgramRun ENDP

; MESSAGE: About program
MSGProgramAbout PROC
	LEA DX, msg_program_about
	MOV AH, 09h				
	INT 21h			
	RET						
MSGProgramAbout ENDP

; MESSAGE: Program Success
MSGProgramSuccess PROC
	CALL MSGNextLine
	CALL MSGNextLine
	LEA DX, msg_program_success	
	MOV AH, 09h				
	INT 21h			
	RET						
MSGProgramSuccess ENDP

; MESSAGE: Quit program
MSGQuitProgram PROC
	CALL MSGNextLine
	CALL MSGNextLine
	LEA DX, msg_terminate_program	
	MOV AH, 09h				
	INT 21h			
	RET						
MSGQuitProgram ENDP

; MESSAGE: Go to next line "/n"
MSGNextLine PROC
	LEA DX, msg_nextline	
	MOV AH, 09h				
	INT 21h					
	RET						
MSGNextLine ENDP

; MESSAGE: GET SECONDS
MSGGetSeconds PROC
	CALL MSGNextLine
	LEA DX,msg_seconds			
	MOV AH,09h				
	INT 21h					
	RET						
MSGGetSeconds ENDP

; MESSAGE: GET MINUTES
MSGGetMinutes PROC
	CALL MSGNextLine
	LEA DX,msg_minutes			
	MOV AH,09h				
	INT 21h					
	RET						
MSGGetMinutes ENDP

; MESSAGE: GET HOURS
MSGGetHours PROC
	CALL MSGNextLine
	LEA DX,msg_hours	
	MOV AH,09h				
	INT 21h					
	RET						
MSGGetHours ENDP

; MESSAGE: INPUT ERROR
MSGInputError PROC
	CALL MSGNextLine	
	CALL MSGNextLine	
	LEA DX, msg_input_error
	MOV AH, 09h				
	INT 21h		
	RET						
MSGInputError ENDP

; DEBUG MESSAGE: General error
DebugError PROC
	CALL MSGNextLine
	LEA DX, debug_error
	MOV AH, 09h				
	INT 21h				
	RET						
DebugError ENDP

; ######################
; ##### END REGION #####
; ######################

; #######################
; ##### USER INPUTS #####
; #######################

GetUserInputs PROC
check_order_position:
	MOV var_input_error, 0		; reset to default value

	MOV BL, var_order_position	; Determines position of inputs
	CMP BL, 1					; Positions: 0 = Seconds, 1 = minutes, 2 = hours 
	JL	position_seconds
	JE	position_minutes
	JG	position_hours
	
	
	position_seconds:
		CALL MSGGetSeconds
		MOV var_string_position, 6	
		
		CALL UserInput
		
		MOV  var_max, 5
		CALL InputCompareToMax1
		
		MOV  var_max, 9
		CALL InputCompareToMax2
		
		JMP validate_input
	
	position_minutes:
		CALL MSGGetMinutes
		MOV var_string_position, 3	
	
		CALL UserInput
		
		MOV  var_max, 5
		CALL InputCompareToMax1
		
		MOV  var_max, 9
		CALL InputCompareToMax2
		
		JMP validate_input
		
		
	position_hours:
		; This stops get hours after inserting valid values for hours - it loops twice 
		CMP BL, 2
		JG inputs_return_main
		
		CALL MSGGetHours
		MOV var_string_position, 0
		
		CALL UserInput
		
		LEA BX, var_input
		MOV AH, [BX + 2]
		SUB AH, 48
		CMP AH, 1
		JLE	hours_zeroteen
		JG	hours_twenty
		
		hours_twenty:
			MOV  var_max, 2
			CALL InputCompareToMax1
		
			MOV  var_max, 3				
			CALL InputCompareToMax2
			JMP  validate_input
		
		hours_zeroteen:
			MOV  var_max, 1
			CALL InputCompareToMax1
		
			MOV  var_max, 9				
			CALL InputCompareToMax2
			JMP validate_input
	
	validate_input:
	
		MOV BL, var_terminate_program	; Check to quit program before accepting input
		CMP BL, 1
		JGE inputs_return_main
		
		MOV BL, var_input_error
		CMP BL, 1
		JGE invalid_input
		
		INC var_order_position
		JMP check_order_position
	
	invalid_input:
		CALL MSGInputError
		JMP check_order_position
	
	inputs_return_main:			
		RET
	
GetUserInputs ENDP

InputCompareToMax1 PROC
	LEA BX, var_input
	MOV AH, [BX + 2]
	CALL UserInputValidator
	CALL InsertIntoString
	RET
InputCompareToMax1 ENDP

InputCompareToMax2 PROC
	LEA BX, var_input
	MOV AH, [BX + 3]
	CALL UserInputValidator
	CALL InsertIntoString
	RET
InputCompareToMax2 ENDP

; Get user input
UserInput PROC
	LEA DX, var_input
	MOV AH, 0Ah   			; Line Feed - input   
	INT 	21h 				
    CMP AH,	0Dh			; check if user pressed enter
	RET
UserInput ENDP


UserInputValidator PROC
	; Quit program 
	CMP AH, 81			
	JE	return_quit_progam
	CMP AH, 113			
	JE	return_quit_progam

	; Comparison of true value
	SUB AH, 48
	MOV BL, AH	
	
	; Make sure the value is a number between 0-9
	CMP BL, CONST_MIN
	JL	return_invalid_input
	CMP BL, var_max
	JG	return_invalid_input

	; Insert input into var_string
	ADD AH, 48
	RET

	return_invalid_input:
		MOV var_input_error, 1
		;CALL MSGInputError
		RET
	
	return_quit_progam:
		MOV var_terminate_program, 1
		RET
	
UserInputValidator ENDP

InsertIntoString PROC
	LEA BX, var_string 
		
	MOV DL, AH
		
	MOV AL, var_string_position
	MOV AH, 0
	MOV SI, AX	; Source Index - convert byte to word
	MOV [BX + SI], DL
	
	INC var_string_position
	
	MOV AH, DL
	
	RET
InsertIntoString ENDP

; ######################
; ##### END REGION #####
; ######################

; ###########################
; ##### CLOCK FUNCTIONS #####
; ###########################

; MESSAGE: Displays clock in CLI
DisplayClock PROC
	CALL 	MSGNextLine
	LEA 	DX, var_string 		
	MOV 	AH, 09h				
	INT 	21h					
	RET		
DisplayClock ENDP

; For/while loop:  for(var_program_time > 0; i--) 
ClockFunction PROC
	GoToNextSecond:
		MOV AX, var_program_time
		CMP AX, 0
		JE	LimitReached
	
		MOV var_clock_second, 1
		Call ClockUpdate
		CALL DisplayClock
		
		DEC var_program_time
		JMP GoToNextSecond
		
	LimitReached:	; Program time reached -> exit program
		RET
ClockFunction ENDP

ClockUpdate PROC
	LEA BX, var_string 
	
	; Going backwards... [hh:mm:ss]	[01:34:67]
	CalculateSeconds:					
		MOV var_string_position, 7		
		
		MOV var_max, 9
		CALL Calculate					 
		
		MOV var_max, 5
		CALL Calculate	

	CalculateMinutes:
		DEC var_string_position		; MOV var_string_position, 4	
		
		MOV var_max, 9
		CALL Calculate					 
		
		MOV var_max, 5
		CALL Calculate	
	
	CalculateHours:
		DEC var_string_position		; MOV var_string_position, 1
		
		MOV AH, [BX]		 
		SUB AH, 48
		CMP AH, 1
		JLE 	BelowTwenty 
		JG 		AboveTwenty	
		
		BelowTwenty:		; [1] 
			MOV var_max, 9	; (00 - 19)
			CALL Calculate
			
			JMP FirstPosition
		
		AboveTwenty:		; [1]
			MOV var_max, 3	; (20 - 23)
			CALL Calculate
	
		FirstPosition:		; [0]
			MOV var_max, 2	; it will tick over to 20:00:00 if it hits 19:59:59
			CALL Calculate
	
			RET

ClockUpdate	ENDP

Calculate PROC
	; This checks if we have a clock second to add to the string
	MOV AL, var_clock_second
	CMP AL, 1
	JL	SkipToNextCell

	MOV AL, var_string_position
	MOV AH, 0
	MOV SI, AX
	
	MOV AH, [BX + SI]
	SUB AH, 48
	
	;MOV AL, var_clock_second
	ADD AH, 1 ;AL
	
	; If AH > MAX, then we go to next position for comparison
	CMP AH, var_max
	JG	GoToNextCell		
	
	; If AH <= MAX add the value back and set the var_clock_seconds to 0
	ADD AH, 48
	DEC var_clock_second
	MOV DL, AH
	
	JMP UpdateString
	
	; If the number exceeds the max, then we need to set this value to 0
	GoToNextCell:					
		MOV DL, 48	
	
	UpdateString:
		MOV AL, var_string_position
		MOV AH, 0
		MOV SI, AX
		MOV [BX + SI], DL
		DEC var_string_position
		RET
	
	; No seconds = return ASAP
	SkipToNextCell:
		RET
		
Calculate ENDP

; ######################
; ##### END REGION #####
; ######################

END MAIN
