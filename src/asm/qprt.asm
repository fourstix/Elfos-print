; -------------------------------------------------------------------
; Query the er status
; Copyright 2021 by Gaston Williams
; -------------------------------------------------------------------
; Based on software written by Michael H Riley
; Thanks to the author for making this code available.
; Original author copyright notice:
; *******************************************************************
; *** This software is copyright 2004 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

#include ops.inc
#include bios.inc
#include kernel.inc

; ************************************************************
; This block generates the Execution header
; It occurs 6 bytes before the program start.
; ************************************************************
      org     02000h-6          ; Header starts at 01ffah
          dw      02000h          ; Program load address
          dw      endrom-2000h    ; Program size
          dw      02000h          ; Program execution address

      org     02000h              ; Program code starts here
          br      start           ; Jump past build information

        ; Build date
date:     db      80H+10          ; Month, 80H offset means extended info
          db      22              ; Day
          dw      2021            ; Year

        ; Current build number
build:    dw      1

          ; Must end with 0 (null)
          db      'Copyright 2021 Gaston Williams',0

start:    LOAD    rd, 00h         ; clear rd

          ldi     0FFh            ; load invalid value before checking status
          CALL    O_PRTSTAT       ; get printer status byte
          plo     rd              ; save status byte in rd.0
                            
chk_arg:  lda     ra              ; process arguments      
          smi     ' '
          bz      chk_arg         ; move past any spaces in argument
          dec     ra              ; move back to non-space character
          LDA     ra              ; check for nonzero byte
          lbz     code            ; jump to show code only if no arguments
          smi     '-'             ; check for argument
          lbnz    bad_arg
          ldn     ra              ; check for sleep option s
          smi     's'             ; to sleep and display verbose message
          lbz     sleep
          smi     3               ; 'v' - 's' = 3 (t,u,v) check for option v
          lbz     verbose         ; to display verbose message
          smi     1               ; 'w' - 'v' = 1 (v,w) check for option w
          lbz     wake            ; to wake and display status
          
          lbr     bad_arg         ; anything else is a bad argument

sleep:    ldi     1Bh             ; send 'ESC =' printer  
          CALL    O_PRINT         ; command to take printer offline and sleep
          ldi     '='             
          CALL    O_PRINT
          lbr     redo            ; update status after sleep or wake
                   
wake:     ldi     1Bh             ; send 'ESC @' printer  
          CALL    O_PRINT         ; command to wake printer back online
          ldi     '@'             ; also reset to default text values
          CALL    O_PRINT 
          
redo:     ldi     0FFh            ; load invalid value before checking status
          CALL    O_PRTSTAT       ; get printer status byte after wake or sleep
          plo     rd              ; save status byte in rd.0
          
verbose:  LOAD    rf, header      ; print text before status text message
          CALL    O_MSG     
          glo     rd              ; get status byte           
          bnz     chksleep        ; if not zero, check to see if offline
                    
          LOAD    rf, okay         
          lbr     showit

chksleep: glo     rd              ; get status byte
          smi     21h             ; check with offline code
          bnz     chkpaper        ; if not zero, check for power error
          
          LOAD    rf, offline     ; show the out of paper message
          lbr     showit    
          
chkpaper: glo     rd              ; get status byte
          smi     24h             ; check with out of paper code
          bnz     chkpwr          ; if not zero, check for power error
          
          LOAD    rf, paper       ; show the out of paper message
          lbr     showit    

chkpwr:   glo     rd              ; get status byte
          smi     28h             ; check with over-voltage code
          bnz     chktemp         ; if not zero, check for temperature error
          
          LOAD    rf, power       ; show power error message
          lbr     showit    

chktemp:  glo     rd              ; get status byte
          smi     60h             ; check with over heated code
          bnz     other           ; if not zero, treat as unavailable
          
          LOAD    rf, hot         ; show over heated message
          lbr     showit    
          
other:    LOAD    rf, O_PRINT     ; check to see if no driver is loaded
          inc     rf              ; go to Address part of print vector
          lda     rf              ; get high byte
          smi     20h             ; check if above kernel memory (> 2000h)
          lbdf    unknown         ; df = 1, means hi byte greater than 20h
          LOAD    rf, unloaded    ; show driver not loaded message
          lbr     showit
            
unknown:  LOAD    rf, unavail     ; all other codes indicate printer not found
showit:   CALL    O_MSG           ; output text value

          LOAD    rf, status      ; output status code header
          CALL    O_MSG
code:     LOAD    rf, buffer
          CALL    f_hexout2       ; convert byte to two ascii hex digits 
          LOAD    rf, buffer      ; and display it
          CALL    O_MSG

          RETURN                  ; return to Elf/OS
          
bad_arg:  LOAD    rf, usage       ; show usage text and exit
          CALL    O_MSG 
          LOAD    rf, info
          CALL    O_MSG
          LOAD    rf, info2
          CALL    O_MSG          
          lbr     O_WRMBOOT        ; return to Elf/OS
        
header:   db 'Printer ',0        
okay:     db 'ready.',13,10,0
paper:    db 'out of paper.',13,10,0
hot:      db 'over heated.',13,10,0
power:    db 'voltage too high.',13,10,0
offline:  db 'offline and asleep.',13,10,0
unloaded: db 'driver not loaded.',13,10,0
unavail:  db 'not available.',13,10,0     
status:   db 'Status code: ',0
buffer:   db 0,0,13,10,0
usage:    db 'Usage: qprt [-s|-v|-w]',13,10,0
info:     db 'Query printer and show status. Use option -v for verbose message.',13,10,0
info2:    db 'Use option -s to sleep printer or option -w to wake printer.',13,10,0    
        ;------ define end of execution block
endrom: equ     $
