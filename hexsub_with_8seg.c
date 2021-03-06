//---------------------------------------------------------------
// Code designed to output the result of a subtraction operation
// when two 2-digit hexadecimal numbers are entered into the 
// hyperterminal connected to the MSP430 microcontroller.
//---------------------------------------------------------------


#include "msp430fg4618.h"
#include "stdio.h"

void Init_UART(void);
void OUTA_UART(unsigned char A);
unsigned char INCHAR_UART(void);

void Init_LCD(void);
unsigned char *LCDSeg = (unsigned char *) &LCDM3;
int LCD_SIZE=11;
int NUMFIELD=7;

int main(void){
	volatile unsigned int a,b,c,d; // AB is the first number in hex code, CD is the second.
	volatile unsigned int e, f, g, h; 	// e f g and h will hold the converted values of the input.
	volatile unsigned int j, k, l;      // J and K hold the final converted value of their input. L
	volatile unsigned int s, t, u, v; //s will hold the MSB of the difference, t will hold the LSB
	unsigned char equal, mult, nl, cr;
	volatile unsigned int i;
	int disp[16] = {0x5f, 0x06, 0x6b, 0x2f, 0x36, 0x3d, 0x7d, 0x07, 0x7f, 0x37, 0x77, 0x7c, 0x68, 0x6e, 0x79, 0x71};
	//The display array hold all 16 hexadecimal values from 0 to F - converted so that the 8 segment
	//display will display them properly.
	// Display format
 	// 			 A A A
	// 			E     B
 	// 		X 	E     B
 	// 			 F F F
 	// 		X	G     C
 	// 			G     C
 	// 		DP       D D D
 	// bit order
 	// dp, G, F, E, D, C, B, A
	
	WDTCTL = WDTPW + WDTHOLD;

	Init_UART();
	Init_LCD();

	mult = 0x2A; //ASCII code for '*'
	equal = 0x3D; // ASCII code for '='
	nl = 10;
	cr = 13;
for (;;){
		a=INCHAR_UART();		//First, we input the first 2-digit number
		OUTA_UART(a);	
						//Then, we must convert it to ASCII. 
						//ASCII code is not in the same order as hexadecimal
						//Numbers are 30h digits away from their actual value (0x0 = ASCII 0x30)
						//Letters are 37h digits away (0xF = 15d = ASCII 0x46)
		if (a<=0x39){			// is first character a number?
			if (a>=0x30){
				e=a-0x30;		// convert first character from ASCII to hex
				e*=16;			// multiplying by 16 is equivalent to rotating left by four bits
			}
		}
		else if (a<=0x46){		// is first character a capital letter?
			if (a>=0x41){
				e=a-0x37;		// convert from ASCII to hex
				e*=16;			// rotate left by 4 to next hex digit
			}
		}

		b=INCHAR_UART();		// read second character
		OUTA_UART(b);			// output second character
		if (b<=0x39){			// is second character a number?
			if (b>=0x30){
				f=b-0x30;	// convert from ascii to hex
			}					// second character stays in the first four bits/first hex number
		}
		else if (b<=0x46){		// is second character a capitol letter?
			if (b>=0x41){
				f=b-0x37;	// convert from ascii to hex
			}
		}
		j = e+f;				// add converted first character to converted second character to get the number you entered in actual hex form
		OUTA_UART(mult);			// this concludes the first number entered.

		c = INCHAR_UART();
		OUTA_UART(c);
		if (c<=0x39){			// is first character a number?
				if (c>=0x30){
					g=c-0x30;		// convert first character from ASCII to hex
					g*=16;			// multiplying by 16 is equivalent to rotating left by four bits
				}
			}
			else if (c<=0x46){		// is first character a capital letter?
				if (c>=0x41){
					g=c-0x37;		// convert from ASCII to hex
					g*=16;			// rotate left by 4
				}
			}

		d=INCHAR_UART();		// read second character
		OUTA_UART(d);			// output second character
		if (d<=0x39){			// is second character a number?
			if (d>=0x30){
					h=d-0x30;	// convert from ascii to hex
			}					// second character stays in the first four bits/first hex number
		}
		else if (d<=0x46){		// is second character a capitol letter?
			if (d>=0x41){
					h=d-0x37;	// convert from ascii to hex
			}
		}

		k = g+h;		// same as above, character codes converted to actual number and added together.
		OUTA_UART(equal);	// this concludes the second character, output an equal sign before calculation.

		if (k>j){ // the result is negative if the second is greater than the first
			OUTA_UART(sub); // because it's negative, ouptut will need to reflect that.
			LCDSeg[3] = 0x20; // same is done on the 8-seg
			l = k-j;
			s = 0xF0 & l;	// s is the masked 4 upper bits.
			s /= 16;		// to make it a character, you first have to bring it down to the 4 LSB.
			LCDSeg[2] = disp[s];	// the raw value reflects the portion of the array that we want
			
			// we must now reverse the ASCII to hex operation we did above. 
			if (s<=9){
				s+=0x30;
			}
			else if (s>=0xA){
				s+=0x37;
			}

			t = 0x0F & l;	//T is the masked lower 4 bits.
			LCDSeg[1] = disp[t];
			LCDSeg[0] = 0x74; //This corresponds to the letter 'h', denoting a hexadecimal value on the 8-seg

			if (t<=9){
				t+=0x30;
			}
			else if (t>=0xA){
				t+=0x37;
			}

			OUTA_UART(s);
			OUTA_UART(t);
		}

		else if (j>k){
			l = j-k;		// the difference is calculated

			s = 0xF0 & l;	// s is the masked 4 upper bits.
			s /= 16;		// to make it a character, you first have to bring it down to the 4 LSB.
			LCDSeg[2] = disp[s];

			if (s<=9){
				s+=0x30;
			}
			else if (s>=0xA){
				s+=0x37;
			}

			t = 0x0F & l;
			LCDSeg[1] = disp[t];
			LCDSeg[0] = 0x74;

			if (t<=9){
				t+=0x30;
			}
			else if (t>=0xA){
				t+=0x37;
			}
			OUTA_UART(s);
			OUTA_UART(t);
		}
		OUTA_UART(nl);
		OUTA_UART(cr);

	}
}
void OUTA_UART(unsigned char A){
//---------------------------------------------------------------
//***************************************************************
//From here on, code is borrowed from the lab manual provided.
//This work is not written by me, but is given to allow expedient
//teaching of the lab material.
//***************************************************************
//---------------------------------------------------------------
// IFG2 register (1) = 1 transmit buffer is empty,
// UCA0TXBUF 8 bit transmit buffer
// wait for the transmit buffer to be empty before sending the
// data out
do{
 }while ((IFG2&0x02)==0);
// send the data to the transmit buffer
UCA0TXBUF =A;
}

