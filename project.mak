CC = icc12w
LIB = ilibw
CFLAGS =  -e -D__ICC_VERSION=708 -D__BUILD=119  -l 
ASFLAGS = $(CFLAGS) 
LFLAGS =  -nb:119 -btext:0x4000 -bdata:0x1000 -s2_s1 -dinit_sp:0x3DFF -fmots19
FILES = SYSC2003A5.o DP256Reg.o basicLCD.o assign5vector.c.o 

SYSC2003_A5:	$(FILES)
	$(CC) -o SYSC2003_A5 $(LFLAGS) @SYSC2003_A5.lk  
SYSC2003A5.o: .\..\SY54DE~1\hcs12dp256.h C:\iccv712\include\hc12def.h C:\iccv712\include\stdio.h C:\iccv712\include\stdarg.h C:\iccv712\include\_const.h
SYSC2003A5.o:	..\SY54DE~1\SYSC2003A5.c
	$(CC) -c $(CFLAGS) ..\SY54DE~1\SYSC2003A5.c
DP256Reg.o:	..\SY54DE~1\DP256Reg.s
	$(CC) -c $(ASFLAGS) ..\SY54DE~1\DP256Reg.s
basicLCD.o: M:\SY54DE~1\DP256reg.s 
basicLCD.o:	..\SY54DE~1\basicLCD.s
	$(CC) -c $(ASFLAGS) ..\SY54DE~1\basicLCD.s
assign5vector.c.o:
assign5vector.c.o:	..\SY54DE~1\assign5vector.c.c
	$(CC) -c $(CFLAGS) ..\SY54DE~1\assign5vector.c.c
