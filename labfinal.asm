;This assembly code has two functions:
; 1. A hexadecimal calculator with add and subtract functionality
; 2. An approximation of a memory cell editor.
;	a. One can input commands to increment and decrement a chosen cell,
;      but cannot edit the memory within those cells. 
;
;Program set to run on an MSP430 mixed signal microcontroller.
		
		
.cdecls C,LIST, "msp430fg4618.h"
;----------------------------------------------------------------
; Main Code
;----------------------------------------------------------------
			.sect ".const"
			.bss label, 4
 			.word 0x1234
 			.sect ".const"

 			.text ; program start
 			.global _START ; define entry point
;----------------------------------------------------------------
START 		mov.w #300h,SP					; Initialize 0x1121
											; stackpointer
StopWDT 	mov.w #WDTPW+WDTHOLD,&WDTCTL ; Stop WDT

 			call #Init_UART
start
			call #INCHAR_UART
			call #OUTA_UART
			cmp #0x4D,R4				; If input is "M"
			jeq mement					; Jump to memory enter function
			cmp #0x48,R4				
			jeq hexcalc					; If input is "H"
										; Jump to hexadecimal calcultor
hexcalc		call #INCHAR_UART
			call #OUTA_UART
			call #SPACE_MAKE
			cmp #0x41,R4				; If second letter is "A"
			jeq hexadd					; Jump to add function
			cmp #0x53,R4
			jeq hexsub					; If second letter is "S"
										; Jump to subtract function

hexadd		call #INPUT4		; input two 4 digit numbers
			call #SPACE_MAKE	; A space is made
			call #HEX_MAKE		; convert hex to dec, values placed in registers 4, 5
			add R5,R4			; registers added, stored in R4

			call #ASCII_MAKE	; program called to convert result to printable characters
			push R4				; numbers stored in registers 4 through 7. 
			mov R7,R4			; 4 is stacked to preserve data
			call #OUTA_UART		; MSB printed
			mov R6,R4
			call #OUTA_UART		; MSB-1 printed
			mov R5,R4
			call #OUTA_UART		; LSB+1 printed
			pop R4
			call #OUTA_UART		; LSB printed
			jmp end				


hexsub		call #INPUT4		; input two 4 digit numbers
			call #HEX_MAKE		; convert to actual, R4 and R5
			cmp R5,R4
			jnc hexsubpos		; if R4<R5
			jc hexsubneg		; if R5<R4

hexsubneg	inv R5
			add #1,R5		; R5 converted to 2's complement
			add.w R5,R4				;R4>R5. R4=R4-R5
			inv R4
			add #1,R4
			call #ASCII_MAKE
			call #SPACE_MAKE
			push R4
			mov R7,R4
			call #OUTA_UART
			mov R6,R4
			call #OUTA_UART
			mov R5,R4
			call #OUTA_UART
			pop R4
			call #OUTA_UART
			jmp end


hexsubpos	inv R4
			add #1,R4		; R4 converted to 2's complement
			add R5,R4				;R5>R4. R5=R5-R4

			call #ASCII_MAKE
			call #SPACE_MAKE
			push R4
			mov R7,R4
			call #OUTA_UART
			mov R6,R4
			call #OUTA_UART
			mov R5,R4
			call #OUTA_UART
			pop R4
			call #OUTA_UART
			jmp end

mement		call #SPACE_MAKE
			call #INPUTTWICE		; input 4 char. address
			call #HEX_MAKE			; converted to actual value, stored in R5
			push R4					; preserve R4
			call #SPACE_MAKE
mem			call #INCHAR_UART		; input command
			call #OUTA_UART
			cmp.b #0x50,R4
			jeq meminc			; if P (+ enter), increment address
			cmp.b #0x4E,R4
			jeq memdec			; if N (+ enter), decrement address
			cmp #0x20,R4
			jeq end				; if [space] (+ enter), end
			call #INCHAR_UART
			call #OUTA_UART
			call #INCHAR_UART
			call #OUTA_UART
			call #INCHAR_UART
			call #OUTA_UART
			call #NEWLINE_MAKE
			mov #0x3E,R4
			call #OUTA_UART		; Code prints "> " on new line
			call #SPACE_MAKE
			pop R4
			call #ASCII_MAKE	; R4 reconverted back to ascii in R7-R4
			push R4
			mov R7,R4
			call #OUTA_UART
			mov R6,R4
			call #OUTA_UART
			mov R5,R4
			call #OUTA_UART
			pop R4
			call #OUTA_UART		; R7-R4 printed in order
			call #SPACE_MAKE	; new space made
			call #HEX_MAKE
			push R4
			jmp mem





