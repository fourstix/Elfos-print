; *******************************************************************************************
; Vprint - Print the image in the display buffer
;
; Copyright (c) 2021 by Gaston Williams
; *******************************************************************************************
#include  ops.inc
#include  bios.inc
#include  kernel.inc

; ************************************************************
; Include the video definitions in the ROM
; ************************************************************                        
#include  video.inc                                          

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
                        ORG     02000h-6        ; Header starts at 01ffah
                    dw  02000h                  ; Program load address
                    dw  endrom-2000h            ; Program size
                    dw  02000h                  ; Program execution address

                        ORG     02000h          ; code starts here
                    br  start                   ; Jump past build info to code

; Build information
binfo:              db  80H+10           ; Month
                    db  21               ; Day
                    dw  2021             ; Year

                    ; Current build number
build:              dw  1

                    ; Must end with 0 (null)
                    db  'Copyright 2021 Gaston Williams',0


start:              CALL ValidateVideo    ; check if video is loaded                  
                    GLO  RF               ; RF.0 is zero if video loaded
                    BZ   loaded
                    LOAD RF, failed
                    CALL O_MSG
                    LBR  O_WRMBOOT        ; exit to Elf/Os


loaded:             ldi  1Bh              ; wake up and reset before printing
                    CALL O_PRINT          ; send 'ESC @' printer  
                    ldi  '@'              ; wake and reset to default text values
                    CALL O_PRINT
                    
                    ldi  0FFh             ; load invalid value before checking status
                    CALL O_PRTSTAT        ; check if Printer is available
                    bz   ready            ; non-zero means not available
          
                    LOAD rf, unavail      ; show unavailable message and exit
                    CALL O_MSG 
                    lbr  O_WRMBOOT        ; exit to Elf/OS
                    
ready:              ldi  0Ah              ; start printing on a new line 
                    CALL O_PRINT         
                    
                    LOAD R9, O_VIDEO      ; prepare the pointer to the video buffer
                    LDN  R9
                    PHI  RF
                    LDI  0
                    PLO  RF               ; video buffer address in RF      
                    LOAD RC, 512          ; Put count into RC
                    ldi  1Bh              ; send 'ESC *' printer  
                    CALL O_PRINT          ; to start 64x64 graphics mode
                    ldi  '*'         
                    CALL O_PRINT
                    
prt_img:            lda  rf               ; get a byte from buffer                              
                    CALL O_PRINT          ; print image byte
                    dec  rc               ; count down
                    ghi  rc               ; check hi byte of counter
                    bnz  prt_img          ; if non-zero keep going
                    glo  rc               ; check lo byte of counter
                    bnz  prt_img          ; if non-zero keep going                    

                    ldi  12               ; afterwards, print a form feed 
                    CALL O_PRINT          ; to eject paper for tear off                    
                    RETURN                ; return to Elf/Os
           
                    
           ;--- Message strings
unavail:   db      'Printer not ready.',10,13,0
errmsg:    db      'File Error',10,13,0
failed:    db      'Video is not loaded.',13,10,0

            ;------ define end of execution block
endrom:     equ     $
