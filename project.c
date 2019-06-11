#include "hcs12dp256.h"
#include <stdio.h>
//keypad & for loops
char i, row, column;

//stepper motor
char blindStart = 0;

char duty; // For the motor (water pump)
char fan_duty; //for fan
char actualRPS, desiredRPS, rotations;
static char LOWER_LIMIT = 10, UPPER_LIMIT = 50;

int temp = 0, previousTemp = 0; //temperature

int time = 0, time2 = 0, time3 = 0, time4 = 0, globalTime = 0;
int counter = 0; //number of clock ticks
char incTens = 0, incHunds = 0, incThou = 0;

char stringArr1[] = "GMS Time:0000 s";
char stringArr2[] = "T:00C P: 00RPS";
char stringArray[] = "0000";

void main() {
	initHW();
	
	//write static portion of LCD
	for (i = 0; i <= 14; i++) {
		LCD_display(stringArr1[i]);
	}
	LCD_instruction(0xc0); //newline
	for (i = 0; i <= 13; i++) {
		LCD_display(stringArr2[i]);
	}
	
	while (1) {
		//Timer
		if (counter == 4) {
			
			/*time++; - not working
			LCD_instruction(0x89);
			LCD_display(time4 + 0x30);
			LCD_instruction(0x8A);
			LCD_display(time3 + 0x30);
			LCD_instruction(0x8B);
			LCD_display(time2 + 0x30);
			LCD_instruction(0x8C);
			LCD_display(time + 0x30);*/
			
	    	if (time == -1 && time2 == -1 && time3 == -1) {
		    	time4++;
		    	LCD_instruction(0x89);
		    	LCD_display(time4 + 0x30);
		        if (time4 == 9) {
		   	       time4 = -1;
		        }
		    }
	   		if (time == -1 && time2 == -1) {
		       time3++;
		       LCD_instruction(0x8A);
		       LCD_display(time3 + 0x30);
		       if (time3 == 9) {
		   	      time3 = -1;
		       }
		    }
	   		if (incTens == 1) {
		       time2++;
		       LCD_instruction(0x8B);
		       LCD_display(time2 + 0x30);
		       incTens = 0;
		       if (time2 == 9) { 
		   	      time2 = -1;
		       }
		    }
		    time++;
		    LCD_instruction(0x8C); //0x80 forces cursor to first line. 0xC0 is second line
		    LCD_display(time + 0x30);
		    if (time == 9) {
		       time = -1;
		       incTens = 1;
		    }
		    counter = 0;
	    }
		//End Timer
		
		if (temp != previousTemp) { //display updated temperature
			 LCD_instruction(0xC3);
			 LCD_display((temp % 10) + 0x30); //have to print 1 digit at a time
			 LCD_instruction(0xC4);
			 LCD_display((temp / 10) + 0x30);
			 previousTemp = temp;
		}
		if (temp > 24 && fan_duty != 100) { //23C + 2 = 25 (too hot)
			//ramp fan
			PTM &= 0x7F; //clear bit 7 to turn off heater
			for (fan_duty = 0; fan_duty <= 100; fan_duty++) { //ramp up fan
				PWMDTY4 = fan_duty;
			}	
		} else if (temp < 22) { //turn on heater, turn off fan. 23C - 2 = 21 (too cold)
			PTM |= 0x80; //note: heater on RTI needs to trigger ADCISR?
			for (i = fan_duty; i >= 1; i--) { //decelerate fan
				PWMDTY4 = i;
		    }
		}
		//Motor RPS
		if (desiredRPS != actualRPS) {
			LCD_instruction(0xCA);
			LCD_display((actualRPS % 10) + 0x30);
			LCD_instruction(0xCB);
			LCD_display((actualRPS / 10) + 0x30);
			desiredRPS = actualRPS;
		}
		
		//polling for button press 'F' to quit
		row = 0x08;
		PTM |= 0x08; //latch is transparent
		PTP = row; //if equals row (for button 'F')
		PTM &= 0xF7;
		column = PTH & 0xF0;
		if (column == 0x40) { //if F is pressed at any time
			PORTK &= 0x00; //turn off LEDs
			PTT = 0; //set 7-segment to 0
			CRGINT &= 0x00; //disable interrupts
			LCD_instruction(0x01);//Clear LCD
			//PWMDTY7 = 0; //stop motor
			//PWMDTY4 = 0; //stop fan
			exit(); 
		}
		debounceDelay();
		
		//Press 1 to increase pump rate
		row = 0x01;
		PTM |= 0x08; //latch is transparent
		PTP = row; //if equals row (for button '1')
		PTM &= 0xF7;
		column = PTH & 0xF0;
		if (column == 0x10) { //if 1 is pressed at any time
			//increase pump rate
			duty += 5;
			if (duty > UPPER_LIMIT) {
				duty = UPPER_LIMIT;
			}
			PWMDTY7 = duty;
			actualRPS = duty;
		}
		debounceDelay();
		
		//Press 2 to increase pump rate
		row = 0x01;
		PTM |= 0x08; //latch is transparent
		PTP = row; //if equals row (for button '2')
		PTM &= 0xF7;
		column = PTH & 0xF0;
		if (column == 0x20) { //if 2 is pressed at any time
			//decrease pump rate
			duty -= 5;
			if (duty < LOWER_LIMIT) {
				duty = LOWER_LIMIT;
			}
			PWMDTY7 = duty;
			actualRPS = duty;
		}
		debounceDelay();
		if (blindStart == 0) { //will only work when blinds have not started
			//Press 4 to raise blind
			row = 0x02;
			PTM |= 0x08; //latch is transparent
			PTP = row; //if equals row (for button '4')
			PTM &= 0xF7;
			column = PTH & 0xF0;
			if (column == 0x10) { //if 4 is pressed at any time
				//start motor
				//OC5 = TCNT + 10000 //10ms
				blindStart = 1;
			}
			debounceDelay();
		}
		
		if (blindStart == 0) {
			//Press 5 to lower blind
			row = 0x02;
			PTM |= 0x08; //latch is transparent
			PTP = row; //if equals row (for button '5')
			PTM &= 0xF7;
			column = PTH & 0xF0;
			if (column == 0x20) { //if 5 is pressed at any time
				//start motor reversed
				TC4 = TCNT;
				blindStart = 2;
			}
			debounceDelay();
		}
		
		if (TFLG2 & 0x80) { //if TCNT overflow is set
			//TCRE = 0x01; //Will clear TCNT if successful compare 7
			TCNT = 0x0000;
			TC4 = 0x0000;
		}
		
		//TIE |= 0x10; //For the blind control (ouput capture?)
	} //end while
	
	

}

