// Variables pour LCD
sbit LCD_RS at RB4_bit;
sbit LCD_EN at RB5_bit;
sbit LCD_D4 at RB0_bit;
sbit LCD_D5 at RB1_bit;
sbit LCD_D6 at RB2_bit;
sbit LCD_D7 at RB3_bit;
sbit LCD_RS_Direction at TRISB4_bit;
sbit LCD_EN_Direction at TRISB5_bit;
sbit LCD_D4_Direction at TRISB0_bit;
sbit LCD_D5_Direction at TRISB1_bit;
sbit LCD_D6_Direction at TRISB2_bit;
sbit LCD_D7_Direction at TRISB3_bit;

// Variables globales
bit flag;                 // Flag interuption externe
bit endSwitch;
float speedConveyor = 0;
float infill = 0;
int delayK2000 = 0;
int i = 0;
int nbBottle = 0;
int count;
char buff1[17];  // 17 car "\0" invisible
char buff2[16];
bit flagRaz;
bit work;

     //variables UART_RX
char incomingByte[12];
int adress = 0;
char datasent[24];
char eeprom_out;
char fillTxt [15];
float infillToTxt;
char speedTxt[15];
char newAdress[8];
int indexStop;
bit flag_uart;

//variables Eeprom
int whereInEeprom = 0;


     //variable eeprom