unsigned char INCHAR_UART(void){
//---------------------------------------------------------------
//***************************************************************
//---------------------------------------------------------------
// IFG2 register (0) = 1 receive buffer is full,
// UCA0RXBUF 8 bit receive buffer
// wait for the receive buffer is full before getting the data
do{
}while ((IFG2&0x01)==0);
// get the char from the receive buffer
return (UCA0RXBUF);
}
void Init_UART(void){
//---------------------------------------------------------------
// Initialization code to set up the uart on the experimenter
// board to 8 data,
// 1 stop, no parity, and 9600 baud, polling operation
//---------------------------------------------------------------
P2SEL=0x30; // transmit and receive to port 2 b its 4 and 5
 // Bits p2.4 transmit and p2.5 receive
UCA0CTL0=0; // 8 data, no parity 1 stop, uart, async
 // (7)=1 (parity), (6)=1 Even, (5)= 0 lsb first,
 // (4)= 0 8 data / 1 7 data,
 // (3) 0 1 stop 1 / 2 stop, (2-1) -- UART mode,
 // (0) 0 = async
UCA0CTL1= 0x41;
 // select ALK 32768 and put in
 // software reset the UART
 // (7-6) 00 UCLK, 01 ACLK (32768 hz), 10 SMCLK,
 // 11 SMCLK
 // (0) = 1 reset
UCA0BR1=0; // upper byte of divider clock word
UCA0BR0=3; // clock divide from a clock to bit clock 32768/9600
 // = 3.413
 // UCA0BR1:UCA0BR0 two 8 bit reg to from 16 bit
 // clock divider
 // for the baud rate
UCA0MCTL=0x06;
 // low frequency mode module 3 modulation pater
 // used for the bit clock
UCA0STAT=0; // do not loop the transmitter back to the
 // receiver for echoing
 // (7) = 1 echo back trans to rec
 // (6) = 1 framing, (5) = 1 overrun, (4) =1 Parity,
 // (3) = 1 break
 // (0) = 2 transmitting or receiving data
UCA0CTL1=0x40;
 // take UART out of reset
IE2=0; // turn transmit interrupts off
//---------------------------------------------------------------
//***************************************************************
//---------------------------------------------------------------
 // IFG2 register (0) = 1 receiver buffer is full,
 // UCA0RXIFG
 // IFG2 register (1) = 1 transmit buffer is empty,
 // UCA0RXIFG
 // UCA0RXBUF 8 bit receiver buffer
 // UCA0TXBUF 8 bit transmit buffer
}

//---------------------------------------------------------------------
// Initialize the LCD system
//---------------------------------------------------------------------
void Init_LCD(void){

int n;
for (n=0;n<LCD_SIZE;n++){
 // initialize the segment memory to zero to clear the LCD
 // writing a zero in the LCD memory location clears turns
 // off the LCD segment Including all of the special characters
 *(LCDSeg+n) = 0;
 // LCDSeg[n]=0;
 }
 // Port 5 ports 5.2-5.4 are connected to com1, com2, com3 of LCD and
 // com0 is fixed and already assigned
 // Need to assign com1 - com3 to port5
 P5SEL = 0x1C; // BIT4 | BIT3 |BIT2 = 1 P5.4, P.3, P5.2 = 1
 // Used the internal voltage for the LCD bit 4 = 0 (VLCDEXT=0)
 // internal bias voltage set to 1/3 of Vcc, charge pump disabled,
 // page 26-25 of MSP430x4xx user manual
 LCDAVCTL0 = 0x00;
 // LCDS28-LCDS0 pins LCDS0 = lsb and LCDS28 = MSB need
 // LCDS4 through LCDS24
 // from the experimenter board schematic the LCD uses S4-S24,
 // S0-S3 are not used here
 // Only use up to S24 on the LCD 28-31 not needed.
 // Also LCDACTL1 not required since not using S32 - S39
 // Davie's book page 260
 // page 26-23 of MSP430x4xx user manual
 LCDAPCTL0 = 0x7E;
 // The LCD uses the ACLK as the master clock as the scan rate for
 // the display segments
 // The ACLK has been set to 32768 Hz with the external
 // 327768 Hz crystal
 // Bit pattern required = 0111 1101 = 0x7d
 // page 26-22 of MSP430x4xx user manual
 LCDACTL = 0x7d;
}
