
_interrupt:

;projet.c,46 :: 		void interrupt(){              // Interrupt routine
;projet.c,48 :: 		if(RBIF_bit) {         // Checks for Extern Interrupt Flag bit
	BTFSS       RBIF_bit+0, BitPos(RBIF_bit+0) 
	GOTO        L_interrupt0
;projet.c,49 :: 		if(PORTB.B6 == 1){   // Arrêt urgence (RB6)
	BTFSS       PORTB+0, 6 
	GOTO        L_interrupt1
;projet.c,50 :: 		flag = 1;
	BSF         _flag+0, BitPos(_flag+0) 
;projet.c,51 :: 		}
L_interrupt1:
;projet.c,52 :: 		if(PORTB.B7 == 1){  // Ajout compteur FDC (RB7)
	BTFSS       PORTB+0, 7 
	GOTO        L_interrupt2
;projet.c,53 :: 		nbBottle ++;
	INFSNZ      _nbBottle+0, 1 
	INCF        _nbBottle+1, 1 
;projet.c,54 :: 		}
L_interrupt2:
;projet.c,55 :: 		RBIF_bit = 0;              // Clear Interrupt Flag
	BCF         RBIF_bit+0, BitPos(RBIF_bit+0) 
;projet.c,56 :: 		}
L_interrupt0:
;projet.c,58 :: 		if (TMR0IF_bit){ // Timer0 toutes les 5ms
	BTFSS       TMR0IF_bit+0, BitPos(TMR0IF_bit+0) 
	GOTO        L_interrupt3
;projet.c,59 :: 		TMR0IF_bit = 0;
	BCF         TMR0IF_bit+0, BitPos(TMR0IF_bit+0) 
;projet.c,60 :: 		TMR0H = 0xD8;
	MOVLW       216
	MOVWF       TMR0H+0 
;projet.c,61 :: 		TMR0L = 0xF0;
	MOVLW       240
	MOVWF       TMR0L+0 
;projet.c,62 :: 		count ++;
	INFSNZ      _count+0, 1 
	INCF        _count+1, 1 
;projet.c,63 :: 		}
L_interrupt3:
;projet.c,65 :: 		if(RC1IF_bit) // Checks for Receive Interrupt Flag bit
	BTFSS       RC1IF_bit+0, BitPos(RC1IF_bit+0) 
	GOTO        L_interrupt4
;projet.c,67 :: 		flag_uart = 1;
	BSF         _flag_uart+0, BitPos(_flag_uart+0) 
;projet.c,68 :: 		UART1_Read_Text(incomingByte,"LF",11); // Storing read data
	MOVLW       _incomingByte+0
	MOVWF       FARG_UART1_Read_Text_Output+0 
	MOVLW       hi_addr(_incomingByte+0)
	MOVWF       FARG_UART1_Read_Text_Output+1 
	MOVLW       ?lstr1_projet+0
	MOVWF       FARG_UART1_Read_Text_Delimiter+0 
	MOVLW       hi_addr(?lstr1_projet+0)
	MOVWF       FARG_UART1_Read_Text_Delimiter+1 
	MOVLW       11
	MOVWF       FARG_UART1_Read_Text_Attempts+0 
	CALL        _UART1_Read_Text+0, 0
;projet.c,69 :: 		RC1IF_bit = 0;
	BCF         RC1IF_bit+0, BitPos(RC1IF_bit+0) 
;projet.c,70 :: 		}
L_interrupt4:
;projet.c,71 :: 		}
L_end_interrupt:
L__interrupt39:
	RETFIE      1
; end of _interrupt

_writeE2prom:

;projet.c,75 :: 		void writeE2prom(int adress, char dataValue){
;projet.c,76 :: 		I2C1_Start(); // issue I2C start signal
	CALL        _I2C1_Start+0, 0
;projet.c,77 :: 		I2C1_Wr(0xA2); // send byte via I2C (device address + W)
	MOVLW       162
	MOVWF       FARG_I2C1_Wr_data_+0 
	CALL        _I2C1_Wr+0, 0
;projet.c,78 :: 		I2C1_Wr(adress); // send b yte (address of EEPROM location)
	MOVF        FARG_writeE2prom_adress+0, 0 
	MOVWF       FARG_I2C1_Wr_data_+0 
	CALL        _I2C1_Wr+0, 0
;projet.c,79 :: 		I2C1_Wr(dataValue); // send data (data to be written)
	MOVF        FARG_writeE2prom_dataValue+0, 0 
	MOVWF       FARG_I2C1_Wr_data_+0 
	CALL        _I2C1_Wr+0, 0
;projet.c,80 :: 		I2C1_Stop(); // issue I2C stop signal
	CALL        _I2C1_Stop+0, 0
;projet.c,81 :: 		}
L_end_writeE2prom:
	RETURN      0
