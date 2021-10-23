; ******************************************************************************
; Lprt - Load the printer driver 
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

V_DEFAULT:   equ     051bh


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
          
start:    lda  RA                 ; move past any spaces
          smi  ' '
          bz   start
          dec     ra              ; move back to non-space character
          LDA     ra              ; check for nonzero byte
          bz      loadp           ; jump to load driver if no arguments
          smi     '-'             ; check for argument
          lbnz    bad_arg
          ldn     ra              ; check for correct argument
          smi     'u'             ; to unload diver
          lbz     unload
          lbr     bad_arg         ; anything else is a bad argument     

loadp:    LOAD    rd, O_PRINT     ; point rd to vector
          inc     rd              ; go to Address part of vector
          lda     rd              ; get high byte
          sdi     20h             ; check if above kernel memory (> 2000h)
          lbnf    loaded          ; df = 0, means hi byte greater than 20h
          
          LOAD    rc, 0015h       ; block size of 21 bytes
          LOAD    r7, 0F44H       ; 16-byte alignment, named, permanent allocation 
          CALL    o_alloc         ; allocate a block of memory     
          lbdf    bad_blk         ; DF = 1 means allocation failed
          
          COPY    rf, rd          ; save copy of block address for later
            
                  ; Because rf points to the memory block 
                  ; it's quick and easy to just load the opcode bytes
                  ; directly, since this code block is so short.

          ldi     36h             ; opcode for wait: B3 wait (wait here while EF3 true) 
          str     rf              ; store branch
          glo     rf              ; rf points to branch opcode address, so get it now
          inc     rf              ; point to branch target address 
          str     rf              ; save previous address so wait branches to itself
          inc     rf              ; point rf to next byte                                    
          ldi     73h             ; opcode for STXD 
          str     rf              ; STXD saves byte below stack
          inc     rf              ; move rf to next byte in the printer driver
          ldi     60h             ; opcode for IRX 
          str     rf              ; IXR points x back to data byte
          inc     rf
          ldi     65h             ; opcode for OUT 5
          str     rf              ; OUT increments stack pointer
          inc     rf        
          ldi     0f0h            ; opcode for LDX 
          str     rf              ; so we must decrement x by reading and writing
          inc     rf      
          ldi     73h             ; opcode for STXD 
          str     rf              ; the same byte with store and decrement x
          inc     rf
          ldi     36h             ; opcode for wait: B3 wait (wait here while EF3 true) 
          str     rf              ; store branch
          glo     rf              ; rf points to branch opcode address, so get it now
          inc     rf              ; point to branch target address 
          str     rf              ; save previous address so wait branches to itself
          inc     rf              ; point rf to next byte
          ldi     0d5h            ; opcode for Return
          str     rf              ; save last program byte
          inc     rf              ; store code for prtstat
          ldi     36h             ; opcode for prtstat: B3 prtstat (wait here while EF3 true) 
          str     rf              ; store branch
          glo     rf              ; rf points to branch opcode address, so get it now
          inc     rf              ; point to branch target address 
          str     rf              ; save previous address so wait branches to itself
          inc     rf              ; point rf to next byte
          ldi     6dh             ; opcode for INP 5 
          str     rf              ; Read status byte in from Port 5
          inc     rf 
          ldi     0d5h            ; opcode for Return
          str     rf              ; save last program byte
          inc     rf              ; point to padding byte
          ldi     00h             ; pad with zero before name
          str     rf
          inc     rf
          ldi     'P'             ; store string "Print" as name
          str     rf
          inc     rf
          ldi     'r'             ; store string "Print" as name
          str     rf
          inc     rf
          ldi     'i'             ; store string "Print" as name
          str     rf
          inc     rf
          ldi     'n'             ; store string "Print" as name
          str     rf
          inc     rf
          ldi     't'             ; store string "Print" as name
          str     rf
          inc     rf
          ldi     0               ; name string ends with null
          str     rf              ; Drivers are now loaded
  
          LOAD    rf, O_PRINT     ; point rf to printer vector
          inc     rf              ; point to o_print vector address 
          ghi     rd              ; get hi byte of driver address 
          str     rf              ; save it in kernel o_print vector 
          inc     rf
          glo     rd              ; get lo byte of printer address 
          str     rf              ; save it in kernel o_print vector
          adi     0Ah             ; point rd to prtstat driver address
          plo     rd              ; eight bytes beyond print routine
          LOAD    rf, O_PRTSTAT   ; point rf to printer status vector 
          inc     rf              ; point to o_prtstatus vector address 
          ghi     rd              ; get hi byte of driver address 
          str     rf              ; save it in kernel o_prtstatus vector 
          inc     rf
          glo     rd              ; get lo byte of printer address 
          str     rf              ; save it in kernel o_prtstatus vector
          LOAD    rf, success     ; show msg that driver loaded 
          CALL    O_MSG
          RETURN                  ; return to elf/os
          
unload:   LOAD    rd, O_PRINT     ; point rd to printer vector at beginning of block
          inc     rd              ; o_print vector address is block address
          lda     rd              ; get hi byte of block address 
          phi     rf              ; put into rf
          ldn     rd              ; get lo byte of block address
          plo     rf              ; put into rf
          CALL    O_DEALLOC       ; de-allocate block on heap
          
          LOAD    rf, O_PRTSTAT   ; point rf to printer status vector 
          inc     rf              ; point to o_prtstatus vector address 
          LOAD    rd, O_PRINT     ; point rd to printer vector
          inc     rd              ; point to o_print vector address
                        
          ldi     V_DEFAULT.1     ; load hi byte of original vector
          str     rf              ; point vectors back to original address
          inc     rf
          str     rd
          inc     rd
          ldi     V_DEFAULT.0     ; load lo byte of original vector 
          str     rf              ; point vectors back to original address
          str     rd 
          LOAD    rf, unloaded    ; show message that driver is unloaded
          CALL    O_MSG 
          RETURN                  ; return to elf/os
          
loaded:   LOAD    rf, already     ; show already loaded message
          lbr     show_err
          
bad_blk:  LOAD    rf, mem_err     ; show allocation error message
          lbr     show_err
          
bad_arg:  LOAD    rf, usage       ; show usage message, then info text
          CALL    O_MSG
          LOAD    rf, info
show_err: CALL    O_MSG
          lbr     O_WRMBOOT

; ==============================================================================
; Send a character to the printer
;
; This routine is independent of the X variable.
; ==============================================================================
; prtchar:  b3 prtchar              ; prevent over run, wait until not busy 
;           stxd                    ; save byte below stack
;           irx                     ; point x back to data byte
;           out  5                  ; out increments stack pointer
;           ldx                     ; so we must decrement x by reading and
;           stxd                    ; writing same byte at the bottom of stack
; wait:     b3   wait               ; wait for busy flag to exit                             
;           RETURN
;                  
; ==============================================================================
; Get status byte from printer
; ==============================================================================
; prtstat:  b3   prtstat         ; wait for busy flag to clear
;           inp  5                ; get the status byte into D
;           RETURN           


success:  db 'Printer driver loaded.',13,10,0
unloaded: db 'Printer driver unloaded.',13,10,0
already:  db 'A printer driver is already loaded.',13,10,0
mem_err:  db 'Cannot allocate memory for the printer drivers.',13,10,0
usage:    db 'Usage: lprt [-u]',13,10,0
info:     db 'Loads printer drivers. Use option -u to unload.',13,10,0
endrom:    equ     $
