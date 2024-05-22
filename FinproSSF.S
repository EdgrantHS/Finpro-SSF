;------------------------
; IC Checker
;------------------------
; Global Register
;   R16: Parameter Passing
;   R17-20: Local Scope (jangan dipake untuk simpen data permanen)
;   R25-R26: Ascii stuff serial monitor
;   R21: Menyimpan Data testing Gate 1
;   R22: Menyimpan Data testing Gate 2
;   R23: Menyimpan Data testing Gate 3
;   R24: Menyimpan Data testing Gate 4
;   R27: check OR (32) atau AND(8)
;------------------------
; Pin
;   D3 Button Interupt 1 (cycle)
;   D2 Button Interupt 2 (confirm)
;   A0, A1 I2C LCD
;   A2-4 (Check Gate 1)
;   B3-5 (Check Gate 2)
;   B0-2 (Check Gate 3)
;   D5-7 (Check Gate 4)
;   D4 (LED IC tidak rusak)
;------------------------
  #define __SFR_OFFSET 0x00
  #include "avr/io.h"
;------------------------
.global start
start:
  RCALL serial_setup
  RCALL delay_2s 
  LDI R16, 0x69
  RCALL print_R16_Hex
  RCALL print_newline

  RCALL delay_2s
  LDI R16, 0x20
  RCALL print_R16_Hex
  RCALL print_newline
  
  RCALL delay_2s
  LDI R16, 0x43
  RCALL print_R16_Hex
  RCALL print_newline
  
  RCALL delay_2s
  LDI R16, 0xAB
  RCALL print_R16_Hex
  RCALL print_newline
  

  RET


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Function Delay
  delay_20ms:
  LDI   R17, 255
  delay_l3: LDI   R18, 210
    delay_l4: LDI   R19, 2
      delay_l5: DEC   R19
        BRNE  delay_l5
        DEC   R18
        BRNE  delay_l4
        DEC   R17
        BRNE  delay_l3
        RET ; !!!!!!!!!!!!!RETURN!!!!!!!!!!!!!!
  ;-------------------------
  delay_2s:              
  LDI   R17, 255
  delay_l6: LDI   R18, 255
    delay_l7: LDI   R19, 164
      delay_l8: DEC   R19
        BRNE  delay_l8
        DEC   R18
        BRNE  delay_l7
        DEC   R17
        BRNE  delay_l6
        RET ; !!!!!!!!!!!!!RETURN!!!!!!!!!!!!!!
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Function print to serial
  print_R16_Hex:
  ;-----------------------------------------------------------------
    PUSH R16 ; store copy of R16 in STACK register
    ANDI R16, 0xF0 ; mask & extract high-nibble
    SWAP R16 ; swap high-nibble with low-nibble
    ADD R16, R25 ; add 48 to byte to get ASCII char 0 to 9
    MOV R17, R16 ; store a copy of byte in R17
    SUBI R17, 58 ; subtract 58 from R17
    BRPL A_F_MSD ; jump if result is positive
  ;-----------------------------------------------------------------
    print_l2:
      LDS R17, UCSR0A
      SBRS R17, UDRE0 ; test data buffer if data can be sent
      RJMP print_l2
  ;-----------------------------------------------------------------
      STS UDR0, R16 ; print Var mid digit on serial monitor
  ;-----------------------------------------------------------------
      POP R16 ; restore R16 value from STACK register
      ANDI R16, 0x0F ; mask & extract low-nibble
      ADD R16, R25
      MOV R17, R16
      SUBI R17, 58
      BRPL A_F_LSD
  ;-----------------------------------------------------------------
    print_l3:
      LDS R17, UCSR0A
      SBRS R17, UDRE0 ; test data buffer if data can be sent
      RJMP print_l3
  ;-----------------------------------------------------------------
      STS UDR0, R16 ; print Var LSD on serial monitor
  ;-----------------------------------------------------------------
    print_l4:
      LDS R17, UCSR0A
      SBRS R17, UDRE0 ; test data buffer if data can be sent
      RJMP print_l4
  ;-----------------------------------------------------------------
  ;-----------------------------------------------------------------
    print_l5:
      LDS R17, UCSR0A
      SBRS R17, UDRE0 ; test data buffer if data can be sent
      RJMP print_l5
  ;-----------------------------------------------------------------
      RET ; !!!!!!!!!!!!!RETURN!!!!!!!!!!!!!!
  ;=====================================================================
  A_F_MSD:
    ADD R16, R26 ; add 7 to byte to get ASCII chars A to F
    RJMP print_l2
  ;---------------------------------------------------------------------
  A_F_LSD:
    ADD R16, R26 ; add 7 to byte to get ASCII chars A to F
    RJMP print_l3
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Function print New Line
  print_newline:
    LDI R17, 0x0A
    STS UDR0, R17 ; print newline on serial monitor
    LDI R17, 0x0D
    STS UDR0, R17 ; print carriage return on serial monitor
    RET ; !!!!!!!!!!!!!RETURN!!!!!!!!!!!!!!
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Serial Setup
  serial_setup:
    CLR R17
    STS UCSR0A, R17 ; clear UCSR0A register
    STS UBRR0H, R17 ; clear UBRR0H register
    LDI R17, 51 ; & store in UBRR0L 51
    STS UBRR0L, R17 ; to set baud rate 19200
    LDI R17, 1<<RXEN0 | 1<<TXEN0
    STS UCSR0B, R17 ; enable RXB & TXB
    LDI R17, 1<<UCSZ00 | 1<<UCSZ01
    STS UCSR0C, R17 ; asynch, no parity, 1 stop, 8 bits
    ;-----------------------------------------------------------------------
    LDI R25, 48 ; constants used to get ASCII values
    LDI R26, 7 ; for chars 0-->9 & A-->F
    RET ; !!!!!!!!!!!!!RETURN!!!!!!!!!!!!!!
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-