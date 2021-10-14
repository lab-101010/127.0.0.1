// ====================================== NOTES ======================================== 
// 
//  - PWM : Pulse Width Modulation (MLI:Modulation par Largeur d'Impulsion)
//  Controls Analog OUTPUT with digital command or means.
//  
//  frequency : constant => Period : Constant -> F = 1/T
//  width of the Period (DUTY CYCLE) => can be modulated w/ same frequency (from 0 to 100%)
//	-----------------------------------------------------------
//  Alpha (DUTY CYCLE) = TON/T = TON / (TON+TOFF) 
//	-----------------------------------------------------------
//  - TON : signal high
//  - TOFF : signal low
//	- T : Period (TON + TOFF)
//	-----------------------------------------------------------
//  - DUTY CYCLE => Proportional to the Output Means signal
//		if Voltage (Vin) : Vout = Vmean = Vin*Alpha = Vin* (TON / (TON+TOFF))
//	-----------------------------------------------------------
//  - Applications : 
// 		-> LED brightness control
// 		-> Motor Control (DC, Induction)
// 	
// =====================================================================================
// src: https://create.arduino.cc/projecthub/muhammad-aqib/arduino-pwm-tutorial-ae9d71
// =====================================================================================

//============================= LED brightness control =========================== //

//Initializing LED Pin
int led_pin = 6;

void setup() 
{
  //Declaring LED pin as output
  pinMode(led_pin, OUTPUT);
}

void loop() {
  //Fading the LED
  for(int i=0; i<255; i++){
    analogWrite(led_pin, i);
    delay(5);
  }
  for(int i=255; i>0; i--){
    analogWrite(led_pin, i);
    delay(5);
  }
}


// ============================  End of file ==================== //

