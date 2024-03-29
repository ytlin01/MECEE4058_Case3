	list P = 16F747
	title "Case Study 3"
	
#include <P16F747.INC>

	__CONFIG _CONFIG1, _FOSC_HS & _CP_OFF & _DEBUG_OFF & _VBOR_2_0 & _BOREN_0 & _MCLR_ON & _PWRTE_ON & _WDT_OFF
	__CONFIG _CONFIG2, _BORSEN_0 & _IESO_OFF &_FCMEN_OFF

State equ 22h		    ; Program state register
Temp equ 23h		    ; Temporary register
Timer1 equ 24h
Timer2 equ 25h
Timer3 equ 26h
Timer equ 27h
Octal equ 30h		    ; Octal switch register
Mode equ 31h		    ; Mode register to set Mode
    
    org 00h		    ; interrupt vector
    goto SwitchCheck	    ; jump to interrupt service routine (dummy)
    org 04h		    ; interrupt vector
    goto isrService	    ; jump to interrupt service routine (dummy)
    org 15h

SwitchCheck
    call initPort
    
initPort
    clrf PORTB               ; Clear PORTB
    clrf PORTC               ; Clear PORTC
    clrf PORTD		    ; clear PORTD
    
    clrf State		    ; clear STATE register
    
    bsf STATUS, RP0          ; Set RP0 in STATUS register to 1 to select Bank 1
    clrf TRISB               ; Configure PORTB as all outputs (LEDs)
    movlw B'11111111'        ; Configure PORTC as all inputs (buttons)
    movwf TRISC
    movlw B'00111000'	    ; Configure PORTD as all outputs
    movwf TRISD
    movlw B'00001110'        ; Configure RA0 in ADCON1 as analog, else digital
    movwf ADCON1
    bcf STATUS, RP0          ; Switch back to Bank 0
    return

waitPress 
    btfsc PORTC, 0		; check if green button is pressed (bit 0 cleared)
    goto GreenPress		; if not pressed, goto GreenPress
    btfsc PORTC, 1		; check if red button is pressed (bit 1 cleared)
    goto RedPress		; if not, goto RedPress
    goto waitPress		; if neither, loop and wait for button press
    
GreenPress
    call SwitchDelay		; debounce delay
    btfss PORTC, 0		; check if green button is still pressed
    goto waitPress		; noise - return to waitPress
    
setMode
    clrf Mode			; clear MODE
    
    xorlw D'1'			; 
    btfsc STATUS,Z
    goto ModeOne
    movf Octal,W
    
    xorlw D'2'
    btfsc STATUS,Z
    goto ModeTwo
    movf Octal,W
    
    xorlw D'3'
    btfsc STATUS,Z
    goto ModeThree
    movf Octal,W
    
    xorlw D'4'
    btfsc STATUS,Z
    goto ModeFour
    
ModeOne
    bsf Mode,1		    ; initialize Mode 1
    goto waitPress

ModeTwo
    bsf Mode,2
    goto waitPress	    ; initialize Mode 2

ModeThree
    bsf Mode,3
    goto waitPress	    ; initialize Mode 3

ModeFour
    bsf Mode,4
    goto waitPress	    ; initialize Mode 4
    


RedPress
    call SwitchDelay         ; Debounce delay
    btfsc PORTC, 1           ; Check if red button is still pressed
    goto RedRelease          ; If pressed, handle red button release

    ; Wait for red button release
RedRelease
    btfss PORTC, 1           ; Check if red button is released
    goto RedRelease          ; Loop here until red button is released
    goto TransistorToggle    ; Proceed to toggle transistor

SwitchDelay
    movlw 20                ; Load W with the delay count
    movwf Temp              ; Move W to Temp register
delay
    decfsz Temp, F          ; Decrement Temp until it's 0
    goto delay              ; Repeat the loop until Temp is 0
    return


end                 ; End of the file
