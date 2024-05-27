;------------------------
; IC Checker
;------------------------
; Global Register
;   R16: Parameter Passing
;   R17-20: Local Scope (jangan dipake untuk simpen data permanen)
;   R25-R26: Ascii stuff serial monitor 
;   R21: Menyimpan Data testing Gate 1 (all gate correct = 0x04)z
;   R22: Menyimpan Data testing Gate 2
;   R23: Menyimpan Data testing Gate 3
;   R24: Menyimpan Data testing Gate 4
;   R27: I2C
;------------------------
; Pin
;   D3 Button Interupt 1 (and)
;   D2 Button Interupt 2 (or)
;   A4, A5 I2C LCD
;   A0-2 (Check Gate 3)
;   B3-5 (Check Gate 4)
;   B0-2 (Check Gate 2)
;   D5-7 (Check Gate 1)
;   D4 (LED IC tidak rusak)
;------------------------
  #define __SFR_OFFSET 0x00
  #include "avr/io.h"
  #include "avr/interrupt.h"
; ;------------------------
; ; interrupt vector table
; ;------------------------
; .org 0x00
;     RJMP start          ; Reset vector
; .org 0x02
;     JMP interupt_1     ; External Interrupt Request 0
; .org 0x04
;     JMP interupt_2     ; External Interrupt Request 1
; ;------------------------

;-------------------------
; Variable

  ; Port D
  .equ G1I1, 5    ; Gate 1 Input 1
  .equ G1I2, 6    ; Gate 1 Input 2
  .equ G1O, 7     ; Gate 1 Output

  ; Port B
  .equ G2I1, 0    ; Gate 2 Input 1
  .equ G2I2, 1    ; Gate 2 Input 2
  .equ G2O, 2     ; Gate 2 Output

  .equ G4I1, 3    ; Gate 4 Input 1
  .equ G4I2, 4    ; Gate 4 Input 2
  .equ G4O, 5     ; Gate 4 Output

  ; Port C
  .equ G3I1, 0    ; Gate 3 Input 1
  .equ G3I2, 1    ; Gate 3 Input 2
  .equ G3O, 2     ; Gate 3 Output
;-------------------------

.global start
start:
  CALL serial_setup
  CALL io_setup
  CALL ic_setup
  ; CALL interrupt_setup ; pasrah interupt sementara pakai polling
  loop: 
    CALL delay_20ms
    CBI PORTD, 4      ; Matiin LED

    cek_button_and:
      SBIC PIND, 3    ; cek button and
      RJMP loop
      CALL check_and

    RJMP loop
  
  RET

;===============================================================================
; -- Setup Functions --
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  ; IO Setup
    io_setup:
      SBI DDRD, 4  ; pin D4 dipakai untuk output apakah IC rusak atau tidak

      CBI DDRD, 2  ; pin D2 dipakai untuk input button interupt 2 (button confirm) [biru]
      SBI PORTD, 2 ; pull-up resistor

      CBI DDRD, 3  ; pin D3 dipakai untuk input button interupt 1 (button cycle) [hijau]
      SBI PORTD, 3 ; pull-up resistor

      RET ; !!!!!!!!!!!!!RETURN!!!!!!!!!!!!!!
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  ; IC Setup
  ; IC 2 input 1 output combo
    ic_setup:
      ; Gate 3 (A2, A3, A4)
      SBI DDRC, G3I1  ; Set Gate 3 Input 1 as output
      ; CBI PORTC, G3I1
      SBI DDRC, G3I2  ; Set Gate 3 Input 2 as output
      ; CBI PORTC, G3I  2
      CBI DDRC, G3O 

      ; Gate 4 (B3, B4, B5)
      SBI DDRB, G4I1
      ; CBI PORTB, G4I1
      SBI DDRB, G4I2
      ; CBI PORTB, G4I2
      CBI DDRB, G4O

      ; Gate 2 (B0, B1, B2)
      SBI DDRB, G2I1
      ; CBI PORTB, G2I1
      SBI DDRB, G2I2
      ; CBI PORTB, G2I2
      CBI DDRB, G2O

      ; Gate 1 (D5, D6, D7)
      SBI DDRD, G1I1
      ; CBI PORTD, G1I1
      SBI DDRD, G1I2
      ; CBI PORTD, G1I2
      CBI DDRD, G1O
      RET ; !!!!!!!!!!!!!RETURN!!!!!!!!!!!!!!
    
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
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
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  ; ; Interrupt Setup
    ; interrupt_setup:
    ;   ; Configure INT0 to trigger on falling edge
    ;   LDI R17, 0b00001010
    ;   STS EICRA, R17

    ;   ; Enable INT0 and INT1
    ;   LDI R17, 0b00000011 
    ;   STS EIMSK, R17

    ;   ; Enable global interrupts
    ;   SEI

    ;   RET ; !!!!!!!!!!!!!RETURN!!!!!!!!!!!!!!
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  ; I2C Setup
    CBI DDRC, 4 ; pin PC4 (SDA) is input
    CBI DDRC, 5 ; pin PC5 (SCL) is input

    CALL I2C_init ; initialize TWI module
    CALL LCD_init ; initialize LCD