meminc		call #NEWLINE_MAKE	; new line made
			mov #0x3E,R4
			call #OUTA_UART
			call #SPACE_MAKE	; These made the display read "> "
			pop R4				; R4 retrieved again
			add #0x0002,R4
			call #ASCII_MAKE	; ASCII made out of R4 (stored in R7-R4)
			push R4				; R4 preserved
			mov R7,R4
			call #OUTA_UART
			mov R6,R4
			call #OUTA_UART
			mov R5,R4
			call #OUTA_UART
			pop R4
			call #OUTA_UART		; program print R7, R6, R5, R4 in order
			call #HEX_MAKE
			push R4
			call #SPACE_MAKE
			jmp mem				; return to memory instruction

memdec		call #NEWLINE_MAKE	; new line.
			mov #0x3E,R4
			call #OUTA_UART
			call #SPACE_MAKE	; code prints "> "
			pop R4				; R4 retrieved
			add #0xFFFE,R4
			call #ASCII_MAKE
			push R4
			mov R7,R4
			call #OUTA_UART
			mov R6,R4
			call #OUTA_UART
			mov R5,R4
			call #OUTA_UART
			pop R4
			call #OUTA_UART
			call #HEX_MAKE
			push R4
			call #SPACE_MAKE
			jmp mem


end 		call #NEWLINE_MAKE
			jmp start


PRINT2ASCII	;SR will print 2 ASCII numbers in their respective hex format (sent to OUTA_UART)
			;R5 is the first digit entered
			;R4 is the second digit
			push R6				; registers R4, R6, R7 are modified in this SR,
			push R7				; so they're pushed to stack over the course of it
			mov R5,R6			; label separates the first hex digit
			and #0xF0,R6		; masking out four msbits
			rra R6				; four rotates to move into lowest place
			rra R6
			rra R6
			rra R6
			mov R5,R7			; masks out second hex digit
			and #0x0F,R7
			add #0x30,R6		; add 0x30 to convert
			add #0x30,R7
			push R4				; save original R4 for later
			mov R6,R4			; write answer
			call #OUTA_UART
			mov R7,R4			; write answer
			call #OUTA_UART
			pop R4				; recall R4
			mov R4,R6			; Begin converting R5
			and #0xF0,R6		; masking out four most sign. bits
			rra R6				; four rotates to move into lowest place
			rra R6
			rra R6
			rra R6
			mov R4,R7			; masks out second hex digit
			and #0x0F,R7
			add #0x30,R6		; add 0x30 to convert
			add #0x30,R7
			push R4				; save original R4
			mov R6,R4			; write answer
			call #OUTA_UART
			mov R7,R4			; write answer
			call #OUTA_UART
			pop R4				; remember original R4
			pop R7
			pop R8
			ret


INPUTECHO	;SR will input and echo two hex format characters from the keyboard
			call #INCHAR_UART
			call #OUTA_UART
			mov R4, R5
			call #INCHAR_UART
			call #OUTA_UART
			ret

PRINTTWICE	;SR will print values in R7 through R4 as their ASCII code equivalent
			call #PRINT2ASCII
			push R4
			push R5
			mov R7,R5
			mov R6,R4
			call #PRINT2ASCII
			mov R4,R6
			mov R5,R7
			pop R4
			pop R5
			ret

INPUTTWICE	;SR calls input echo twice, to make four characters entered.
			call #INPUTECHO
			mov R4,R6
			mov R5,R7
			call #INPUTECHO
			ret				; SR returns with R4, R5, R6, and R7 changed

INPUT4		;SR calls input echo four times ("input twice" twice, with a space between)
			;Returns eight alphanumeric characters, stored in registers 4 through 11 
			call #INPUTTWICE
			mov R4,R8
			mov R5,R9
			mov R6,R10
			mov R7,R11
			call #SPACE_MAKE
			call #INPUTTWICE
			ret		; SR returns with registers 11 through 4 filled with two 4 digit numbers

