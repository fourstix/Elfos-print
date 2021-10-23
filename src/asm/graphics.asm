; ******************************************************************************
; Print - Send a graphics file to the printer
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
          db      'Usage: graphics filename',10,13,0
          RETURN                  ; and return to os
          
good:     ldi  1Bh            ; wake up and reset printer before reading file 
          CALL O_PRINT        ; send 'ESC @' command to wake printer
          ldi  '@'            ; and reset to default text values
          CALL O_PRINT
          ldi  0FFh           ; load invalid value before checking status
          CALL O_PRTSTAT      ; check Printer
          bz   open_img       ; non-zero means not available
          
          LOAD rf, unavail    ; show unavailable message and exit
          CALL O_MSG 
          lbr  O_WRMBOOT      ; exit to Elf/OS
          
open_img: LOAD rd,fildes	    ; image file descriptor
          ldi	 0		          ; (no create, no truncate, no append) flags
          plo	 r7
          phi  r7
          CALL O_OPEN		      ; attempt to open file
          bnf  opened	        ; DF=0, file was opened
          LOAD rf, not_found
          CALL O_MSG
          LBR O_WRMBOOT	      ; return to Elf/OS
                              
opened:   LOAD rc,512         ; read up to 512 bytes 
          LOAD rf,buff1          
          LOAD rd,fildes
          CALL O_READ		      ; read the image file
          lbdf  read_err 	    ; DF=1, read error
          glo	 rc		          ; check file size read
          lbnz  size_err      ; if nothing read show error
          ghi  rc
        
          smi  1              ; 32x64 size is 100H (256 bytes)
          bz   load32
          smi  1              ; 64x64 size is 200H (512 bytes)
          bz   load64 
          lbnz size_err       ; Anything else isn't supported

load32:   ldi  1Bh            ; send 'ESC #' printer  
          CALL O_PRINT        ; to start 32x64 graphics mode
          ldi  '#'         
          CALL O_PRINT
          
          LOAD rf,buff1       ; point rf at image buffer
          LOAD rc, 256        ; load count into rc
          lbr  prt_img        ; print it
          
load64:   ldi  1Bh            ; send 'ESC *' printer  
          CALL O_PRINT        ; to start 64x64 graphics mode
          ldi  '*'         
          CALL O_PRINT     

          LOAD rf,buff1       ; point rf at image buffer
          LOAD rc, 512        ; load count into rc
          
prt_img:  lda  rf             ; get a byte from buffer                              
          CALL O_PRINT        ; print image byte
          dec  rc             ; count down
          ghi  rc             ; check hi byte of counter
          bnz  prt_img        ; if non-zero keep going
          glo  rc             ; check lo byte of counter
          bnz  prt_img        ; if non-zero keep going
          
          LOAD rd,fildes      ; we're done after printing 512 bytes
          CALL O_CLOSE		    ; close the image file
          ldi  12             ; print a form feed 
          CALL O_PRINT        ; to eject paper for tear off
          
          RETURN              ; return to os
                              
size_err: LOAD  rf,bad_size   ; only 256 or 512 byte images are supported
          CALL	O_MSG                	
          br	  abend
                              
read_err:	LOAD rf,bad_read    ; read error occurred
          CALL O_MSG                  	
                    
abend:    LOAD  rd,fildes     ; in case of error always attempt to close file
          CALL	O_CLOSE		    ; close the image file
          LBR O_WRMBOOT      	; return to Elf/OS

;--- error messages
not_found: db	'File not found',13,10,0
bad_size:  db	'Incorrect image file size',13,10,0
bad_read:  db	'Error reading image file',13,10,0
unavail:   db 'Printer not ready.',10,13,0

;--- file descriptor
fildes:    db      0,0,0,0
           dw      dta
           db      0,0
           db      0
           db      0,0,0,0
           dw      0,0
           db      0,0,0,0

endrom:    equ     $

;--- file data transfer buffer
dta:	           ds	512
;--- image data buffer
buff1:	         ds	512
