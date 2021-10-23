; ******************************************************************************
; Print - Send a text file to the printer
;
; Copyright (c) 2021 by Gaston Williams
;
; ******************************************************************************
; Based on code written by Michael H Riley
; Original copyright notice:
; *******************************************************************
; *** This software is copyright 2004 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

#include  ops.inc
include   bios.inc
include   kernel.inc


; ************************************************************
; This block generates the Execution header
; It occurs 6 bytes before the program start.
; ************************************************************
      ORG     02000h-6      ; Header starts at 01ffah
          dw  02000h        ; Program load address
          dw  endrom-2000h  ; Program size
          dw  02000h        ; Program execution address

      ORG     02000h        ; code starts here
          BR  start         ; Jump past build info to code

      ; Build information
binfo:    db  80H+10        ; Month, 80H offset means extended info
          db  21            ; Day
          dw  2021          ; Year

      ; Current build number
build:    dw  1

                            ; Must end with 0 (null)
          db  'Copyright 2021 Gaston Williams',0

; ==============================================================================
; Main
; ==============================================================================
          
start:    lda     ra              ; move past any spaces
          smi     ' '
          lbz     start
          dec     ra              ; move back to non-space character
          COPY    ra, rf          ; copy argument address to rf

loop1:    lda     rf              ; look for first less <= space
          smi     33
          lbdf    loop1
          dec     rf              ; backup to char
          ldi     0               ; need proper termination
          str     rf
          COPY    ra, rf          ; back to beginning of name
          ldn     rf              ; get byte from argument
          lbnz    good            ; jump if filename given
          CALL    O_INMSG         ; otherwise display usage message      
          db      'Usage: print filename',10,13,0
          RETURN                  ; and return to os
          
good:     ldi     1Bh             ; send 'ESC @' printer  
          CALL    O_PRINT         ; command to wake printer
          ldi     '@'             ; and reset to default text values
          CALL    O_PRINT         ; 
          
          ldi     0FFh            ; load invalid value before checking status
          CALL    O_PRTSTAT       ; check Printer after reset
          bz      ready           ; non-zero means not available
          
          LOAD    rf, unavail     ; show unavailable message and exit
          CALL    O_MSG 
          lbr     O_WRMBOOT       ; exit to Elf/OS
                    
ready:    ldi     0Ah             ; start printing on a new line 
          CALL    O_PRINT         ; 

          LOAD    rd, fildes      ; get file descriptor
          ldi     0               ; flags for open
          plo     r7
          CALL    O_OPEN          ; attempt to open file
          lbnf    mainlp          ; jump if file was opened
          
          LOAD    rf, errmsg      ; get error message
          CALL    O_MSG           ; display it          
          lbr     O_WRMBOOT       ; and return to Elf/OS
          
mainlp:   ldi     0               ; want to read 16 bytes
          phi     rc
          ldi     16
          plo     rc 
          LOAD    rf, buffer      ; buffer to retrieve data

          CALL    O_READ          ; read the header
          glo     rc              ; check for zero bytes read
          lbz     done            ; jump if finished

          LOAD    r8, buffer      ; buffer to retrieve data

linelp:   lda     r8              ; get next byte
          CALL    O_PRINT         ; send to printer
          
          dec     rc              ; decrement read count
          glo     rc              ; see if done
          lbnz    linelp          ; loop back if not
          lbr     mainlp          ; and loop back til done

done:     CALL    O_CLOSE         ; close the file
          ldi     12              ; print a form feed 
          CALL    O_PRINT         ; to eject paper for tear off
          
          RETURN                  ; return to os

errmsg:    db      'File not found',10,13,0
unavail:   db      'Printer not ready.',10,13,0
fildes:    db      0,0,0,0
           dw      dta
           db      0,0
           db      0
           db      0,0,0,0
           dw      0,0
           db      0,0,0,0

endrom:    equ     $

buffer:    ds      20
dta:       ds      512
