#line 1 "D:/OneDrive - EPHEC asbl/bac2/q2/systemeEmbarque/Projet/github_arth/projet.c"

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


bit flag;
bit endSwitch;
float speedConveyor = 0;
float infill = 0;
int delayK2000 = 0;
int i = 0;
int nbBottle = 0;
int count;
char buff1[17];
char buff2[16];
bit flagRaz;
bit work;


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


int EepromAdress;
char addToEeprom;


void interrupt(){

 if(RBIF_bit) {
 if(PORTB.B6 == 1){
 flag = 1;
 }
 if(PORTB.B7 == 1){
 endSwitch = 1;
 }
 RBIF_bit = 0;
 }

 if (TMR0IF_bit){
 TMR0IF_bit = 0;
 TMR0H = 0xD8;
 TMR0L = 0xF0;
 count ++;
 }

 if(RC1IF_bit)
 {
 flag_uart = 1;
 UART1_Read_Text(incomingByte,"LF",11);
 RC1IF_bit = 0;
 }
}



void writeE2prom(int adress, char dataValue){
 I2C1_Start();
 I2C1_Wr(0xA2);
 I2C1_Wr(adress);
 I2C1_Wr(dataValue);
 I2C1_Stop();
}


void main() {
 ANSELA = 3;
 ANSELB = 0;
 ANSELC = 0;
 ANSELD = 0;

 TRISA = 3;
 TRISB = 0b11000000;
 TRISD = 0;
 TRISE.RE0 = 1;


 RBIE_bit = 1;
 IOCB6_bit = 1;
 IOCB7_bit = 1;
 TMR0IE_bit = 1;
 T0CON = 0x88;
 TMR0H = 0xD8;
 TMR0L = 0xF0;
 GIE_bit = 1;

 Sound_Init(&PORTE, 1);
 Lcd_Init();
 Lcd_Cmd(_LCD_CURSOR_OFF);
 I2C1_Init(100000);

UART1_Init(9600);
RC1IE_bit = 1;
RC1IF_bit = 0;
PEIE_bit = 1;


 endSwitch = 0;
 flag = 0;
 flagRaz = 0;
 C1ON_bit = 0;
 C2ON_bit = 0;
 work = 1;

 while(1) {

 if (work == 1){

 if(flag){
 flag = 0;
 LATD = 0;
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Out(1,1,"  EMERGENCY ON");
 while(PORTB.B6 == 1){
 LATD = ~LATD;
 delay_ms(500);
 Sound_Play(2000, 1000);
 }
 }


 speedConveyor = ADC_read(1);
 Bcd2Dec(speedConveyor);
 delayK2000 = (-0.1*(speedConveyor-100)) + 200;
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

 if (Button(&PORTC, 1, 1, 1)) {
 flagRaz = 1;
 }
 if (flagRaz && Button(&PORTC, 1, 1, 0)) {
 nbBottle = 0;
 flagRaz = 0;
 }


 infill = ADC_Read(0);
 Bcd2Dec(infill);
 if(infill > 1015){
 sprintf(buff2,"Fill:%.0f %%|%04d ",(infill/1022.0)*100.0,nbBottle);
 }
 else{
 sprintf(buff2,"Fill:%.1f%%|%04d  ",(infill/1022.0)*100.0,nbBottle);
 }
 Lcd_out(2,1,buff2);


 infillToTxt = (infill/1022.0)*100.0;
 FloatToStr_FixLen(infillToTxt, fillTxt, 7);
 FloatToStr_FixLen(speedConveyor, speedTxt, 7);

 sprintf(datasent,"#%s;%s;%04dLF",fillTxt,speedTxt,nbBottle);


 if (flag_uart){

 if (strcmp(incomingByte,"#1;0000;0")==0){
 sprintf(datasent,"%s",incomingByte) ;
 work = 0;
 }
 if(strcmp(incomingByte,"#0;0000;1")==0){
 sprintf(datasent,"%s",incomingByte) ;


 }

 memset(incomingByte, '0', 3);
 for (i = 0; i <7;i++){
 newAdress[i] = incomingByte[i];
 }
 adress = atoi(newAdress);
 if (adress != 0){

 EepromAdress += 1;
 }
 sprintf(addToEeprom,"(%s;%s;%s",Adress);
 writeE2prom(EepromAdress, addToEeprom);
 flag_uart = 0;
 }
 UART1_Write_Text(datasent);
 if(endSwitch == 1){
 endSwitch = 0;
 for(i = 1000; i<5000; i += 1000){
 Sound_Play(i, 1000);
 }
 nbBottle++;
 }

 if(count == 2){
 count = 0;
 Lcd_out(2,1,buff2);
 Lcd_Out(1,1,buff1);
 }

 }
 }
 }
