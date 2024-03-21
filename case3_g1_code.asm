# include <P16F747.INC>
    __CONFIG _CONFIG1, _FOSC_HS & _CP_OFF & _DEBUG_OFF & _VBOR_2_0 & _BOREN_0 
    & _MCLR_ON & _PWRTE_ON & 

; Define your data section
uDATA
Temp res 1

; Start of code section
code

initPort
    clrf PORTB               ; Clear PORTB
    clrf PORTC               ; Clear PORTC
    bsf STATUS, RP0          ; Switch to Bank 1 for TRIS registers
    clrf TRISB               ; Set all PORTB as output
    movlw 0xFF               ; Set all pins of PORTC as input (for button presses)
    movwf TRISC
    movlw 0x00               ; Set all pins of PORTD as output (for transistor control)
    movwf TRISD
    bcf STATUS, RP0          ; Switch back to Bank 0
    return

    ; Wait for either the green or red button press
waitPress 
    btfsc PORTC, 7           ; Check if green button is pressed (active low)
    goto GreenPress
    btfsc PORTC, 6           ; Check if red button is pressed (active low)
    goto RedPress
    goto waitPress           ; No button press detected, loop back

    ; Handle green button press
GreenPress
    call SwitchDelay          ; Debounce delay
    btfss PORTC, 7           ; Check if green button is still pressed
    goto RedPress            ; If not, check red button

    ; Turn off the transistor (active high control assumed)
TransistorOff
    clrf PORTD               ; Clear PORTD to turn off the transistor
    goto waitPress           ; Return to wait for button press

    ; Handle red button press
RedPress
    call SwitchDelay         ; Debounce delay
    btfsc PORTC, 6           ; Check if red button is still pressed
    goto RedRelease          ; If pressed, handle red button release

    ; Wait for red button release
RedRelease
    btfss PORTC, 6           ; Check if red button is released
    goto RedRelease          ; Loop here until red button is released
    goto TransistorToggle    ; Proceed to toggle transistor

    ; Toggle the state of the transistor
TransistorToggle
    movf PORTD, W            ; Move the contents of PORTD to W register
    xorlw 0x01               ; Toggle the least significant bit
    movwf PORTD              ; Move the result back to PORTD
    goto waitPress           ; Return to wait for button press

    ; Delay routine for debouncing the switches
SwitchDelay
    movlw 20                ; Load W with the delay count
    movwf Temp              ; Move W to Temp register
delay
    decfsz Temp, F          ; Decrement Temp until it's 0
    goto delay              ; Repeat the loop until Temp is 0
    return


end                 ; End of the file
