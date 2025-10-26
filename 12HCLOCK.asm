; funct test


; DEFINE PROGRAM 
TITLE InsertingValuesToAString
.MODEL SMALL
.STACK 100H

; DEFINITIONS
.DATA
	; Debugging
	debug_input_error   	db 	"INVALID VALUES$"
	debug_error				db 	"An error has occured$"
	
	; Program messages
	msg_program_run			db 	"Insert Values between (0-9)$"
	msg_quit_program		db	"User has chosen to quit program.$"
	msg_nextline 			db 	13,10,'$'
	msg_seconds   			db "Enter seconds (0-9):$"
	msg_minutes   			db "Enter minutes (0-9):$"
	msg_hours    			db "Enter hours (0-9):$"
	
	; Variables
	var_order_position		db 	0
	var_input 				db 	2, 0, 3 DUP('$')		; 
	var_string 				db 	"hh:mm:ss$" 			;  1, 4, 7 
	var_string_position		db  1						; string positions = [23:56:89$]
	var_terminate_program	db	0						; Determines program to terminate at value >= 1				
	
	; Constants
	CONST_MIN 				db 	0
	CONST_MAX 				db 	9
	
.CODE
main PROC
	
	; DISPLAY PROMPT
	; MOV DESTINATION, SOURCE
	MOV AX,@DATA			; loads the address of data segment (AX 'Accumulator' temporarily holds it)
	MOV DS,AX				; Copies segment address from AX into DS (Data Segment register)
	
	CALL ProgramRun
	CALL GetUserInputs
	CALL DisplayTime
	
	Exit:    
		MOV AH,4Ch                              
		INT 21h  
main ENDP




; ############################
; ##### PROGRAM MESSAGES #####
; ############################

; DISPLAY MESSAGE - Go to next line
ProgramRun PROC
	LEA DX, msg_program_run	
	MOV AH, 09h				
	INT 21h			
	CALL NextLine
	RET						
ProgramRun ENDP

; DISPLAY MESSAGE - Go to next line
QuitProgram PROC
	LEA DX, msg_quit_program	
	MOV AH, 09h				
	INT 21h			
	CALL NextLine
	RET						
QuitProgram ENDP

; Go to next line
NextLine PROC
	LEA DX, msg_nextline	
	MOV AH, 09h				
	INT 21h					
	RET						
NextLine ENDP

; MESSAGE: GET SECONDS
GetSeconds PROC
	CALL NextLine
	LEA DX,msg_seconds			
	MOV AH,09h				
	INT 21h					
	RET						
GetSeconds ENDP

; MESSAGE: GET MINUTES
GetMinutes PROC
	CALL NextLine
	LEA DX,msg_minutes			
	MOV AH,09h				
	INT 21h					
	RET						
GetMinutes ENDP

; MESSAGE: GET HOURS
GetHours PROC
	CALL NextLine
	LEA DX,msg_hours	
	MOV AH,09h				
	INT 21h					
	RET						
GetHours ENDP

; Display Result
DisplayTime PROC
	CALL 	NextLine
	LEA 	DX, var_string			
	MOV 	AH, 09h				
	INT 	21h					
	RET		
DisplayTime ENDP

; ##########################
; ##### DEBUG MESSAGES #####
; ##########################

; DISPLAY DEBUG MESSAGE - Input error
DebugInputError PROC
	CALL NextLine	
	LEA DX, debug_input_error
	MOV AH, 09h				
	INT 21h		
	RET						
DebugInputError ENDP

DebugError PROC
	CALL NextLine
	LEA DX, debug_error
	MOV AH, 09h				
	INT 21h				
	RET						
DebugError ENDP

; #######################
; ##### USER INPUTS #####
; #######################

GetUserInputs PROC
check_order_position:
	;MOV BL, var_terminate_program
	;CMP BL, 1
	;JE	terminate_program

	MOV BL, var_order_position	; Determines position of inputs
	CMP BL, 1					; Positions: 0 = Seconds, 1 = minutes, 2 = hours 
	JL	position_seconds
	JE	position_minutes
	JG	position_hours
	
	
	position_seconds:
		MOV var_string_position, 7	
		CALL GetSeconds
		JMP validate_input
	
	position_minutes:
		CALL GetMinutes
		MOV var_string_position, 4	
		JMP validate_input
		
	position_hours:
		CMP BL, 4
		JG terminate_program		; get out of loop
		
		CALL Gethours
		MOV var_string_position, 1
		JMP validate_input
	
	validate_input:
		CALL UserInput
		CALL UserInputValidator
		
		MOV BL, var_terminate_program	; Check to quit program before accepting input
		CMP BL, 1
		JE terminate_program
		
		LEA BX, var_string				; Base 
		
		MOV DL, AH
		
		MOV AL, var_string_position
		MOV AH, 0
		MOV SI, AX	; Source Index - convert byte to word
		MOV [BX + SI], DL
		JMP check_order_position
	
	terminate_program:
	CALL QuitProgram
	RET
	
GetUserInputs ENDP

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
	LEA BX, var_input
	MOV AH, [BX + 2]
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
	CMP BL, CONST_MAX
	JG	return_invalid_input

	; Insert input into var_string
	ADD AH, 48
	INC var_order_position	; Move to next position
	RET

	return_invalid_input:
	CALL DebugInputError
	RET
	
	return_quit_progam:
	MOV var_terminate_program, 1
	RET
	
UserInputValidator ENDP

END MAIN
