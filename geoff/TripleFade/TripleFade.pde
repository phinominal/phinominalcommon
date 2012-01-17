int RED = 9;    // RED pin of the LED to PWM pin 37 
int GREEN = 6;  // GREEN pin of the LED to PWM pin 36
int BLUE = 3;   // BLUE pin of the LED to PWM pin 35

int STEPSIZE = 5;
int BRIGHTNESS = 200;
int DELAY = 30;


void setup()
{
  // nothing for setup 
}

void loop()
{
   
  for(int r = 0; r < BRIGHTNESS; r+=STEPSIZE) 
  {   
    analogWrite(BLUE, (BRIGHTNESS-r));  // Blue fades to Green
    analogWrite(GREEN, r);
    delay(DELAY); 
  } 
  for(int r = 0; r < BRIGHTNESS; r+=STEPSIZE) 
  {    
    analogWrite(GREEN, (BRIGHTNESS-r));   // Green fades to Red
    analogWrite(RED, r);
    delay(DELAY); 
  }
  for(int r = 0; r < BRIGHTNESS; r+=STEPSIZE) 
  {
    analogWrite(RED, (BRIGHTNESS-r));  // Red fades to Blue
    analogWrite(BLUE, r);
    delay(DELAY); 
  } 
  
  
}


