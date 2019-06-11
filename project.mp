Project:      SYSC2003_A5
Build Number: 119
Date:         Tue Apr 04 12:32:42 2017
Compiler:     ICC12
Version:      7.50


Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                            text   4000   07E8 =   2024. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       4000  __start
       4026  _exit
       4028  __text_start
       4028  _main
       435D  _initHW
       4414  _debounceDelay
       443C  _takeRPSReading
       444C  _RTIISR
       4484  _ADInt
       44BA  _TIMERISR
       46C9  _pacA_ISR
       46D1  _LCD_instruction
       46DD  _LCD_display
       46E9  _Lcd2PP_Init
       47B9  add4
       47CE  sub4
       47E3  __HC12Setup
       47E8  __text_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                           idata   47E8   003B =     59. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       47E8  __idata_start
       4823  __idata_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                            data   1000   003B =     59. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       1000  __data_start
       1000  _blindStart
       1003  _temp
       1005  _previousTemp
       1007  _time
       1009  _time2
       100B  _time3
       100D  _time4
       100F  _globalTime
       1011  _counter
       1013  _incTens
       1014  _incHunds
       1015  _incThou
       1016  _stringArr1
       1026  _stringArr2
       1035  _stringArray
       103A  _next
       103B  __data_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                             bss   103B   0008 =      8. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       103B  _rotations
       103B  __bss_start
       103C  _desiredRPS
       103D  _actualRPS
       103E  _fan_duty
       103F  _duty
       1040  _column
       1041  _row
       1042  _i
       1043  __bss_end

Area                               Start  End    Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                          memory   3F8C   4000 =  16384. bytes (abs,ovr,rom)

       Addr  Global Symbol
      -----  --------------------------------
       3F8C  _interrupt_vectors

Files Linked      [ module(s) ]

C:\iccv712\lib\crt12.o	[ crt12.s ]
SYSC2003A5.o	[ SYSC2003A5.c ]
DP256Reg.o	[ DP256Reg.s ]
basicLCD.o	[ basicLCD.s ]
assign5vector.c.o	[ assign5vector.c.c ]
<library>	[ ladd.s, setup.s ]

User Global Definitions

init_sp = 0x3dff

Area Definitions

-btext:0x4000.0xffff
-bdata:0x1000.0xffff