void initHW() {

	//Heater is port M, pin 7
	//This is ativated when temperature is too cold
	
	//init LCD
	Lcd2PP_Init();
	//Temp sensor is PortAD0 Pin 6 (PAD6)
	ATD0CTL2 |= 0xFA;
	ATD0CTL3 |= 0x00;
	ATD0CTL4 |= 0x60;
	
	//stepper motor
	DDRP |= 0x20;
	DDRT |= 0x60;
	PTP |= 0x20;
	
	//Fan
	PWMCLK = 0x00; //Select Clock A for channel 4
	PWMPRCLK |= 0x07; //Prescale ClockA : busclock/128
	PWMCAE &= 0xEF; //Channel 4 left aligned
	PWMPER4 = 100; //Set period for PWM4
	PWME |= 0x10; //Enable PWM channel 4
	//Fan is ramped up when needed
	
	//Water Pump - DC Motor
	PWMPOL = 0xFF; // Initial Polarity is high
	PWMCLK &= 0x7F; //Select Clock B for channel 7
	PWMPRCLK |= 0x70; //Prescale ClockB : busclock/128
	PWMCAE &= 0x7F; //Channel 7 : left aligned
	PWMCTL &= 0xF3; //PWM in Wait and Freeze Modes
	PWMPER7 = 100; //Set period for PWM7
	PWME |= 0x80; //Enable PWM Channel 7
	DDRP |= 0x40; //For Motor Direction Control
	PAFLG |= 1; //Clear out the interrupt flag
	PACTL = 0x50; //Enable PACA for Optical Sensor

	INTR_ON();
	PTP = 0x00; //Clockwise 0x40 is counterClockwise;
	for(duty = 10; duty <= 15; duty++) { //ramp up motor
		PWMDTY7 = duty;
	}
	
	//Output Compare
	TIOS |= 0x10; //select OC4 function
	TSCR2 = 0x02; //prescale factor to 4 (0x01 is 2, 0x00 is 1)
	TCTL2 = 0x01; //select toggle as output compare
	TSCR1 = 0x80; //enable TCNT as fast timer flag clear
	TC4 = TCNT + 500; //(high time)
	
	//init 7Segment?
	//DDRT |= 0x0F;
	
	//init Keypad
	DDRP |= 0x0F; //row scan (output)
	DDRH &= 0x0F; //column scan (input)
	SPI1CR1 = 0; //Disable SPI
	
	//init LEDs
	DDRK = 0x0F;
	PORTK |= 0x01;
	
	//init RTI ISR
	CRGFLG |= 0x80;
	RTICTL |= 0x7F; //max divider 3F?
	CRGINT |= 0x80;
	asm("CLI");
	
}


