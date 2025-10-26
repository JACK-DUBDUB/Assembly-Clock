
; DEFINE PROGRAM 
TITLE DigitalClockProgram
.MODEL SMALL
.STACK 100H

INCLUDE input_function.asm

; DEFINITIONS
.DATA
	var_clock_second 	db 	1
	;var_program_time	dw	43200

.CODE
main PROC
	
	; DISPLAY PROMPT
	; MOV DESTINATION, SOURCE
	MOV AX,@DATA			; loads the address of data segment (AX 'Accumulator' temporarily holds it)
	MOV DS,AX				; Copies segment address from AX into DS (Data Segment register)
	
	CALL ProgramRun
	CALL GetUserInputs
	CALL DisplayTime
	
	CALL ClockFunction
	
	Exit:    
		MOV AH,4Ch                              
		INT 21h  
main ENDP

DisplayClock PROC
	CALL 	NextLine
	LEA 	DX, var_string 		
	MOV 	AH, 09h				
	INT 	21h					
	RET		
DisplayClock ENDP

ClockFunction PROC
	
	GoToNextSecond:
		MOV var_clock_second, 1
		Call ClockUpdate
		
		
		
		
	QuitProgram:
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
		MOV var_string_position, 4		
		
		MOV var_max, 9
		CALL Calculate					 
		
		MOV var_max, 5
		CALL Calculate	
	
	CalculateHours:
		MOV var_string_position, 1
		
		MOV AH, [BX + 2]
		CMP AH, 1
		JE		
		
		BelowTen:
			MOV var_max, 9
			CALL Calculate
			
			MOV var_max, 1
			CALL Calculate
			
			RET
		
		AboveTen:
			MOV var_max, 2
			CALL Calculate
	
			MOV var_max, 1
			CALL Calculate
	
			RET

ClockUpdate	ENDP


Calculate PROC
	; This checks if we have a clock second to add to the string
	MOV AL, var_clock_second
	CMP AL, 1
	JL	GoToNext

	MOV AL, var_string_position
	MOV AH, 0
	MOV SI, AX
	
	MOV AH, [BX + SI]
	SUB AH, 48
	
	MOV AL, var_clock_second
	ADD AH, AL
	
	; If AH > MAX, then we go to next position for comparison
	CMP AH, var_max
	JG	GoToNext		
	
	ADD AH, 48
	MOV var_clock_second, 0		; Set clock seconds to 0
	;DEC	var_program_time
	MOV DL, AH
	JMP UpdateString
	
	; If the number exceeds the max, then we need to set this value to 0
	GoToNextCell:					
		MOV DL, 48	; this should be 48.... because 0 = 48
	
	UpdateString:
		MOV AL, var_string_position
		MOV AH, 0
		MOV SI, AX
		MOV [BX + SI], DL
		DEC var_string_position

		RET
	
	; No seconds means we try to return as fast as possible for the next iteration
	SkipToNextCell:
		RET
		
Calculate ENDP

END MAIN