;===============================================================================

; ===============================================================================
; -- Delay Functions --
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  ; Function Delay 20ns
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
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  ; Function Delay 2s
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
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;===============================================================================

;===============================================================================
; -- Serial Functions --
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
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
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  ; Function print New Line
    print_newline:
      LDI R17, 0x0A
      STS UDR0, R17 ; print newline on serial monitor
      LDI R17, 0x0D
      STS UDR0, R17 ; print carriage return on serial monitor
      RET ; !!!!!!!!!!!!!RETURN!!!!!!!!!!!!!!
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;===============================================================================

;===============================================================================
; -- Interupt Functions --
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ; ; Interupt 1
    ;   .global interupt_1
    ;   interupt_1: ; Turn on LED IC tidak rusak
    ;     CBI PORTD, 4
    ;     LDI R16, 0x01
    ;     CALL print_R16_Hex
    ;     CALL print_newline
    ;     RET
    ; ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ; ; Interupt 2
    ;   .global interupt_2
    ;   interupt_2: ; Turn off LED IC tidak rusak
    ;     CBI PORTD, 4
    ;     LDI R16, 0x00
    ;     CALL print_R16_Hex
    ;     CALL print_newline
    ;     RET
;===============================================================================

;===============================================================================
; -- LCD Functions --
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  I2C_init:
      LDI R21, 0
      STS TWSR, R21 ; prescaler = 0
      LDI R21, 12 ; division factor = 12
      STS TWBR, R21 ; SCK freq = 400kHz
      LDI R21, (1<<TWEN)
      STS TWCR, R21 ; enable TWI
      RET

  ;==============================================================

  LCD_init:
      CALL I2C_start
      LDI R27, (0x27<<1)
      CALL I2C_write
      LDI R27, 0x00 ; Control byte: Co = 0, RS = 0
      CALL I2C_write
      
      LDI R27, 0x38 ; Function set: 8-bit, 2 line, 5x7 dots
      CALL I2C_write
      CALL LCD_delay
      
      LDI R27, 0x0C ; Display on, cursor off, blink off
      CALL I2C_write
      CALL LCD_delay
      
      LDI R27, 0x01 ; Clear display
      CALL I2C_write
      CALL LCD_delay
      
      LDI R27, 0x06 ; Entry mode set: increment automatically, no shift
      CALL I2C_write
      CALL LCD_delay

      CALL I2C_stop
      RET

  ;==============================================================

  LCD_delay:
      LDI R20, 255
  d1: LDI R21, 255
  d2: DEC R21
      BRNE d2
      DEC R20
      BRNE d1
      RET

  ;==============================================================

  I2C_start:
      LDI R21, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
      STS TWCR, R21 ; transmit START condition
  wt1:
      LDS R21, TWCR
      SBRS R21, TWINT ; TWI interrupt = 1?
      RJMP wt1 ; wait for end of transmission
      RET

  ;==============================================================

  I2C_write:
      STS TWDR, R27 ; copy SLA+W into data register
      LDI R21, (1<<TWINT)|(1<<TWEN)
      STS TWCR, R21 ; transmit SLA+W
  wt2:
      LDS R21, TWCR
      SBRS R21, TWINT
      RJMP wt2 ; wait for end of transmission
      RET

  ;==============================================================

  I2C_stop:
      LDI R21, (1<<TWINT)|(1<<TWSTO)|(1<<TWEN)
      STS TWCR, R21 ; transmit STOP condition
      RET
