int RED = 9;    // RED pin of the LED to PWM pin 9 
int GREEN = 6;  // GREEN pin of the LED to PWM pin 6
int BLUE = 3;   // BLUE pin of the LED to PWM pin 3

int STEPSIZE = 1;
int BRIGHTNESS = 200;
int DELAY = 20;


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
    analogWrite(GREEN, r);  // Red fades to white
    analogWrite(BLUE, r);
    delay(DELAY); 
  } 
  for(int r = 0; r < BRIGHTNESS; r+=STEPSIZE) 
  {    
    analogWrite(GREEN, (BRIGHTNESS-r));   // White fades to Blue
    analogWrite(RED, (BRIGHTNESS-r));
    delay(DELAY); 
  }
  
}

