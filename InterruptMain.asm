 #include "configurationbits.h"
 
 CBLOCK 0X60
    Tcoin ; total acumulate coins
    delayvar:3
 ENDC 
 
 org 0
 goto main
 org 8
 goto CCPISR
 
main:
    call initmcu
    call initccp
here
    goto here
    bra main
    
initmcu:;Preparando el MCU
    clrf TRISC
    clrf LATC
    return
    
initccp: ;*************************************INITIAL CONFIGURATION CCP MODULE
    movlw 0x04 ;capture mode, falling edge
    movwf CCP1CON 
    clrf T3CON
    bsf TRISC,RC2 ; CCP1 as Input 
    bcf PIR1,CCP1IF
    bsf PIE1,CCP1IE; Enabling interrupt for CCP1
    bsf INTCON,PEIE; Enabling peripheral interrupts
    bsf INTCON,GIE; Enabling global interruptions
    return

CCPISR:;********************************************CCP INTERRUPT SERVICE RUTINE
    movlw 0x19
    call delayW0ms
    bcf PIR1,CCP1IF
    movlw b'00000001' ;* Prescalamiento de 4, Reloj interno,16bits off
    movwf T0CON
    movlw 57 
    movwf TMR0L
    movlw 9E
    movwf TMR0H
    bsf T0CON,TMR0ON ;Run
    bcf INTCON,TMR0IF 
bucle    btfsc INTCON,TMR0IF
    bra S200 ; Coin value =500 
    btfsc PIR1,CCP1IF
    bra S500; Coin value = 200
    goto bucle
    
S500;---------------------------------------------------------500 COIN SUBRUTINE
    movlw 0x05
    addwf Tcoin,F
    bcf PIR1,CCP1IF ; Clear Flag CCP1 Module
    retfie
    
S200;---------------------------------------------------------200 COIN SUBRUTINE
    movlw 0x02
    addwf Tcoin,F
    bcf PIR1,CCP1IF ; Clear Flag CCP1 Module
    retfie 
    
    
;***************************************************************DELAY SUBRUTINES   
delay10ms:  ;4MHz frecuency oscillator
    movlw d'84'  ;A Value
    movwf delayvar+1
d0:   movlw d'38' ;B Value
    movwf delayvar  
    nop
d1:  decfsz delayvar,F
    bra d1
    decfsz delayvar+1,F
    bra d0      
    return ;2+1+1+A[1+1+1+B+1+2B-2]+A+1+2A-2+2 => 5+A[5+3B]
    
delayW0ms: ;It is neccesary load a properly value in the acumulator before use this subrutine
    movwf delayvar+2
d2:    call delay10ms
    decfsz delayvar+2,F
    bra d2
    return
    
    END