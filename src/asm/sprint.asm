; ******************************************************************************
; String Print - Send a string of text to the printer
;
; Copyright (c) 2021 by Gaston Williams
;
; ******************************************************************************
#include  ops.inc
#include  bios.inc
#include  kernel.inc

; ==============================================================================
; Reserved CPU registers
; R0            Pointer to the DMA buffer
; R1            Interrupt vector
; R2            Main stack pointer
; R3            Main program counter
; R4            Program counter for standard call procedure
; R5            Program counter for standard return procedure
; R6            Temporary values for standard call/return procedures
; RE.0          Used by Elf/OS to store accumulator in call procedures
; RE.1          Used by Elf/OS for baud rate
; ==============================================================================

; ************************************************************
; This block generates the Execution header
; It occurs 6 bytes before the program start.
; ************************************************************
                      ORG     02000h-6  ; Header starts at 01ffah
                    dw  02000h          ; Program load address
                    dw  endrom-2000h    ; Program size
                    dw  02000h          ; Program execution address

                      ORG     02000h    ; code starts here
                    BR  start           ; Jump past build info to code

; Build information
binfo:              db  80H+10      ; Month, 80H offset means extended info
                    db  21          ; Day
                    dw  2021        ; Year

                    ; Current build number
build:              dw  1

                    ; Must end with 0 (null)
                    db  'Copyright 2021 Gaston Williams',0

; ==============================================================================
; Main
; ==============================================================================

start:              lda  ra                 ; move past any spaces
                    smi  ' '
                    bz   start
                    dec  ra                 ; move back to non-space character
                    ldn  ra                 ; check for nonzero byte
                    lbnz good               ; jump if non-zero
                    LOAD rf, usage          ; print information on command
                    CALL O_MSG
                    LOAD rf, helptxt
                    CALL O_MSG     
                    LBR O_WRMBOOT           ; return to os
                          
good:               ldi     1Bh             ; send 'ESC @' printer command  
                    CALL    O_PRINT         ; to wake and reset the printer
                    ldi     '@'             ; back to default text values
                    CALL    O_PRINT
                    
                    ldi     0FFh            ; load invalid value before checking status
                    CALL    O_PRTSTAT       ; check printer ready
                    bz      ready           ; non-zero means not available
          
                    LOAD    rf, unavail     ; show unavailable message and exit
                    CALL    O_MSG 
                    lbr     O_WRMBOOT       ; exit to Elf/OS
                    
ready:              ldi     0Ah             ; start printing on new line
                    CALL    O_PRINT         

                    copy ra, rf             ; save start of string
find_end:           lda  ra                 ; get byte from argument
                    smi  31                 ; check for non-printable character
                    lbdf find_end           ; repeat until end of string
                    dec  ra                 ; move back to end of string                    
                    ldi  13                 ; add carriage return to end 
                    str  ra
                    inc  ra
                    ldi  10                 ; next, add line feed 
                    str  ra
                    inc  ra              
                    ldi  0                  ; then terminate with a null  
                    str  ra 
                    
outchar:            lda  rf
                    lbz  done
                    CALL O_PRINT
                    lbr  outchar
                  
done:               RETURN                  
                        
usage:     db 'Usage: sprint text',10,13,0
helptxt:   db "'sprint \e?' will print help text on the printer.",10,13,0 
unavail:   db 'Printer not ready.',10,13,0                                                                
;-------------------------------------------------------------------------------
; define end of execution block
endrom: EQU     $
