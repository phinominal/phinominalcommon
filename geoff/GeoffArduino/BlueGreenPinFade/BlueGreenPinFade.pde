int redPin = 9;    // RED pin of the LED to PWM pin 9 
int greenPin = 6;  // GREEN pin of the LED to PWM pin 6
int bluePin = 3;   // BLUE pin of the LED to PWM pin 3

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
    analogWrite(bluePin, (BRIGHTNESS-r));  // Blue fades to Green
    analogWrite(greenPin, r);  
    delay(DELAY); 
  }
  for(int r = 0; r < BRIGHTNESS; r+=STEPSIZE) 
  {
    
    analogWrite(greenPin, (BRIGHTNESS-r));  // Green fades to Blue
    analogWrite(bluePin, r);
    delay(DELAY); 
  }
}