NEWLINE_MAKE ; SR makes a new line
			push R4
			mov #0x0d,R4		; 0xD is for a CR
			call #OUTA_UART
			mov #0x0a,R4		; 0xA is for a New Line
			call #OUTA_UART
			pop R4
			ret
SPACE_MAKE	; SR makes a space
			push R4
			mov #0x20,R4
			call #OUTA_UART
			pop R4
			ret

HEX_MAKE	; SR converts the eight registers from R11 through R4 to two 4 digit hexadecimal numbers in R4 and R5.
			; input in registers is as follows: HA R11,R10,R9,R8 R7,R6,R5,R4
			; what we need is to get these eight registers down to two
			; so first we have to get the actual value from their ASCII codes.

			call #CONV_IN		; First value is already in R4
			push R4				; converted value is stored for later use

			mov R5,R4			; 00x0 is converted
			call #CONV_IN
			mov R4,R5
			mov #4,R12			; number will be rotated in order to be in right place
l1			rla R5				; 000x --> 00x0
			dec R12
			cmp #0,R12
			jne l1

			mov R6,R4			; 0x00 is converted
			call #CONV_IN
			mov R4,R6
			mov #8,R12			; 000x --> 0x00 requires a move of 2 * 4 places
l2			rla R6
			dec R12
			cmp #0,R12
			jne l2

			mov R7,R4			; x000 is converted
			call #CONV_IN
			mov R4,R7
			mov #12,R12			; 000x --> x000 requires a move of 3*4 places
l3			rla R7
			dec R12
			cmp #0,R12
			jne l3

			mov R8,R4			; second number lsb is converted
			call #CONV_IN
			mov R4,R8

			mov R9,R4			; 00x0 is converted
			call #CONV_IN
			mov R4,R9
			mov #4,R12
l4			rla R9
			dec R12
			cmp #0,R12
			jne l4

			mov R10,R4			; 0x00 is converted
			call #CONV_IN
			mov R4,R10
			mov #8,R12
l5			rla R10
			dec R12
			cmp #0,R12
			jne l5

			mov R11,R4			; x000 is converted
			call #CONV_IN
			mov R4,R11
			mov #12,R12
l6			rla R11
			dec R12
			cmp #0,R12
			jne l6

			pop R4				; #1 lsb is reclaimed
			add R5,R4
			add R6,R4
			add R7,R4			; R4 = R4+R5+R6+R7

			add R9,R8
			add R10,R8
			add R11,R8
			mov R8,R5			; R5 = R8+R9+R10+R11
			ret				;SR returns with R4 and R5 overwritten

ASCII_MAKE	;SR converts a hexadecimal held in R4 to its respective ASCII character code
			mov R4,R5	; Number held in register 4 is copied out to additional registers
			mov R4,R6
			mov R4,R7

			and #0x000F,R4	; Masking occurs. Registers will now correspond to
			and #0x00F0,R5	; one hexadecimal number out of the original four.
			and #0x0F00,R6
			and #0xF000,R7

			call #CONV_OUT
			push R4
							; Conversion of the numbers happens.
			mov #4,R12		; Each number is rotated to fill the lowest possible values.
l7			rra R5
			dec R12
			cmp #0,R12
			jne l7
			mov R5,R4
			call #CONV_OUT
			mov R4,R5

			mov #8,R12
l8			rra R6
			dec R12
			cmp #0,R12
			jne l8
			mov R6,R4
			call #CONV_OUT
			mov R4,R6

			mov #11,R12
			rrc R7
l9			rra R7
			dec R12
			cmp #0,R12
			jne l9
			mov R7,R4
			call #CONV_OUT
			mov R4,R7
			pop R4
			ret	; SR returns with R7(MSB)-R4(LSB) holding the ascii codes

CONV_IN	; SR will change the value of R4 from the input character's ASCII code to its actual value
			cmp.b #0x3A,R4				; is it a number?
			jnc numb
			cmp.b #0x40,R4				; is it a letter?
			jc	lett

lett		add #0xFFC9,R4				; letters are 0x37 away from their actual value
			ret

numb		add #0xFFD0,R4				; numbers are 0x30 away from their actual value
			ret