;===============================================================================


;===============================================================================
; -- Check IC Functions --
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  ; Check OR (global function)
    .global check_or
    check_or:
      CBI PORTD, 4          ; Matiin LED
      CLR R21               ; Clear R21 (Gate 1 Data)
      CLR R22               ; Clear R22 (Gate 2 Data)
      CLR R23               ; Clear R23 (Gate 3 Data)
      CLR R24               ; Clear R24 (Gate 4 Data)

      OR_G1:
        CALL ic_setup
        
        OR_G1_1:
          CLR R17             ; Clear R17

          CALL delay_20ms
          CBI PORTD, G1I1     
          CBI PORTD, G1I2    
          CALL delay_20ms 
          IN R17, PIND        ; Read Gate 1 Output
          ANDI R17, 1<<G1O    ; Mask Gate 1 Output
          ADD R21, R17

        OR_G1_2:
          SBI PORTD, G1I1     
          CBI PORTD, G1I2    
          CALL delay_20ms 
          IN R17, PIND        ; Read Gate 1 Output
          ANDI R17, 1<<G1O    ; Mask Gate 1 Output
          ADD R21, R17

        OR_G1_3:
          CBI PORTD, G1I1     
          SBI PORTD, G1I2    
          CALL delay_20ms 
          IN R17, PIND        ; Read Gate 1 Output
          ANDI R17, 1<<G1O    ; Mask Gate 1 Output
          ADD R21, R17

        OR_G1_4:
          SBI PORTD, G1I1     
          SBI PORTD, G1I2    
          CALL delay_20ms 
          IN R17, PIND        ; Read Gate 1 Output
          ANDI R17, 1<<G1O    ; Mask Gate 1 Output
          ADD R21, R17
      
      OR_G2:
        CALL ic_setup
        
        OR_G2_1:
          CLR R17             ; Clear R17

          CBI PORTB, G2I1     
          CBI PORTB, G2I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G2O    ; Mask Gate 1 Output
          ADD R22, R17

        OR_G2_2:
          SBI PORTB, G2I1     
          CBI PORTB, G2I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G2O    ; Mask Gate 1 Output
          ADD R22, R17

        OR_G2_3:
          CBI PORTB, G2I1     
          SBI PORTB, G2I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G2O    ; Mask Gate 1 Output
          ADD R22, R17

        OR_G2_4:
          SBI PORTB, G2I1     
          SBI PORTB, G2I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G2O    ; Mask Gate 1 Output
          ADD R22, R17

      OR_G3:
        CALL ic_setup
        
        OR_G3_1:
          CLR R17             ; Clear R17

          CBI PORTC, G3I1     
          CBI PORTC, G3I2    
          CALL delay_20ms 
          IN R17, PINC        ; Read Gate 1 Output
          ANDI R17, 1<<G3O    ; Mask Gate 1 Output
          ADD R23, R17

        OR_G3_2:
          SBI PORTC, G3I1     
          CBI PORTC, G3I2    
          CALL delay_20ms 
          IN R17, PINC        ; Read Gate 1 Output
          ANDI R17, 1<<G3O    ; Mask Gate 1 Output
          ADD R23, R17

        OR_G3_3:
          CBI PORTC, G3I1     
          SBI PORTC, G3I2    
          CALL delay_20ms 
          IN R17, PINC        ; Read Gate 1 Output
          ANDI R17, 1<<G3O    ; Mask Gate 1 Output
          ADD R23, R17

        OR_G3_4:
          SBI PORTC, G3I1     
          SBI PORTC, G3I2    
          CALL delay_20ms 
          IN R17, PINC        ; Read Gate 1 Output
          ANDI R17, 1<<G3O    ; Mask Gate 1 Output
          ADD R23, R17

      OR_G4:
        CALL ic_setup
        
        OR_G4_1:
          CLR R17             ; Clear R17

          CBI PORTB, G4I1     
          CBI PORTB, G4I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G4O    ; Mask Gate 1 Output
          ADD R24, R17

        OR_G4_2:
          SBI PORTB, G4I1     
          CBI PORTB, G4I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G4O    ; Mask Gate 1 Output
          ADD R24, R17

        OR_G4_3:
          CBI PORTB, G4I1     
          SBI PORTB, G4I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G4O    ; Mask Gate 1 Output
          ADD R24, R17

        OR_G4_4:
          SBI PORTB, G4I1     
          SBI PORTB, G4I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G4O    ; Mask Gate 1 Output
          ADD R24, R17

      OR_END:
        MOV R16, R21        ; Store Gate 1 Output to R16
        CALL print_R16_Hex  ; Print Gate 1 Output
        CALL print_newline  ; Print New Line
        MOV R16, R22        ; Store Gate 2 Output to R16
        CALL print_R16_Hex  ; Print Gate 2 Output
        CALL print_newline  ; Print New Line
        MOV R16, R23        ; Store Gate 3 Output to R16
        CALL print_R16_Hex  ; Print Gate 3 Output
        CALL print_newline  ; Print New Line
        MOV R16, R24        ; Store Gate 4 Output to R16
        CALL print_R16_Hex  ; Print Gate 4 Output
        CALL print_newline  ; Print New Line

        ADD R21, R22        ; Add Gate 1 and Gate 2
        ADD R21, R23        ; Add Gate 1, 2 and 3
        ADD R21, R24        ; Add Gate 1, 2, 3 and 4

        MOV R16, R21        ; Store Gate 1, 2, 3 and 4 to R16
        CALL print_R16_Hex  ; Print Gate 1, 2, 3 and 4
        CALL print_newline  ; Print New Line

        CPI R21, 0xF8      ; Check if Gate 1, 2, 3 and 4 is 0xF8
        BRNE OR_INCORRECT  ; If not 0, jump to incorrect
        SBI PORTD, 4
        CALL print_or     ; Print OR pada I2C
        
        OR_INCORRECT:
        RET ; !!!!!!!!!!!!!RETURN!!!!!!!!!!!!!!
      
  
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  ; Check AND
    check_and:
      CBI PORTD, 4          ; Matiin LED
      CLR R21               ; Clear R21 (Gate 1 Data)
      CLR R22               ; Clear R22 (Gate 2 Data)
      CLR R23               ; Clear R23 (Gate 3 Data)
      CLR R24               ; Clear R24 (Gate 4 Data)

      AND_G1:
        CALL ic_setup
        
        AND_G1_1:
          CLR R17             ; Clear R17

          CALL delay_20ms
          CBI PORTD, G1I1     
          CBI PORTD, G1I2    
          CALL delay_20ms 
          IN R17, PIND        ; Read Gate 1 Output
          ANDI R17, 1<<G1O    ; Mask Gate 1 Output
          ADD R21, R17

        AND_G1_2:
          SBI PORTD, G1I1     
          CBI PORTD, G1I2    
          CALL delay_20ms 
          IN R17, PIND        ; Read Gate 1 Output
          ANDI R17, 1<<G1O    ; Mask Gate 1 Output
          ADD R21, R17

        AND_G1_3:
          CBI PORTD, G1I1     
          SBI PORTD, G1I2    
          CALL delay_20ms 
          IN R17, PIND        ; Read Gate 1 Output
          ANDI R17, 1<<G1O    ; Mask Gate 1 Output
          ADD R21, R17

        AND_G1_4:
          SBI PORTD, G1I1     
          SBI PORTD, G1I2    
          CALL delay_20ms 
          IN R17, PIND        ; Read Gate 1 Output
          ANDI R17, 1<<G1O    ; Mask Gate 1 Output
          ADD R21, R17
      
      AND_G2:
        CALL ic_setup
        
        AND_G2_1:
          CLR R17             ; Clear R17

          CBI PORTB, G2I1     
          CBI PORTB, G2I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G2O    ; Mask Gate 1 Output
          ADD R22, R17

        AND_G2_2:
          SBI PORTB, G2I1     
          CBI PORTB, G2I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G2O    ; Mask Gate 1 Output
          ADD R22, R17

        AND_G2_3:
          CBI PORTB, G2I1     
          SBI PORTB, G2I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G2O    ; Mask Gate 1 Output
          ADD R22, R17

        AND_G2_4:
          SBI PORTB, G2I1     
          SBI PORTB, G2I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G2O    ; Mask Gate 1 Output
          ADD R22, R17

      AND_G3:
        CALL ic_setup
        
        AND_G3_1:
          CLR R17             ; Clear R17

          CBI PORTC, G3I1     
          CBI PORTC, G3I2    
          CALL delay_20ms 
          IN R17, PINC        ; Read Gate 1 Output
          ANDI R17, 1<<G3O    ; Mask Gate 1 Output
          ADD R23, R17

        AND_G3_2:
          SBI PORTC, G3I1     
          CBI PORTC, G3I2    
          CALL delay_20ms 
          IN R17, PINC        ; Read Gate 1 Output
          ANDI R17, 1<<G3O    ; Mask Gate 1 Output
          ADD R23, R17

        AND_G3_3:
          CBI PORTC, G3I1     
          SBI PORTC, G3I2    
          CALL delay_20ms 
          IN R17, PINC        ; Read Gate 1 Output
          ANDI R17, 1<<G3O    ; Mask Gate 1 Output
          ADD R23, R17

        AND_G3_4:
          SBI PORTC, G3I1     
          SBI PORTC, G3I2    
          CALL delay_20ms 
          IN R17, PINC        ; Read Gate 1 Output
          ANDI R17, 1<<G3O    ; Mask Gate 1 Output
          ADD R23, R17

      AND_G4:
        CALL ic_setup
        
        AND_G4_1:
          CLR R17             ; Clear R17

          CBI PORTB, G4I1     
          CBI PORTB, G4I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G4O    ; Mask Gate 1 Output
          ADD R24, R17

        AND_G4_2:
          SBI PORTB, G4I1     
          CBI PORTB, G4I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G4O    ; Mask Gate 1 Output
          ADD R24, R17

        AND_G4_3:
          CBI PORTB, G4I1     
          SBI PORTB, G4I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G4O    ; Mask Gate 1 Output
          ADD R24, R17

        AND_G4_4:
          SBI PORTB, G4I1     
          SBI PORTB, G4I2    
          CALL delay_20ms 
          IN R17, PINB        ; Read Gate 1 Output
          ANDI R17, 1<<G4O    ; Mask Gate 1 Output
          ADD R24, R17

      AND_END:
        MOV R16, R21        ; Store Gate 1 Output to R16
        CALL print_R16_Hex  ; Print Gate 1 Output
        CALL print_newline  ; Print New Line
        MOV R16, R22        ; Store Gate 2 Output to R16
        CALL print_R16_Hex  ; Print Gate 2 Output
        CALL print_newline  ; Print New Line
        MOV R16, R23        ; Store Gate 3 Output to R16
        CALL print_R16_Hex  ; Print Gate 3 Output
        CALL print_newline  ; Print New Line
        MOV R16, R24        ; Store Gate 4 Output to R16
        CALL print_R16_Hex  ; Print Gate 4 Output
        CALL print_newline  ; Print New Line

        ADD R21, R22        ; Add Gate 1 and Gate 2
        ADD R21, R23        ; Add Gate 1, 2 and 3
        ADD R21, R24        ; Add Gate 1, 2, 3 and 4

        MOV R16, R21        ; Store Gate 1, 2, 3 and 4 to R16
        CALL print_R16_Hex  ; Print Gate 1, 2, 3 and 4
        CALL print_newline  ; Print New Line

        CPI R21, 0xA8      ; Check if Gate 1, 2, 3 and 4 is 0xA8
        BRNE AND_INCORRECT  ; If not 0, jump to incorrect
        SBI PORTD, 4
        CALL print_and     ; Print AND pada I2C
        
        AND_INCORRECT:
        RET ; !!!!!!!!!!!!!RETURN!!!!!!!!!!!!!!
      
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