int EepromAdress;
char addToEeprom [;

// Interruption
void interrupt(){              // Interrupt routine
  //interruption externe (RB6)
  if(RBIF_bit) {         // Checks for Extern Interrupt Flag bit
    if(PORTB.B6 == 1){   // Arrêt urgence (RB6)
      flag = 1;
    }
    if(PORTB.B7 == 1){  // Ajout compteur FDC (RB7)
      nbBottle ++;
    }
    RBIF_bit = 0;              // Clear Interrupt Flag
  }
  //interruption timer
  if (TMR0IF_bit){ // Timer0 toutes les 5ms
    TMR0IF_bit = 0;
    TMR0H = 0xD8;
    TMR0L = 0xF0;
    count ++;
  }
  //interruption UART
  if(RC1IF_bit) // Checks for Receive Interrupt Flag bit
  {
    flag_uart = 1;
    UART1_Read_Text(incomingByte,"LF",11); // Storing read data
    RC1IF_bit = 0;
  }
}


// eeprom write function
void writeE2prom(int adress, char dataValue){
  I2C1_Start(); // issue I2C start signal
  I2C1_Wr(0xA2); // send byte via I2C (device address + W)
  I2C1_Wr(adress); // send b yte (address of EEPROM location)
  I2C1_Wr(dataValue); // send data (data to be written)
  I2C1_Stop(); // issue I2C stop signal
}


void main() {
 ANSELA = 3;                  // PORT A analog (00000011)
 ANSELB = 0;                  // Configure PORT B pins as digital
 ANSELC = 0;                  // Configure C pin as digital
 ANSELD = 0;                  // PORT D digital
  
 TRISA = 3;                   // PORTA input (00000011)
 TRISB  = 0b11000000;         // Set PORT B direction
 TRISD = 0;                   // Set PORT D output
 TRISE.RE0 = 1;               // Disable CCPx pin output by setting
                              // the associated TRIS bit

 RBIE_bit  = 1;               // Enable Port B Interrupt-On-Change
 IOCB6_bit = 1;               // Enable RB6 interrupt pin
 IOCB7_bit = 1;               // Enable RB7 interrupt pin
 TMR0IE_bit = 1;
 T0CON = 0x88;
 TMR0H = 0xD8;
 TMR0L = 0xF0;
 GIE_bit = 1;                 // Enable GLOBAL interrupts
 
 Sound_Init(&PORTE, 1);       // Init sound PORTE1
 Lcd_Init();                  // Init LCD
 Lcd_Cmd(_LCD_CURSOR_OFF);
 I2C1_Init(100000);           // initialize I2C communication

UART1_Init(9600);             //UART INIT
RC1IE_bit = 1; // turn ON interrupt on UART1 receive
RC1IF_bit = 0; // Clear interrupt flag
PEIE_bit = 1; // Enable peripheral interrupts


 endSwitch = 0;               // Flag for button
 flag = 0;                    // Flag for interruption
 flagRaz = 0;
 C1ON_bit = 0;                        //disable comparators
 C2ON_bit = 0;
 work = 1;
 
 while(1) {

   if (work == 1){
     // Action lors d'interruption externe
     if(flag){
       flag = 0;                    // Reset flag interruption
       LATD = 0;                    // Turn off leds on Port D
       Lcd_Cmd(_LCD_CLEAR);
       Lcd_Out(1,1,"  EMERGENCY ON");
       while(PORTB.B6 == 1){
         LATD = ~LATD;              // Toggle LEDs on PORTD
         delay_ms(500);
         Sound_Play(2000, 1000);    // Play sound f = 1000Hz for 1s
         }
       }

     // Gestion du K2000 avec ADC(RA1)
     speedConveyor = ADC_read(1);   // Get ADC value
     Bcd2Dec(speedConveyor);        // Convert ADC value to decimal
     delayK2000 = (-0.1*(speedConveyor-100)) + 200;   // Set delay of K2000
     sprintf(buff1,"V:%.3fm/s|Count",speedConveyor/1000);
     Lcd_Out(1,1,buff1);

     for (i = 0; i < 7; ++i){
       LATD = LATD << 1;
       Vdelay_ms(delayK2000);;
       }
     LATD = 0x80;
     for (i = 0; i < 7; ++i){
       LATD = LATD >> 1;
       Vdelay_ms(delayK2000);
       }
      //Bouton RAZ
     if (Button(&PORTC, 1, 1, 1)) {
       flagRaz = 1;
       }
     if (flagRaz && Button(&PORTC, 1, 1, 0)) {
       nbBottle = 0;                       // reset count
       flagRaz = 0;
       }

     // Gestion du remplissage des bouteilles (RA0)
     infill = ADC_Read(0);
     Bcd2Dec(infill);
     if(infill > 1015){
       sprintf(buff2,"Fill:%.0f %%|%04d ",(infill/1022.0)*100.0,nbBottle);
       }
     else{
       sprintf(buff2,"Fill:%.1f%%|%04d  ",(infill/1022.0)*100.0,nbBottle);
       }
     Lcd_out(2,1,buff2);
     
     //UART Sending
     infillToTxt = (infill/1022.0)*100.0;           //getting info in shape for EZ sending & LabVIEW display
     FloatToStr_FixLen(infillToTxt, fillTxt, 7);
     FloatToStr_FixLen(speedConveyor, speedTxt, 7);

     sprintf(datasent,"#%s;%s;%04dLF",fillTxt,speedTxt,nbBottle);

     //UartWork;
     if (flag_uart){
        //UART1_Write_Text(incomingByte);
        if (strcmp(incomingByte,"#1;0000;0")==0){
          sprintf(datasent,"%s",incomingByte) ;
          work = 0;
        }
        if(strcmp(incomingByte,"#0;0000;1")==0){
          sprintf(datasent,"%s",incomingByte) ;
          //hexDump();
          //UART1_Write_Text(eeprom_out);                                                           //NOT DONE WITH THIS SHIT
        }
        
        memset(incomingByte, '0', 3);          //replace 3 first carac by '000'
        for (i = 0; i <7;i++){
            newAdress[i] = incomingByte[i];
            }
        adress = atoi(newAdress);             //adress is int of incomingByte
        if (adress != 0){
           //sprintf(datasent,"%i",adress);
           whereInEeprom += 1;
        }
        sprintf(addToEeprom,"(%s;%s;%s",Adress);
        writeE2prom(whereInEeprom, addToEeprom);
        flag_uart = 0;
    }
    UART1_Write_Text(datasent);
     
     //Bouton RAZ
     if (Button(&PORTC, 1, 1, 1)) {
       flagRaz = 1;
       }
     if (flagRaz && Button(&PORTC, 1, 1, 0)) {
       nbBottle = 0;                       // reset count
       flagRaz = 0;
       }


     //update LCD after 10ms
     if(count == 2){
       count = 0;
       Lcd_out(2,1,buff2);
       Lcd_Out(1,1,buff1);
       }

     }
   }
 }