; end of _writeE2prom

_main:

;projet.c,84 :: 		void main() {
;projet.c,85 :: 		ANSELA = 3;                  // PORT A analog (00000011)
	MOVLW       3
	MOVWF       ANSELA+0 
;projet.c,86 :: 		ANSELB = 0;                  // Configure PORT B pins as digital
	CLRF        ANSELB+0 
;projet.c,87 :: 		ANSELC = 0;                  // Configure C pin as digital
	CLRF        ANSELC+0 
;projet.c,88 :: 		ANSELD = 0;                  // PORT D digital
	CLRF        ANSELD+0 
;projet.c,90 :: 		TRISA = 3;                   // PORTA input (00000011)
	MOVLW       3
	MOVWF       TRISA+0 
;projet.c,91 :: 		TRISB  = 0b11000000;         // Set PORT B direction
	MOVLW       192
	MOVWF       TRISB+0 
;projet.c,92 :: 		TRISD = 0;                   // Set PORT D output
	CLRF        TRISD+0 
;projet.c,93 :: 		TRISE.RE0 = 1;               // Disable CCPx pin output by setting
	BSF         TRISE+0, 0 
;projet.c,96 :: 		RBIE_bit  = 1;               // Enable Port B Interrupt-On-Change
	BSF         RBIE_bit+0, BitPos(RBIE_bit+0) 
;projet.c,97 :: 		IOCB6_bit = 1;               // Enable RB6 interrupt pin
	BSF         IOCB6_bit+0, BitPos(IOCB6_bit+0) 
;projet.c,98 :: 		IOCB7_bit = 1;               // Enable RB7 interrupt pin
	BSF         IOCB7_bit+0, BitPos(IOCB7_bit+0) 
;projet.c,99 :: 		TMR0IE_bit = 1;
	BSF         TMR0IE_bit+0, BitPos(TMR0IE_bit+0) 
;projet.c,100 :: 		T0CON = 0x88;
	MOVLW       136
	MOVWF       T0CON+0 
;projet.c,101 :: 		TMR0H = 0xD8;
	MOVLW       216
	MOVWF       TMR0H+0 
;projet.c,102 :: 		TMR0L = 0xF0;
	MOVLW       240
	MOVWF       TMR0L+0 
;projet.c,103 :: 		GIE_bit = 1;                 // Enable GLOBAL interrupts
	BSF         GIE_bit+0, BitPos(GIE_bit+0) 
;projet.c,105 :: 		Sound_Init(&PORTE, 1);       // Init sound PORTE1
	MOVLW       PORTE+0
	MOVWF       FARG_Sound_Init_snd_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Sound_Init_snd_port+1 
	MOVLW       1
	MOVWF       FARG_Sound_Init_snd_pin+0 
	CALL        _Sound_Init+0, 0
;projet.c,106 :: 		Lcd_Init();                  // Init LCD
	CALL        _Lcd_Init+0, 0
;projet.c,107 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;projet.c,108 :: 		I2C1_Init(100000);           // initialize I2C communication
	MOVLW       20
	MOVWF       SSP1ADD+0 
	CALL        _I2C1_Init+0, 0
;projet.c,110 :: 		UART1_Init(9600);             //UART INIT
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       207
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;projet.c,111 :: 		RC1IE_bit = 1; // turn ON interrupt on UART1 receive
	BSF         RC1IE_bit+0, BitPos(RC1IE_bit+0) 
;projet.c,112 :: 		RC1IF_bit = 0; // Clear interrupt flag
	BCF         RC1IF_bit+0, BitPos(RC1IF_bit+0) 
;projet.c,113 :: 		PEIE_bit = 1; // Enable peripheral interrupts
	BSF         PEIE_bit+0, BitPos(PEIE_bit+0) 
;projet.c,116 :: 		endSwitch = 0;               // Flag for button
	BCF         _endSwitch+0, BitPos(_endSwitch+0) 
;projet.c,117 :: 		flag = 0;                    // Flag for interruption
	BCF         _flag+0, BitPos(_flag+0) 
;projet.c,118 :: 		flagRaz = 0;
	BCF         _flagRaz+0, BitPos(_flagRaz+0) 
;projet.c,119 :: 		C1ON_bit = 0;                        //disable comparators
	BCF         C1ON_bit+0, BitPos(C1ON_bit+0) 
;projet.c,120 :: 		C2ON_bit = 0;
	BCF         C2ON_bit+0, BitPos(C2ON_bit+0) 
;projet.c,121 :: 		work = 1;
	BSF         _work+0, BitPos(_work+0) 
;projet.c,123 :: 		while(1) {
L_main5:
;projet.c,125 :: 		if (work == 1){
	BTFSS       _work+0, BitPos(_work+0) 
	GOTO        L_main7
;projet.c,127 :: 		if(flag){
	BTFSS       _flag+0, BitPos(_flag+0) 
	GOTO        L_main8
;projet.c,128 :: 		flag = 0;                    // Reset flag interruption
	BCF         _flag+0, BitPos(_flag+0) 
;projet.c,129 :: 		LATD = 0;                    // Turn off leds on Port D
	CLRF        LATD+0 
;projet.c,130 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;projet.c,131 :: 		Lcd_Out(1,1,"  EMERGENCY ON");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr2_projet+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr2_projet+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;projet.c,132 :: 		while(PORTB.B6 == 1){
L_main9:
	BTFSS       PORTB+0, 6 
	GOTO        L_main10
;projet.c,133 :: 		LATD = ~LATD;              // Toggle LEDs on PORTD
	COMF        LATD+0, 1 
;projet.c,134 :: 		delay_ms(500);
	MOVLW       6
	MOVWF       R11, 0
	MOVLW       19
	MOVWF       R12, 0
	MOVLW       173
	MOVWF       R13, 0
L_main11:
	DECFSZ      R13, 1, 1
	BRA         L_main11
	DECFSZ      R12, 1, 1
	BRA         L_main11
	DECFSZ      R11, 1, 1
	BRA         L_main11
	NOP
	NOP
;projet.c,135 :: 		Sound_Play(2000, 1000);    // Play sound f = 1000Hz for 1s
	MOVLW       208
	MOVWF       FARG_Sound_Play_freq_in_hz+0 
	MOVLW       7
	MOVWF       FARG_Sound_Play_freq_in_hz+1 
	MOVLW       232
	MOVWF       FARG_Sound_Play_duration_ms+0 
	MOVLW       3
	MOVWF       FARG_Sound_Play_duration_ms+1 
	CALL        _Sound_Play+0, 0
;projet.c,136 :: 		}
	GOTO        L_main9
L_main10:
;projet.c,137 :: 		}
L_main8:
;projet.c,140 :: 		speedConveyor = ADC_read(1);   // Get ADC value
	MOVLW       1
	MOVWF       FARG_ADC_Read_channel+0 
	CALL        _ADC_Read+0, 0
	CALL        _word2double+0, 0
	MOVF        R0, 0 
	MOVWF       _speedConveyor+0 
	MOVF        R1, 0 
	MOVWF       _speedConveyor+1 
	MOVF        R2, 0 
	MOVWF       _speedConveyor+2 
	MOVF        R3, 0 
	MOVWF       _speedConveyor+3 
;projet.c,141 :: 		Bcd2Dec(speedConveyor);        // Convert ADC value to decimal
	CALL        _double2byte+0, 0
	MOVF        R0, 0 
	MOVWF       FARG_Bcd2Dec_bcdnum+0 
	CALL        _Bcd2Dec+0, 0
;projet.c,142 :: 		delayK2000 = (-0.1*(speedConveyor-100)) + 200;   // Set delay of K2000
	MOVLW       0
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	MOVLW       72
	MOVWF       R6 
	MOVLW       133
	MOVWF       R7 
	MOVF        _speedConveyor+0, 0 
	MOVWF       R0 
	MOVF        _speedConveyor+1, 0 
	MOVWF       R1 
	MOVF        _speedConveyor+2, 0 
	MOVWF       R2 
	MOVF        _speedConveyor+3, 0 
	MOVWF       R3 
	CALL        _Sub_32x32_FP+0, 0
	MOVLW       205
	MOVWF       R4 
	MOVLW       204
	MOVWF       R5 
	MOVLW       204
	MOVWF       R6 
	MOVLW       123
	MOVWF       R7 
	CALL        _Mul_32x32_FP+0, 0
	MOVLW       0
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	MOVLW       72
	MOVWF       R6 
	MOVLW       134
	MOVWF       R7 
	CALL        _Add_32x32_FP+0, 0
	CALL        _double2int+0, 0
	MOVF        R0, 0 
	MOVWF       _delayK2000+0 
	MOVF        R1, 0 
	MOVWF       _delayK2000+1 
;projet.c,143 :: 		sprintf(buff1,"V:%.3fm/s|Count",speedConveyor/1000);
	MOVLW       _buff1+0
	MOVWF       FARG_sprintf_wh+0 
	MOVLW       hi_addr(_buff1+0)
	MOVWF       FARG_sprintf_wh+1 
	MOVLW       ?lstr_3_projet+0
	MOVWF       FARG_sprintf_f+0 
	MOVLW       hi_addr(?lstr_3_projet+0)
	MOVWF       FARG_sprintf_f+1 
	MOVLW       higher_addr(?lstr_3_projet+0)
	MOVWF       FARG_sprintf_f+2 
	MOVLW       0
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	MOVLW       122
	MOVWF       R6 
	MOVLW       136
	MOVWF       R7 
	MOVF        _speedConveyor+0, 0 
	MOVWF       R0 
	MOVF        _speedConveyor+1, 0 
	MOVWF       R1 
	MOVF        _speedConveyor+2, 0 
	MOVWF       R2 
	MOVF        _speedConveyor+3, 0 
	MOVWF       R3 
	CALL        _Div_32x32_FP+0, 0
	MOVF        R0, 0 
	MOVWF       FARG_sprintf_wh+5 
	MOVF        R1, 0 
	MOVWF       FARG_sprintf_wh+6 
	MOVF        R2, 0 
	MOVWF       FARG_sprintf_wh+7 
	MOVF        R3, 0 
	MOVWF       FARG_sprintf_wh+8 
	CALL        _sprintf+0, 0
;projet.c,144 :: 		Lcd_Out(1,1,buff1);
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       _buff1+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(_buff1+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;projet.c,146 :: 		for (i = 0; i < 7; ++i){
	CLRF        _i+0 
	CLRF        _i+1 
L_main12:
	MOVLW       128
	XORWF       _i+1, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main42
	MOVLW       7
	SUBWF       _i+0, 0 
L__main42:
	BTFSC       STATUS+0, 0 
	GOTO        L_main13
;projet.c,147 :: 		LATD = LATD << 1;
	MOVF        LATD+0, 0 
	MOVWF       R0 
	RLCF        R0, 1 
	BCF         R0, 0 
	MOVF        R0, 0 
	MOVWF       LATD+0 
;projet.c,148 :: 		Vdelay_ms(delayK2000);;
	MOVF        _delayK2000+0, 0 
	MOVWF       FARG_VDelay_ms_Time_ms+0 
	MOVF        _delayK2000+1, 0 
	MOVWF       FARG_VDelay_ms_Time_ms+1 
	CALL        _VDelay_ms+0, 0
;projet.c,146 :: 		for (i = 0; i < 7; ++i){
	INFSNZ      _i+0, 1 
	INCF        _i+1, 1 
;projet.c,149 :: 		}
	GOTO        L_main12
L_main13:
;projet.c,150 :: 		LATD = 0x80;
	MOVLW       128
	MOVWF       LATD+0 
;projet.c,151 :: 		for (i = 0; i < 7; ++i){
	CLRF        _i+0 
	CLRF        _i+1 
L_main15:
	MOVLW       128
	XORWF       _i+1, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main43
	MOVLW       7
	SUBWF       _i+0, 0 
L__main43:
	BTFSC       STATUS+0, 0 
	GOTO        L_main16
;projet.c,152 :: 		LATD = LATD >> 1;
	MOVF        LATD+0, 0 
	MOVWF       R0 
	RRCF        R0, 1 
	BCF         R0, 7 
	MOVF        R0, 0 
	MOVWF       LATD+0 
;projet.c,153 :: 		Vdelay_ms(delayK2000);
	MOVF        _delayK2000+0, 0 
	MOVWF       FARG_VDelay_ms_Time_ms+0 
	MOVF        _delayK2000+1, 0 
	MOVWF       FARG_VDelay_ms_Time_ms+1 
	CALL        _VDelay_ms+0, 0
;projet.c,151 :: 		for (i = 0; i < 7; ++i){
	INFSNZ      _i+0, 1 
	INCF        _i+1, 1 
;projet.c,154 :: 		}
	GOTO        L_main15
L_main16:
;projet.c,156 :: 		if (Button(&PORTC, 1, 1, 1)) {
	MOVLW       PORTC+0
	MOVWF       FARG_Button_port+0 
	MOVLW       hi_addr(PORTC+0)
	MOVWF       FARG_Button_port+1 
	MOVLW       1
	MOVWF       FARG_Button_pin+0 
	MOVLW       1
	MOVWF       FARG_Button_time_ms+0 
	MOVLW       1
	MOVWF       FARG_Button_active_state+0 
	CALL        _Button+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main18
;projet.c,157 :: 		flagRaz = 1;
	BSF         _flagRaz+0, BitPos(_flagRaz+0) 
;projet.c,158 :: 		}
L_main18:
;projet.c,159 :: 		if (flagRaz && Button(&PORTC, 1, 1, 0)) {
	BTFSS       _flagRaz+0, BitPos(_flagRaz+0) 
	GOTO        L_main21
	MOVLW       PORTC+0
	MOVWF       FARG_Button_port+0 
	MOVLW       hi_addr(PORTC+0)
	MOVWF       FARG_Button_port+1 
	MOVLW       1
	MOVWF       FARG_Button_pin+0 
	MOVLW       1
	MOVWF       FARG_Button_time_ms+0 
	CLRF        FARG_Button_active_state+0 
	CALL        _Button+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main21
L__main37:
;projet.c,160 :: 		nbBottle = 0;                       // reset count
	CLRF        _nbBottle+0 
	CLRF        _nbBottle+1 
;projet.c,161 :: 		flagRaz = 0;
	BCF         _flagRaz+0, BitPos(_flagRaz+0) 
;projet.c,162 :: 		}
L_main21:
;projet.c,165 :: 		infill = ADC_Read(0);
	CLRF        FARG_ADC_Read_channel+0 
	CALL        _ADC_Read+0, 0
	CALL        _word2double+0, 0
	MOVF        R0, 0 
	MOVWF       _infill+0 
	MOVF        R1, 0 
	MOVWF       _infill+1 
	MOVF        R2, 0 
	MOVWF       _infill+2 
	MOVF        R3, 0 
	MOVWF       _infill+3 
;projet.c,166 :: 		Bcd2Dec(infill);
	CALL        _double2byte+0, 0
	MOVF        R0, 0 
	MOVWF       FARG_Bcd2Dec_bcdnum+0 
	CALL        _Bcd2Dec+0, 0
;projet.c,167 :: 		if(infill > 1015){
	MOVF        _infill+0, 0 
	MOVWF       R4 
	MOVF        _infill+1, 0 
	MOVWF       R5 
	MOVF        _infill+2, 0 
	MOVWF       R6 
	MOVF        _infill+3, 0 
	MOVWF       R7 
	MOVLW       0
	MOVWF       R0 
	MOVLW       192
	MOVWF       R1 
	MOVLW       125
	MOVWF       R2 
	MOVLW       136
	MOVWF       R3 
	CALL        _Compare_Double+0, 0
	MOVLW       1
	BTFSC       STATUS+0, 0 
	MOVLW       0
	MOVWF       R0 
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main22
;projet.c,168 :: 		sprintf(buff2,"Fill:%.0f %%|%04d ",(infill/1022.0)*100.0,nbBottle);
	MOVLW       _buff2+0
	MOVWF       FARG_sprintf_wh+0 
	MOVLW       hi_addr(_buff2+0)
	MOVWF       FARG_sprintf_wh+1 
	MOVLW       ?lstr_4_projet+0
	MOVWF       FARG_sprintf_f+0 
	MOVLW       hi_addr(?lstr_4_projet+0)
	MOVWF       FARG_sprintf_f+1 
	MOVLW       higher_addr(?lstr_4_projet+0)
	MOVWF       FARG_sprintf_f+2 
	MOVLW       0
	MOVWF       R4 
	MOVLW       128
	MOVWF       R5 
	MOVLW       127
	MOVWF       R6 
	MOVLW       136
	MOVWF       R7 
	MOVF        _infill+0, 0 
	MOVWF       R0 
	MOVF        _infill+1, 0 
	MOVWF       R1 
	MOVF        _infill+2, 0 
	MOVWF       R2 
	MOVF        _infill+3, 0 
	MOVWF       R3 
	CALL        _Div_32x32_FP+0, 0
	MOVLW       0
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	MOVLW       72
	MOVWF       R6 
	MOVLW       133
	MOVWF       R7 
	CALL        _Mul_32x32_FP+0, 0
	MOVF        R0, 0 
	MOVWF       FARG_sprintf_wh+5 
	MOVF        R1, 0 
	MOVWF       FARG_sprintf_wh+6 
	MOVF        R2, 0 
	MOVWF       FARG_sprintf_wh+7 
	MOVF        R3, 0 
	MOVWF       FARG_sprintf_wh+8 
	MOVF        _nbBottle+0, 0 
	MOVWF       FARG_sprintf_wh+9 
	MOVF        _nbBottle+1, 0 
	MOVWF       FARG_sprintf_wh+10 
	CALL        _sprintf+0, 0
;projet.c,169 :: 		}
	GOTO        L_main23
L_main22:
;projet.c,171 :: 		sprintf(buff2,"Fill:%.1f%%|%04d  ",(infill/1022.0)*100.0,nbBottle);
	MOVLW       _buff2+0
	MOVWF       FARG_sprintf_wh+0 
	MOVLW       hi_addr(_buff2+0)
	MOVWF       FARG_sprintf_wh+1 
	MOVLW       ?lstr_5_projet+0
	MOVWF       FARG_sprintf_f+0 
	MOVLW       hi_addr(?lstr_5_projet+0)
	MOVWF       FARG_sprintf_f+1 
	MOVLW       higher_addr(?lstr_5_projet+0)
	MOVWF       FARG_sprintf_f+2 
	MOVLW       0
	MOVWF       R4 
	MOVLW       128
	MOVWF       R5 
	MOVLW       127
	MOVWF       R6 
	MOVLW       136
	MOVWF       R7 
	MOVF        _infill+0, 0 
	MOVWF       R0 
	MOVF        _infill+1, 0 
	MOVWF       R1 
	MOVF        _infill+2, 0 
	MOVWF       R2 
	MOVF        _infill+3, 0 
	MOVWF       R3 
	CALL        _Div_32x32_FP+0, 0
	MOVLW       0
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	MOVLW       72
	MOVWF       R6 
	MOVLW       133
	MOVWF       R7 
	CALL        _Mul_32x32_FP+0, 0
	MOVF        R0, 0 
	MOVWF       FARG_sprintf_wh+5 
	MOVF        R1, 0 
	MOVWF       FARG_sprintf_wh+6 
	MOVF        R2, 0 
	MOVWF       FARG_sprintf_wh+7 
	MOVF        R3, 0 
	MOVWF       FARG_sprintf_wh+8 
	MOVF        _nbBottle+0, 0 
	MOVWF       FARG_sprintf_wh+9 
	MOVF        _nbBottle+1, 0 
	MOVWF       FARG_sprintf_wh+10 
	CALL        _sprintf+0, 0
;projet.c,172 :: 		}
L_main23:
;projet.c,173 :: 		Lcd_out(2,1,buff2);
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       _buff2+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(_buff2+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;projet.c,176 :: 		infillToTxt = (infill/1022.0)*100.0;           //getting info in shape for EZ sending & LabVIEW display
	MOVLW       0
	MOVWF       R4 
	MOVLW       128
	MOVWF       R5 
	MOVLW       127
	MOVWF       R6 
	MOVLW       136
	MOVWF       R7 
	MOVF        _infill+0, 0 
	MOVWF       R0 
	MOVF        _infill+1, 0 
	MOVWF       R1 
	MOVF        _infill+2, 0 
	MOVWF       R2 
	MOVF        _infill+3, 0 
	MOVWF       R3 
	CALL        _Div_32x32_FP+0, 0
	MOVLW       0
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	MOVLW       72
	MOVWF       R6 
	MOVLW       133
	MOVWF       R7 
	CALL        _Mul_32x32_FP+0, 0
	MOVF        R0, 0 
	MOVWF       _infillToTxt+0 
	MOVF        R1, 0 
	MOVWF       _infillToTxt+1 
	MOVF        R2, 0 
	MOVWF       _infillToTxt+2 
	MOVF        R3, 0 
	MOVWF       _infillToTxt+3 
;projet.c,177 :: 		FloatToStr_FixLen(infillToTxt, fillTxt, 7);
	MOVF        R0, 0 
	MOVWF       FARG_FloatToStr_FixLen_fnum+0 
	MOVF        R1, 0 
	MOVWF       FARG_FloatToStr_FixLen_fnum+1 
	MOVF        R2, 0 
	MOVWF       FARG_FloatToStr_FixLen_fnum+2 
	MOVF        R3, 0 
	MOVWF       FARG_FloatToStr_FixLen_fnum+3 
	MOVLW       _fillTxt+0
	MOVWF       FARG_FloatToStr_FixLen_str+0 
	MOVLW       hi_addr(_fillTxt+0)
	MOVWF       FARG_FloatToStr_FixLen_str+1 
	MOVLW       7
	MOVWF       FARG_FloatToStr_FixLen_len+0 
	CALL        _FloatToStr_FixLen+0, 0
;projet.c,178 :: 		FloatToStr_FixLen(speedConveyor, speedTxt, 7);
	MOVF        _speedConveyor+0, 0 
	MOVWF       FARG_FloatToStr_FixLen_fnum+0 
	MOVF        _speedConveyor+1, 0 
	MOVWF       FARG_FloatToStr_FixLen_fnum+1 
	MOVF        _speedConveyor+2, 0 
	MOVWF       FARG_FloatToStr_FixLen_fnum+2 
	MOVF        _speedConveyor+3, 0 
	MOVWF       FARG_FloatToStr_FixLen_fnum+3 
	MOVLW       _speedTxt+0
	MOVWF       FARG_FloatToStr_FixLen_str+0 
	MOVLW       hi_addr(_speedTxt+0)
	MOVWF       FARG_FloatToStr_FixLen_str+1 
	MOVLW       7
	MOVWF       FARG_FloatToStr_FixLen_len+0 
	CALL        _FloatToStr_FixLen+0, 0
;projet.c,180 :: 		sprintf(datasent,"#%s;%s;%04dLF",fillTxt,speedTxt,nbBottle);
	MOVLW       _datasent+0
	MOVWF       FARG_sprintf_wh+0 
	MOVLW       hi_addr(_datasent+0)
	MOVWF       FARG_sprintf_wh+1 
	MOVLW       ?lstr_6_projet+0
	MOVWF       FARG_sprintf_f+0 
	MOVLW       hi_addr(?lstr_6_projet+0)
	MOVWF       FARG_sprintf_f+1 
	MOVLW       higher_addr(?lstr_6_projet+0)
	MOVWF       FARG_sprintf_f+2 
	MOVLW       _fillTxt+0
	MOVWF       FARG_sprintf_wh+5 
	MOVLW       hi_addr(_fillTxt+0)
	MOVWF       FARG_sprintf_wh+6 
	MOVLW       _speedTxt+0
	MOVWF       FARG_sprintf_wh+7 
	MOVLW       hi_addr(_speedTxt+0)
	MOVWF       FARG_sprintf_wh+8 
	MOVF        _nbBottle+0, 0 
	MOVWF       FARG_sprintf_wh+9 
	MOVF        _nbBottle+1, 0 
	MOVWF       FARG_sprintf_wh+10 
	CALL        _sprintf+0, 0
;projet.c,183 :: 		if (flag_uart){
	BTFSS       _flag_uart+0, BitPos(_flag_uart+0) 
	GOTO        L_main24
;projet.c,185 :: 		if (strcmp(incomingByte,"#1;0000;0")==0){
	MOVLW       _incomingByte+0
	MOVWF       FARG_strcmp_s1+0 
	MOVLW       hi_addr(_incomingByte+0)
	MOVWF       FARG_strcmp_s1+1 
	MOVLW       ?lstr7_projet+0
	MOVWF       FARG_strcmp_s2+0 
	MOVLW       hi_addr(?lstr7_projet+0)
	MOVWF       FARG_strcmp_s2+1 
	CALL        _strcmp+0, 0
	MOVLW       0
	XORWF       R1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main44
	MOVLW       0
	XORWF       R0, 0 
L__main44:
	BTFSS       STATUS+0, 2 
	GOTO        L_main25
;projet.c,186 :: 		sprintf(datasent,"%s",incomingByte) ;
	MOVLW       _datasent+0
	MOVWF       FARG_sprintf_wh+0 
	MOVLW       hi_addr(_datasent+0)
	MOVWF       FARG_sprintf_wh+1 
	MOVLW       ?lstr_8_projet+0
	MOVWF       FARG_sprintf_f+0 
	MOVLW       hi_addr(?lstr_8_projet+0)
	MOVWF       FARG_sprintf_f+1 
	MOVLW       higher_addr(?lstr_8_projet+0)
	MOVWF       FARG_sprintf_f+2 
	MOVLW       _incomingByte+0
	MOVWF       FARG_sprintf_wh+5 
	MOVLW       hi_addr(_incomingByte+0)
	MOVWF       FARG_sprintf_wh+6 
	CALL        _sprintf+0, 0
;projet.c,187 :: 		work = 0;
	BCF         _work+0, BitPos(_work+0) 
;projet.c,188 :: 		}
L_main25:
;projet.c,189 :: 		if(strcmp(incomingByte,"#0;0000;1")==0){
	MOVLW       _incomingByte+0
	MOVWF       FARG_strcmp_s1+0 
	MOVLW       hi_addr(_incomingByte+0)
	MOVWF       FARG_strcmp_s1+1 
	MOVLW       ?lstr9_projet+0
	MOVWF       FARG_strcmp_s2+0 
	MOVLW       hi_addr(?lstr9_projet+0)
	MOVWF       FARG_strcmp_s2+1 
	CALL        _strcmp+0, 0
	MOVLW       0
	XORWF       R1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main45
	MOVLW       0
	XORWF       R0, 0 
L__main45:
	BTFSS       STATUS+0, 2 
	GOTO        L_main26
;projet.c,190 :: 		sprintf(datasent,"%s",incomingByte) ;
	MOVLW       _datasent+0
	MOVWF       FARG_sprintf_wh+0 
	MOVLW       hi_addr(_datasent+0)
	MOVWF       FARG_sprintf_wh+1 
	MOVLW       ?lstr_10_projet+0
	MOVWF       FARG_sprintf_f+0 
	MOVLW       hi_addr(?lstr_10_projet+0)
	MOVWF       FARG_sprintf_f+1 
	MOVLW       higher_addr(?lstr_10_projet+0)
	MOVWF       FARG_sprintf_f+2 
	MOVLW       _incomingByte+0
	MOVWF       FARG_sprintf_wh+5 
	MOVLW       hi_addr(_incomingByte+0)
	MOVWF       FARG_sprintf_wh+6 
	CALL        _sprintf+0, 0
;projet.c,193 :: 		}
L_main26:
;projet.c,195 :: 		memset(incomingByte, '0', 3);          //replace 3 first carac by '000'
	MOVLW       _incomingByte+0
	MOVWF       FARG_memset_p1+0 
	MOVLW       hi_addr(_incomingByte+0)
	MOVWF       FARG_memset_p1+1 
	MOVLW       48
	MOVWF       FARG_memset_character+0 
	MOVLW       3
	MOVWF       FARG_memset_n+0 
	MOVLW       0
	MOVWF       FARG_memset_n+1 
	CALL        _memset+0, 0
;projet.c,196 :: 		for (i = 0; i <7;i++){
	CLRF        _i+0 
	CLRF        _i+1 
L_main27:
	MOVLW       128
	XORWF       _i+1, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main46
	MOVLW       7
	SUBWF       _i+0, 0 
L__main46:
	BTFSC       STATUS+0, 0 
	GOTO        L_main28
;projet.c,197 :: 		newAdress[i] = incomingByte[i];
	MOVLW       _newAdress+0
	ADDWF       _i+0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_newAdress+0)
	ADDWFC      _i+1, 0 
	MOVWF       FSR1H 
	MOVLW       _incomingByte+0
	ADDWF       _i+0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_incomingByte+0)
	ADDWFC      _i+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;projet.c,196 :: 		for (i = 0; i <7;i++){
	INFSNZ      _i+0, 1 
	INCF        _i+1, 1 
;projet.c,198 :: 		}
	GOTO        L_main27
L_main28:
;projet.c,199 :: 		adress = atoi(newAdress);             //adress is int of incomingByte
	MOVLW       _newAdress+0
	MOVWF       FARG_atoi_s+0 
	MOVLW       hi_addr(_newAdress+0)
	MOVWF       FARG_atoi_s+1 
	CALL        _atoi+0, 0
	MOVF        R0, 0 
	MOVWF       _adress+0 
	MOVF        R1, 0 
	MOVWF       _adress+1 
;projet.c,200 :: 		if (adress != 0){
	MOVLW       0
	XORWF       R1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main47
	MOVLW       0
	XORWF       R0, 0 
L__main47:
	BTFSC       STATUS+0, 2 
	GOTO        L_main30
;projet.c,202 :: 		}
L_main30:
;projet.c,203 :: 		flag_uart = 0;
	BCF         _flag_uart+0, BitPos(_flag_uart+0) 
;projet.c,204 :: 		}
L_main24:
;projet.c,205 :: 		UART1_Write_Text(datasent);
	MOVLW       _datasent+0
	MOVWF       FARG_UART1_Write_Text_uart_text+0 
	MOVLW       hi_addr(_datasent+0)
	MOVWF       FARG_UART1_Write_Text_uart_text+1 
	CALL        _UART1_Write_Text+0, 0
;projet.c,208 :: 		if (Button(&PORTC, 1, 1, 1)) {
	MOVLW       PORTC+0
	MOVWF       FARG_Button_port+0 
	MOVLW       hi_addr(PORTC+0)
	MOVWF       FARG_Button_port+1 
	MOVLW       1
	MOVWF       FARG_Button_pin+0 
	MOVLW       1
	MOVWF       FARG_Button_time_ms+0 
	MOVLW       1
	MOVWF       FARG_Button_active_state+0 
	CALL        _Button+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main31
;projet.c,209 :: 		flagRaz = 1;
	BSF         _flagRaz+0, BitPos(_flagRaz+0) 
;projet.c,210 :: 		}
L_main31:
;projet.c,211 :: 		if (flagRaz && Button(&PORTC, 1, 1, 0)) {
	BTFSS       _flagRaz+0, BitPos(_flagRaz+0) 
	GOTO        L_main34
	MOVLW       PORTC+0
	MOVWF       FARG_Button_port+0 
	MOVLW       hi_addr(PORTC+0)
	MOVWF       FARG_Button_port+1 
	MOVLW       1
	MOVWF       FARG_Button_pin+0 
	MOVLW       1
	MOVWF       FARG_Button_time_ms+0 
	CLRF        FARG_Button_active_state+0 
	CALL        _Button+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main34
L__main36:
;projet.c,212 :: 		nbBottle = 0;                       // reset count
	CLRF        _nbBottle+0 
	CLRF        _nbBottle+1 
;projet.c,213 :: 		flagRaz = 0;
	BCF         _flagRaz+0, BitPos(_flagRaz+0) 
;projet.c,214 :: 		}
L_main34:
;projet.c,218 :: 		if(count == 2){
	MOVLW       0
	XORWF       _count+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main48
	MOVLW       2
	XORWF       _count+0, 0 
L__main48:
	BTFSS       STATUS+0, 2 
	GOTO        L_main35
;projet.c,219 :: 		count = 0;
	CLRF        _count+0 
	CLRF        _count+1 
;projet.c,220 :: 		Lcd_out(2,1,buff2);
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       _buff2+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(_buff2+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;projet.c,221 :: 		Lcd_Out(1,1,buff1);
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       _buff1+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(_buff1+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;projet.c,222 :: 		}
L_main35:
;projet.c,224 :: 		}
L_main7:
;projet.c,225 :: 		}
	GOTO        L_main5
;projet.c,226 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