/*this was used to print integers, but it's not working
int j = 0;
void intToString(int num) {

	while(num != 0) {
	    stringArray[j] = (num % 10) + 48;
		num /= 10;
		j++;
	}

}*/
void debounceDelay(void) {
	
	for(i = 0; i <= 26000; i++) {
		i = i*2;
		i = i/2;
	}
}

void takeRPSReading(void) {
	actualRPS = rotations;
	rotations = 0;
	//actualRPS = PACN2; ?
	desiredRPS = actualRPS;
}

#pragma interrupt_handler RTIISR()
void RTIISR(void) {
	counter++;
	if (counter == 4) { //at 1Hz
	    //time++;
		globalTime++; //timer that never resets
    }
	if (counter % 2 == 0) { //run at 2Hz
		/*timer - doesnt work
		if (time = 9) {
			time = 0;
			time2++;
			if (time2 = 9) {
				time2 = 0;
				time3++;
				if (time3 == 9) {
					time3 = 0;
					time4++;
					if (time4 == 9) {
						time4 = 0;
						time3 = 0;
						time2 = 0;
						time = 0;
					}
				}
			}
		}*/
		//For motor
		if (globalTime == 1) { //take initial reading at 1 second
			takeRPSReading();
		}
		ATD0CTL5 = 0x86; //take temperature reading
	}
	CRGFLG |= 0x80;
}

#pragma interrupt_handler ADInt()
void ADInt(void) {
	
	temp = ATD0DR6 & 0x0300; //as per slides
	temp = (temp >> 3) + 5; //or temp = (ATD0DR6 / 8) - 5; - not + because that's what was done in class
	temp = (temp * 5) / 9;
	temp -= 32; //convert to C
	
}

char next = 0;
#pragma interrupt_handler TIMERISR()
//This will happen when TC4 = TCNT
void TIMERISR(void) {
	if (blindStart == 1) {
		
		 if (next == 0) {
		 		PTT |= 0x60;
				TC4 = TCNT + 1000000; //do this in 1s
				next = 1;
		 }
		 else if (next == 1) { 
		 		PTT |= 0x40;
				TC4 = TCNT + 1000000; //1s
				next = 2;
		 }
		 else if (next == 2) {
		 		PTT |= 0x00;
				TC4 = TCNT + 1000000; //1s
				next = 3;
		 }
		 else if (next == 3) {
		 		PTT |= 0x20;
				TC4 = TCNT + 1000000; //1s
				next = 4;
		 }
		 else if (next == 4) {
		 	TC4 = TCNT + 1000000; //1s for a total of 5s
			next = 5;
		} else if (next == 5) {
			next = 0;
			blindStart = 0;
		}
		
	} else if (blindStart == 2) {
	
		//go opposite direction
		 if (next == 0) {
				PTT |= 0x20;
				TC4 = TCNT + 1000000;
				next = 1;
		 }
		 else if (next == 1) { 
				PTT |= 0x00;
				TC4 = TCNT + 1000000;
				next = 2;
		 }
		 else if (next == 2) {
		 		PTT |= 0x40;
				TC4 = TCNT + 1000000;
				next = 3;
		 }
		 else if (next == 3) {
		 		PTT |= 0x60;
				TC4 = TCNT + 1000000;
				next = 4;
		 }
		 else if (next == 4) {
		 	TC4 = TCNT + 1000000; //1s for a total of 5s
			next = 5;
		} else if (next == 5) {
			next = 0;
			blindStart = 0;
		}
	
	}
	TFLG1 |= 0x10;
}

#pragma interrupt_handler TIMERISR()
void pacA_ISR(void) {
	
	rotations++;
	PAFLG |= 0x01;
		 
}