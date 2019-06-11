	.module SYSC2003A5.c
	.area data
_blindStart::
	.blkb 1
	.area idata
	.byte 0
	.area data
_LOWER_LIMIT:
	.blkb 1
	.area idata
	.byte 10
	.area data
_UPPER_LIMIT:
	.blkb 1
	.area idata
	.byte 50
	.area data
_temp::
	.blkb 2
	.area idata
	.word 0
	.area data
_previousTemp::
	.blkb 2
	.area idata
	.word 0
	.area data
_time::
	.blkb 2
	.area idata
	.word 0
	.area data
_time2::
	.blkb 2
	.area idata
	.word 0
	.area data
_time3::
	.blkb 2
	.area idata
	.word 0
	.area data
_time4::
	.blkb 2
	.area idata
	.word 0
	.area data
_globalTime::
	.blkb 2
	.area idata
	.word 0
	.area data
_counter::
	.blkb 2
	.area idata
	.word 0
	.area data
_incTens::
	.blkb 1
	.area idata
	.byte 0
	.area data
_incHunds::
	.blkb 1
	.area idata
	.byte 0
	.area data
_incThou::
	.blkb 1
	.area idata
	.byte 0
	.area data
_stringArr1::
	.blkb 16
	.area idata
	.byte 'G,'M,'S,32,'T,'i,'m,'e,58,48,48,48,48,32,'s,0
	.area data
_stringArr2::
	.blkb 15
	.area idata
	.byte 'T,58,48,48,'C,32,'P,58,32,48,48,'R,'P,'S,0
	.area data
_stringArray::
	.blkb 5
	.area idata
	.byte 48,48,48,48,0
	.area data
	.area text
_main::
	leas -2,S