;===============================================================================
  ; I2C Print
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ; OR:
    print_or:
      CALL I2C_start ; transmit START condition
      LDI R27, (0x27<<1) ; SLA+W (LCD_ADDRESS << 1) + W(0)
      CALL I2C_write ; write slave address SLA+W
      LDI R27, 0x00 ; Control byte: Co = 0, RS = 0 (instruction register)
      CALL I2C_write ; write control byte
      LDI R27, 0x80 ; Set DDRAM address to 0 (first line, first position)
      CALL I2C_write ; write DDRAM address command

      CALL I2C_start ; repeat START condition
      LDI R27, (0x27<<1) ; SLA+W again
      CALL I2C_write ; write slave address SLA+W
      LDI R27, 0x40 ; Control byte: Co = 0, RS = 1 (data register)
      CALL I2C_write ; write control byte

      LDI R27, 'I'
      CALL I2C_write
      CALL LCD_delay

      LDI R27, 'C'
      CALL I2C_write
      CALL LCD_delay

      LDI R27, ' '
      CALL I2C_write
      CALL LCD_delay

      LDI R27, 'O'
      CALL I2C_write
      CALL LCD_delay

      LDI R27, 'R'
      CALL I2C_write
      CALL LCD_delay

      ; CALL I2C_stop ; transmit STOP condition

      RET ; !!!!!!!!!!!!!RETURN!!!!!!!!!!!!!!
  ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ; AND:
    print_and:
      CALL I2C_start ; transmit START condition
      LDI R27, (0x27<<1) ; SLA+W (LCD_ADDRESS << 1) + W(0)
      CALL I2C_write ; write slave address SLA+W
      LDI R27, 0x00 ; Control byte: Co = 0, RS = 0 (instruction register)
      CALL I2C_write ; write control byte
      LDI R27, 0x80 ; Set DDRAM address to 0 (first line, first position)
      CALL I2C_write ; write DDRAM address command

      CALL I2C_start ; repeat START condition
      LDI R27, (0x27<<1) ; SLA+W again
      CALL I2C_write ; write slave address SLA+W
      LDI R27, 0x40 ; Control byte: Co = 0, RS = 1 (data register)
      CALL I2C_write ; write control byte

      LDI R27, 'I'
      CALL I2C_write
      CALL LCD_delay

      LDI R27, 'C'
      CALL I2C_write
      CALL LCD_delay

      LDI R27, ' '
      CALL I2C_write
      CALL LCD_delay

      LDI R27, 'A'
      CALL I2C_write
      CALL LCD_delay

      LDI R27, 'N'
      CALL I2C_write
      CALL LCD_delay

      LDI R27, 'D'
      CALL I2C_write
      CALL LCD_delay

      CALL I2C_stop ; transmit STOP condition

      RET ; !!!!!!!!!!!!!RETURN!!!!!!!!!!!!!!
;===============================================================================