CONV_OUT ; SR effectively does the opposite of the above.
			cmp.b #0xA,R4
			jnc numbb
			cmp.b #0x9,R4
			jc lettb

lettb		add #0x37,R4
			ret

numbb		add #0x30,R4
			ret




			
			; The following portions of code were not written by me.
			; These subroutines were provided by the curriculum.
			; I take no credit for the function of the code, nor their comments.

OUTA_UART
;----------------------------------------------------------------
; prints to the screen the ASCII value stored in register 4 and
; uses register 5 as a temp value
;----------------------------------------------------------------
; IFG2 register (1) = 1 transmit buffer is empty,
; UCA0TXBUF 8 bit transmit buffer
; wait for the transmit buffer to be empty before sending the
; data out
  		push R5
lpa 	mov.b &IFG2,R5
  		and.b #0x02,R5
  		cmp.b #0x00,R5
  		jz lpa
; send the data to the transmit buffer UCA0TXBUF = A;
 		mov.b R4,&UCA0TXBUF
  		pop R5
  		ret


INCHAR_UART
;----------------------------------------------------------------
; returns the ASCII value in register 4
;----------------------------------------------------------------
; IFG2 register (0) = 1 receive buffer is full,
; UCA0RXBUF 8 bit receive buffer
; wait for the receive buffer is full before getting the data
 			push R5
lpb 		mov.b &IFG2,R5
			and.b #0x01,R5
 			cmp.b #0x00,R5
 			jz lpb
 			mov.b &UCA0RXBUF,R4
 			pop R5
; go get the char from the receive buffer
 			ret



Init_UART
;----------------------------------------------------------------
; Initialization code to set up the uart on the experimenter board
; to 8 data,
; 1 stop, no parity, and 9600 baud, polling operation
;----------------------------------------------------------------
;P2SEL=0x30;
; transmit and receive to port 2 b its 4 and 5
 mov.b #0x30,&P2SEL
; Bits p2.4 transmit and p2.5 receive UCA0CTL0=0
 ; 8 data, no parity 1 stop, uart, async
 mov.b #0x00,&UCA0CTL0
; (7)=1 (parity), (6)=1 Even, (5)= 0 lsb first,
; (4)= 0 8 data / 1 7 data, (3) 0 1 stop 1 / 2 stop, (2-1) --
; UART mode, (0) 0 = async
; UCA0CTL1= 0x41;
 mov.b #0x41,&UCA0CTL1
; select ALK 32768 and put in software reset the UART
; (7-6) 00 UCLK, 01 ACLK (32768 hz), 10 SMCLK, 11 SMCLK
; (0) = 1 reset
;UCA0BR1=0;
; upper byte of divider clock word
 mov.b #0x00,&UCA0BR1
;UCA0BR0=3; ;
; clock divide from a clock to bit clock 32768/9600 = 3.413
 mov.b #0x03,&UCA0BR0
; UCA0BR1:UCA0BR0 two 8 bit reg to from 16 bit clock divider
; for the baud rate
;UCA0MCTL=0x06;
; low frequency mode module 3 modulation pater used for the bit
; clock
 mov.b #0x06,&UCA0MCTL
;UCA0STAT=0;
; do not loop the transmitter back to the receiver for echoing
 mov.b #0x00,&UCA0STAT
; (7) = 1 echo back trans to rec
; (6) = 1 framing, (5) = 1 overrun, (4) =1 Parity, (3) = 1 break
; (0) = 2 transmitting or receiving data
;UCA0CTL1=0x40;
; take UART out of reset
 mov.b #0x40,&UCA0CTL1
;IE2=0;
; turn transmit interrupts off
 mov.b #0x00,&IE2
; (0) = 1 receiver buffer Interrupts enabled
; (1) = 1 transmit buffer Interrupts enabled
;----------------------------------------------------------------
;****************************************************************
;----------------------------------------------------------------
; IFG2 register (0) = 1 receiver buffer is full, UCA0RXIFG
; IFG2 register (1) = 1 transmit buffer is empty, UCA0RXIFG
; UCA0RXBUF 8 bit receiver buffer, UCA0TXBUF 8 bit transmit
; buffer
 ret
;----------------------------------------------------------------
; Interrupt Vectors
;----------------------------------------------------------------
done .sect ".reset" ; MSP430 RESET Vector
  .short START ;
  .end