; #include "hcs12dp256.h"
; #include <stdio.h>
; //keypad & for loops
; char i, row, column;
; 
; //stepper motor
; char blindStart = 0;
; 
; char duty; // For the motor (water pump)
; char fan_duty; //for fan
; char actualRPS, desiredRPS, rotations;
; static char LOWER_LIMIT = 10, UPPER_LIMIT = 50;
; 
; int temp = 0, previousTemp = 0; //temperature
; 
; int time = 0, time2 = 0, time3 = 0, time4 = 0, globalTime = 0;
; int counter = 0; //number of clock ticks
; char incTens = 0, incHunds = 0, incThou = 0;
; 
; char stringArr1[] = "GMS Time:0000 s";
; char stringArr2[] = "T:00C P: 00RPS";
; char stringArray[] = "0000";
; 
; void main() {
; 	initHW();
	jsr _initHW
; 	
; 	//write static portion of LCD
; 	for (i = 0; i <= 14; i++) {
	clr _i
	bra L7
L4:
; 		LCD_display(stringArr1[i]);
	ldy #_stringArr1
	ldab _i
	clra
	sty 0,S
	addd 0,S
	tfr D,Y
	ldab 0,Y
	clra
	jsr _LCD_display
; 	}
L5:
	inc _i
L7:
	ldab _i
	cmpb #14
	bls L4
; 	LCD_instruction(0xc0); //newline
	ldd #192
	jsr _LCD_instruction
; 	for (i = 0; i <= 13; i++) {
	clr _i
	bra L11
L8:
; 		LCD_display(stringArr2[i]);
	ldy #_stringArr2
	ldab _i
	clra
	sty 0,S
	addd 0,S
	tfr D,Y
	ldab 0,Y
	clra
	jsr _LCD_display
; 	}
L9:
	inc _i
L11:
	ldab _i
	cmpb #13
	bls L8
	lbra L13
L12:
; 	
; 	while (1) {
; 		//Timer
; 		if (counter == 4) {
	ldy _counter
	cpy #4
	lbne L15
; 			
; 			/*time++; - not working
; 			LCD_instruction(0x89);
; 			LCD_display(time4 + 0x30);
; 			LCD_instruction(0x8A);
; 			LCD_display(time3 + 0x30);
; 			LCD_instruction(0x8B);
; 			LCD_display(time2 + 0x30);
; 			LCD_instruction(0x8C);
; 			LCD_display(time + 0x30);*/
; 			
; 	    	if (time == -1 && time2 == -1 && time3 == -1) {
	ldy _time
	cpy #65535
	bne L17
	ldy _time2
	cpy #65535
	bne L17
	ldy _time3
	cpy #65535
	bne L17
; 		    	time4++;
	ldy _time4
	iny
	sty _time4
; 		    	LCD_instruction(0x89);
	ldd #137
	jsr _LCD_instruction
; 		    	LCD_display(time4 + 0x30);
	ldd _time4
	addd #48
	jsr _LCD_display
; 		        if (time4 == 9) {
	ldy _time4
	cpy #9
	bne L19
; 		   	       time4 = -1;
	movw #65535,_time4
; 		        }
L19:
; 		    }
L17:
; 	   		if (time == -1 && time2 == -1) {
	ldy _time
	cpy #65535
	bne L21
	ldy _time2
	cpy #65535
	bne L21
; 		       time3++;
	ldy _time3
	iny
	sty _time3
; 		       LCD_instruction(0x8A);
	ldd #138
	jsr _LCD_instruction
; 		       LCD_display(time3 + 0x30);
	ldd _time3
	addd #48
	jsr _LCD_display
; 		       if (time3 == 9) {
	ldy _time3
	cpy #9
	bne L23
; 		   	      time3 = -1;
	movw #65535,_time3
; 		       }
L23:
; 		    }
L21:
; 	   		if (incTens == 1) {
	ldab _incTens
	cmpb #1
	bne L25
; 		       time2++;
	ldy _time2
	iny
	sty _time2
; 		       LCD_instruction(0x8B);
	ldd #139
	jsr _LCD_instruction
; 		       LCD_display(time2 + 0x30);
	ldd _time2
	addd #48
	jsr _LCD_display
; 		       incTens = 0;
	clr _incTens
; 		       if (time2 == 9) { 
	ldy _time2
	cpy #9
	bne L27
; 		   	      time2 = -1;
	movw #65535,_time2
; 		       }
L27:
; 		    }
L25:
; 		    time++;
	ldy _time
	iny
	sty _time
; 		    LCD_instruction(0x8C); //0x80 forces cursor to first line. 0xC0 is second line
	ldd #140
	jsr _LCD_instruction
; 		    LCD_display(time + 0x30);
	ldd _time
	addd #48
	jsr _LCD_display
; 		    if (time == 9) {
	ldy _time
	cpy #9
	bne L29
; 		       time = -1;
	movw #65535,_time
; 		       incTens = 1;
	movb #1,_incTens
; 		    }
L29:
; 		    counter = 0;
	movw #0,_counter
; 	    }
L15:
; 		//End Timer
; 		
; 		if (temp != previousTemp) { //display updated temperature
	ldy _temp
	cpy _previousTemp
	beq L31
; 			 LCD_instruction(0xC3);
	ldd #195
	jsr _LCD_instruction
; 			 LCD_display((temp % 10) + 0x30); //have to print 1 digit at a time
	ldx #10
	ldd _temp
	idivs
	addd #48
	jsr _LCD_display
; 			 LCD_instruction(0xC4);
	ldd #196
	jsr _LCD_instruction
; 			 LCD_display((temp / 10) + 0x30);
	ldx #10
	ldd _temp
	idivs
	tfr X,D
	addd #48
	jsr _LCD_display
; 			 previousTemp = temp;
	movw _temp,_previousTemp
; 		}
L31:
; 		if (temp > 24 && fan_duty != 100) { //23C + 2 = 25 (too hot)
	ldy _temp
	cpy #24
	ble L33
	ldab _fan_duty
	cmpb #100
	beq L33
; 			//ramp fan
; 			PTM &= 0x7F; //clear bit 7 to turn off heater
	bclr 0x250,#128
; 			for (fan_duty = 0; fan_duty <= 100; fan_duty++) { //ramp up fan
	clr _fan_duty
	bra L38
L35:
; 				PWMDTY4 = fan_duty;
	movb _fan_duty,0xc0
; 			}	
L36:
	inc _fan_duty
L38:
	ldab _fan_duty
	cmpb #100
	bls L35
; 		} else if (temp < 22) { //turn on heater, turn off fan. 23C - 2 = 21 (too cold)
	bra L34
L33:
	ldy _temp
	cpy #22
	bge L39
; 			PTM |= 0x80; //note: heater on RTI needs to trigger ADCISR?
	bset 0x250,#128
; 			for (i = fan_duty; i >= 1; i--) { //decelerate fan
	movb _fan_duty,_i
	bra L44
L41:
; 				PWMDTY4 = i;
	movb _i,0xc0
; 		    }
L42:
	dec _i
L44:
	ldab _i
	cmpb #1
	bhs L41
; 		}
L39:
L34:
; 		//Motor RPS
; 		if (desiredRPS != actualRPS) {
	ldab _desiredRPS
	cmpb _actualRPS
	beq L45
; 			LCD_instruction(0xCA);
	ldd #202
	jsr _LCD_instruction
; 			LCD_display((actualRPS % 10) + 0x30);
	ldx #10
	ldab _actualRPS
	clra
	idivs
	addd #48
	jsr _LCD_display
; 			LCD_instruction(0xCB);
	ldd #203
	jsr _LCD_instruction
; 			LCD_display((actualRPS / 10) + 0x30);
	ldx #10
	ldab _actualRPS
	clra
	idivs
	tfr X,D
	addd #48
	jsr _LCD_display
; 			desiredRPS = actualRPS;
	movb _actualRPS,_desiredRPS
; 		}
L45:
; 		
; 		//polling for button press 'F' to quit
; 		row = 0x08;
	movb #8,_row
; 		PTM |= 0x08; //latch is transparent
	bset 0x250,#8
; 		PTP = row; //if equals row (for button 'F')
	movb _row,0x258
; 		PTM &= 0xF7;
	bclr 0x250,#8
; 		column = PTH & 0xF0;
	ldab 0x260
	andb #240
	stab _column
; 		if (column == 0x40) { //if F is pressed at any time
	ldab _column
	cmpb #64
	bne L47
; 			PORTK &= 0x00; //turn off LEDs
	ldd #0
	stab 0x32
; 			PTT = 0; //set 7-segment to 0
	clr 0x240
; 			CRGINT &= 0x00; //disable interrupts
	ldd #0
	stab 0x38
; 			LCD_instruction(0x01);//Clear LCD
	ldd #1
	jsr _LCD_instruction
; 			//PWMDTY7 = 0; //stop motor
; 			//PWMDTY4 = 0; //stop fan
; 			exit(); 
	jsr _exit
; 		}
L47:
; 		debounceDelay();
	jsr _debounceDelay
; 		
; 		//Press 1 to increase pump rate
; 		row = 0x01;
	movb #1,_row
; 		PTM |= 0x08; //latch is transparent
	bset 0x250,#8
; 		PTP = row; //if equals row (for button '1')
	movb _row,0x258
; 		PTM &= 0xF7;
	bclr 0x250,#8
; 		column = PTH & 0xF0;
	ldab 0x260
	andb #240
	stab _column
; 		if (column == 0x10) { //if 1 is pressed at any time
	ldab _column
	cmpb #16
	bne L49
; 			//increase pump rate
; 			duty += 5;
	ldab _duty
	addb #5
	stab _duty
; 			if (duty > UPPER_LIMIT) {
	ldab _duty
	cmpb _UPPER_LIMIT
	bls L51
; 				duty = UPPER_LIMIT;
	movb _UPPER_LIMIT,_duty
; 			}
L51:
; 			PWMDTY7 = duty;
	movb _duty,0xc3
; 			actualRPS = duty;
	movb _duty,_actualRPS
; 		}
L49:
; 		debounceDelay();
	jsr _debounceDelay
; 		
; 		//Press 2 to increase pump rate
; 		row = 0x01;
	movb #1,_row
; 		PTM |= 0x08; //latch is transparent
	bset 0x250,#8
; 		PTP = row; //if equals row (for button '2')
	movb _row,0x258
; 		PTM &= 0xF7;
	bclr 0x250,#8
; 		column = PTH & 0xF0;
	ldab 0x260
	andb #240
	stab _column
; 		if (column == 0x20) { //if 2 is pressed at any time
	ldab _column
	cmpb #32
	bne L53
; 			//decrease pump rate
; 			duty -= 5;
	ldab _duty
	subb #5
	stab _duty
; 			if (duty < LOWER_LIMIT) {
	ldab _duty
	cmpb _LOWER_LIMIT
	bhs L55
; 				duty = LOWER_LIMIT;
	movb _LOWER_LIMIT,_duty
; 			}
L55:
; 			PWMDTY7 = duty;
	movb _duty,0xc3
; 			actualRPS = duty;
	movb _duty,_actualRPS
; 		}
L53:
; 		debounceDelay();
	jsr _debounceDelay
; 		if (blindStart == 0) { //will only work when blinds have not started
	ldab _blindStart
	cmpb #0
	bne L57
; 			//Press 4 to raise blind
; 			row = 0x02;
	movb #2,_row
; 			PTM |= 0x08; //latch is transparent
	bset 0x250,#8
; 			PTP = row; //if equals row (for button '4')
	movb _row,0x258
; 			PTM &= 0xF7;
	bclr 0x250,#8
; 			column = PTH & 0xF0;
	ldab 0x260
	andb #240
	stab _column
; 			if (column == 0x10) { //if 4 is pressed at any time
	ldab _column
	cmpb #16
	bne L59
; 				//start motor
; 				//OC5 = TCNT + 10000 //10ms
; 				blindStart = 1;
	movb #1,_blindStart
; 			}
L59:
; 			debounceDelay();
	jsr _debounceDelay
; 		}
L57:
; 		
; 		if (blindStart == 0) {
	ldab _blindStart
	cmpb #0
	bne L61
; 			//Press 5 to lower blind
; 			row = 0x02;
	movb #2,_row
; 			PTM |= 0x08; //latch is transparent
	bset 0x250,#8
; 			PTP = row; //if equals row (for button '5')
	movb _row,0x258
; 			PTM &= 0xF7;
	bclr 0x250,#8
; 			column = PTH & 0xF0;
	ldab 0x260
	andb #240
	stab _column
; 			if (column == 0x20) { //if 5 is pressed at any time
	ldab _column
	cmpb #32
	bne L63
; 				//start motor reversed
; 				TC4 = TCNT;
	movw 0x44,0x58
; 				blindStart = 2;
	movb #2,_blindStart
; 			}
L63:
; 			debounceDelay();
	jsr _debounceDelay
; 		}
L61:
; 		
; 		if (TFLG2 & 0x80) { //if TCNT overflow is set
	brclr 0x4f,#128,L65
; 			//TCRE = 0x01; //Will clear TCNT if successful compare 7
; 			TCNT = 0x0000;
	movw #0,0x44
; 			TC4 = 0x0000;
	movw #0,0x58
; 		}
L65:
; 		
; 		//TIE |= 0x10; //For the blind control (ouput capture?)
; 	} //end while
L13:
	lbra L12
X0:
L3:
	.dbline 0 ; func end
	leas 2,S
	rts
_initHW::
; 	
; 	
; 
; }
; 
; void initHW() {
; 
; 	//Heater is port M, pin 7
; 	//This is ativated when temperature is too cold
; 	
; 	//init LCD
; 	Lcd2PP_Init();
	jsr _Lcd2PP_Init
; 	//Temp sensor is PortAD0 Pin 6 (PAD6)
; 	ATD0CTL2 |= 0xFA;
	bset 0x82,#250
; 	ATD0CTL3 |= 0x00;
	ldab 0x83
	stab 0x83
; 	ATD0CTL4 |= 0x60;
	bset 0x84,#96
; 	
; 	//stepper motor
; 	DDRP |= 0x20;
	bset 0x25a,#32
; 	DDRT |= 0x60;
	bset 0x242,#96
; 	PTP |= 0x20;
	bset 0x258,#32
; 	
; 	//Fan
; 	PWMCLK = 0x00; //Select Clock A for channel 4
	clr 0xa2
; 	PWMPRCLK |= 0x07; //Prescale ClockA : busclock/128
	bset 0xa3,#7
; 	PWMCAE &= 0xEF; //Channel 4 left aligned
	bclr 0xa4,#16
; 	PWMPER4 = 100; //Set period for PWM4
	movb #100,0xb8
; 	PWME |= 0x10; //Enable PWM channel 4
	bset 0xa0,#16
; 	//Fan is ramped up when needed
; 	
; 	//Water Pump - DC Motor
; 	PWMPOL = 0xFF; // Initial Polarity is high
	movb #255,0xa1
; 	PWMCLK &= 0x7F; //Select Clock B for channel 7
	bclr 0xa2,#128
; 	PWMPRCLK |= 0x70; //Prescale ClockB : busclock/128
	bset 0xa3,#112
; 	PWMCAE &= 0x7F; //Channel 7 : left aligned
	bclr 0xa4,#128
; 	PWMCTL &= 0xF3; //PWM in Wait and Freeze Modes
	bclr 0xa5,#12
; 	PWMPER7 = 100; //Set period for PWM7
	movb #100,0xbb
; 	PWME |= 0x80; //Enable PWM Channel 7
	bset 0xa0,#128
; 	DDRP |= 0x40; //For Motor Direction Control
	bset 0x25a,#64
; 	PAFLG |= 1; //Clear out the interrupt flag
	bset 0x61,#1
; 	PACTL = 0x50; //Enable PACA for Optical Sensor
	movb #80,0x60
; 
; 	INTR_ON();
	cli
; 	PTP = 0x00; //Clockwise 0x40 is counterClockwise;
	clr 0x258
; 	for(duty = 10; duty <= 15; duty++) { //ramp up motor
	movb #10,_duty
	bra L71
L68:
; 		PWMDTY7 = duty;
	movb _duty,0xc3
; 	}
L69:
	inc _duty
L71:
	ldab _duty
	cmpb #15
	bls L68
; 	
; 	//Output Compare
; 	TIOS |= 0x10; //select OC4 function
	bset 0x40,#16
; 	TSCR2 = 0x02; //prescale factor to 4 (0x01 is 2, 0x00 is 1)
	movb #2,0x4d
; 	TCTL2 = 0x01; //select toggle as output compare
	movb #1,0x49
; 	TSCR1 = 0x80; //enable TCNT as fast timer flag clear
	movb #128,0x46
; 	TC4 = TCNT + 500; //(high time)
	ldd 0x44
	addd #500
	std 0x58
; 	
; 	//init 7Segment?
; 	//DDRT |= 0x0F;
; 	
; 	//init Keypad
; 	DDRP |= 0x0F; //row scan (output)
	bset 0x25a,#15
; 	DDRH &= 0x0F; //column scan (input)
	bclr 0x262,#240
; 	SPI1CR1 = 0; //Disable SPI
	clr 0xf0
; 	
; 	//init LEDs
; 	DDRK = 0x0F;
	movb #15,0x33
; 	PORTK |= 0x01;
	bset 0x32,#1
; 	
; 	//init RTI ISR
; 	CRGFLG |= 0x80;
	bset 0x37,#128
; 	RTICTL |= 0x7F; //max divider 3F?
	bset 0x3b,#127
; 	CRGINT |= 0x80;
	bset 0x38,#128
; 	asm("CLI");
	CLI
L67:
	.dbline 0 ; func end
	rts
_debounceDelay::
; 	
; }
; 
; 
; /*this was used to print integers, but it's not working
; int j = 0;
; void intToString(int num) {
; 
; 	while(num != 0) {
; 	    stringArray[j] = (num % 10) + 48;
; 		num /= 10;
; 		j++;
; 	}
; 
; }*/
; void debounceDelay(void) {
; 	
; 	for(i = 0; i <= 26000; i++) {
	clr _i
	bra L76
L73:
; 		i = i*2;
	ldab _i
	clra
	lsld
	stab _i
; 		i = i/2;
	ldx #2
	ldab _i
	clra
	idivs
	tfr X,B
	stab _i
; 	}
L74:
	inc _i
L76:
	ldab _i
	clra
	cpd #26000
	ble L73
L72:
	.dbline 0 ; func end
	rts
_takeRPSReading::
; }
; 
; void takeRPSReading(void) {
; 	actualRPS = rotations;
	movb _rotations,_actualRPS
; 	rotations = 0;
	clr _rotations
; 	//actualRPS = PACN2; ?
; 	desiredRPS = actualRPS;
	movb _actualRPS,_desiredRPS
L77:
	.dbline 0 ; func end
	rts
_RTIISR::
; }
; 
; #pragma interrupt_handler RTIISR()
; void RTIISR(void) {
; 	counter++;
	ldy _counter
	iny
	sty _counter
; 	if (counter == 4) { //at 1Hz
	ldy _counter
	cpy #4
	bne L79
; 	    //time++;
; 		globalTime++; //timer that never resets
	ldy _globalTime
	iny
	sty _globalTime
;     }
L79:
; 	if (counter % 2 == 0) { //run at 2Hz
	ldx #2
	ldd _counter
	idivs
	cpd #0
	bne L81
; 		/*timer - doesnt work
; 		if (time = 9) {
; 			time = 0;
; 			time2++;
; 			if (time2 = 9) {
; 				time2 = 0;
; 				time3++;
; 				if (time3 == 9) {
; 					time3 = 0;
; 					time4++;
; 					if (time4 == 9) {
; 						time4 = 0;
; 						time3 = 0;
; 						time2 = 0;
; 						time = 0;
; 					}
; 				}
; 			}
; 		}*/
; 		//For motor
; 		if (globalTime == 1) { //take initial reading at 1 second
	ldy _globalTime
	cpy #1
	bne L83
; 			takeRPSReading();
	jsr _takeRPSReading
; 		}
L83:
; 		ATD0CTL5 = 0x86; //take temperature reading
	movb #134,0x85
; 	}
L81:
; 	CRGFLG |= 0x80;
	bset 0x37,#128
L78:
	.dbline 0 ; func end
	rti
_ADInt::
; }
; 
; #pragma interrupt_handler ADInt()
; void ADInt(void) {
; 	
; 	temp = ATD0DR6 & 0x0300; //as per slides
	ldd 0x9c
	anda #3
	andb #0
	std _temp
; 	temp = (temp >> 3) + 5; //or temp = (ATD0DR6 / 8) - 5; - not + because that's what was done in class
	ldd _temp
	asra
	rorb
	asra
	rorb
	asra
	rorb
	addd #5
	std _temp
; 	temp = (temp * 5) / 9;
	ldd #5
	ldy _temp
	emul
	tfr D,Y
	ldx #9
	tfr Y,D
	idivs
	stx _temp
; 	temp -= 32; //convert to C
	ldd _temp
	subd #32
	std _temp
L85:
	.dbline 0 ; func end
	rti
	.area data
_next::
	.blkb 1
	.area idata
	.byte 0
	.area data
	.area text
_TIMERISR::
; 	
; }
; 
; char next = 0;
; #pragma interrupt_handler TIMERISR()
; //This will happen when TC4 = TCNT
; void TIMERISR(void) {
; 	if (blindStart == 1) {
	ldab _blindStart
	cmpb #1
	lbne L87
; 		
; 		 if (next == 0) {
	ldab _next
	cmpb #0
	bne L89
; 		 		PTT |= 0x60;
	bset 0x240,#96
; 				TC4 = TCNT + 1000000; //do this in 1s
	ldy 0x44
	pshy
	movw #0,2,-S
	movw #16960,2,-S
	movw #15,2,-S
	jsr add4
	leas 2,S
	puly
	sty 0x58
; 				next = 1;
	movb #1,_next
; 		 }
	lbra L88
L89:
; 		 else if (next == 1) { 
	ldab _next
	cmpb #1
	bne L91
; 		 		PTT |= 0x40;
	bset 0x240,#64
; 				TC4 = TCNT + 1000000; //1s
	ldy 0x44
	pshy
	movw #0,2,-S
	movw #16960,2,-S
	movw #15,2,-S
	jsr add4
	leas 2,S
	puly
	sty 0x58
; 				next = 2;
	movb #2,_next
; 		 }
	lbra L88
L91:
; 		 else if (next == 2) {
	ldab _next
	cmpb #2
	bne L93
; 		 		PTT |= 0x00;
	ldab 0x240
	stab 0x240
; 				TC4 = TCNT + 1000000; //1s
	ldy 0x44
	pshy
	movw #0,2,-S
	movw #16960,2,-S
	movw #15,2,-S
	jsr add4
	leas 2,S
	puly
	sty 0x58
; 				next = 3;
	movb #3,_next
; 		 }
	lbra L88
L93:
; 		 else if (next == 3) {
	ldab _next
	cmpb #3
	bne L95
; 		 		PTT |= 0x20;
	bset 0x240,#32
; 				TC4 = TCNT + 1000000; //1s
	ldy 0x44
	pshy
	movw #0,2,-S
	movw #16960,2,-S
	movw #15,2,-S
	jsr add4
	leas 2,S
	puly
	sty 0x58
; 				next = 4;
	movb #4,_next
; 		 }
	lbra L88
L95:
; 		 else if (next == 4) {
	ldab _next
	cmpb #4
	bne L97
; 		 	TC4 = TCNT + 1000000; //1s for a total of 5s
	ldy 0x44
	pshy
	movw #0,2,-S
	movw #16960,2,-S
	movw #15,2,-S
	jsr add4
	leas 2,S
	puly
	sty 0x58
; 			next = 5;
	movb #5,_next
; 		} else if (next == 5) {
	lbra L88
L97:
	ldab _next
	cmpb #5
	lbne L88
; 			next = 0;
	clr _next
; 			blindStart = 0;
	clr _blindStart
; 		}
; 		
; 	} else if (blindStart == 2) {
	lbra L88
L87:
	ldab _blindStart
	cmpb #2
	lbne L101
; 	
; 		//go opposite direction
; 		 if (next == 0) {
	ldab _next
	cmpb #0
	bne L103
; 				PTT |= 0x20;
	bset 0x240,#32
; 				TC4 = TCNT + 1000000;
	ldy 0x44
	pshy
	movw #0,2,-S
	movw #16960,2,-S
	movw #15,2,-S
	jsr add4
	leas 2,S
	puly
	sty 0x58
; 				next = 1;
	movb #1,_next
; 		 }
	lbra L104
L103:
; 		 else if (next == 1) { 
	ldab _next
	cmpb #1
	bne L105
; 				PTT |= 0x00;
	ldab 0x240
	stab 0x240
; 				TC4 = TCNT + 1000000;
	ldy 0x44
	pshy
	movw #0,2,-S
	movw #16960,2,-S
	movw #15,2,-S
	jsr add4
	leas 2,S
	puly
	sty 0x58
; 				next = 2;
	movb #2,_next
; 		 }
	lbra L106
L105:
; 		 else if (next == 2) {
	ldab _next
	cmpb #2
	bne L107
; 		 		PTT |= 0x40;
	bset 0x240,#64
; 				TC4 = TCNT + 1000000;
	ldy 0x44
	pshy
	movw #0,2,-S
	movw #16960,2,-S
	movw #15,2,-S
	jsr add4
	leas 2,S
	puly
	sty 0x58
; 				next = 3;
	movb #3,_next
; 		 }
	lbra L108
L107:
; 		 else if (next == 3) {
	ldab _next
	cmpb #3
	bne L109
; 		 		PTT |= 0x60;
	bset 0x240,#96
; 				TC4 = TCNT + 1000000;
	ldy 0x44
	pshy
	movw #0,2,-S
	movw #16960,2,-S
	movw #15,2,-S
	jsr add4
	leas 2,S
	puly
	sty 0x58
; 				next = 4;
	movb #4,_next
; 		 }
	bra L110
L109:
; 		 else if (next == 4) {
	ldab _next
	cmpb #4
	bne L111
; 		 	TC4 = TCNT + 1000000; //1s for a total of 5s
	ldy 0x44
	pshy
	movw #0,2,-S
	movw #16960,2,-S
	movw #15,2,-S
	jsr add4
	leas 2,S
	puly
	sty 0x58
; 			next = 5;
	movb #5,_next
; 		} else if (next == 5) {
	bra L112
L111:
	ldab _next
	cmpb #5
	bne L113
; 			next = 0;
	clr _next
; 			blindStart = 0;
	clr _blindStart
; 		}
L113:
L112:
L110:
L108:
L106:
L104:
; 	
; 	}
L101:
L88:
; 	TFLG1 |= 0x10;
	bset 0x4e,#16
L86:
	.dbline 0 ; func end
	rti
_pacA_ISR::
; }
; 
; #pragma interrupt_handler TIMERISR()
; void pacA_ISR(void) {
; 	
; 	rotations++;
	inc _rotations
; 	PAFLG |= 0x01;
	bset 0x61,#1
L115:
	.dbline 0 ; func end
	rts
	.area bss
_rotations::
	.blkb 1
_desiredRPS::
	.blkb 1
_actualRPS::
	.blkb 1
_fan_duty::
	.blkb 1
_duty::
	.blkb 1
_column::
	.blkb 1
_row::
	.blkb 1
_i::
	.blkb 1
