int RED = 9;    // RED pin of the LED to PWM pin 9
int GREEN = 6;  // GREEN pin of the LED to PWM pin 6
int BLUE = 3;   // BLUE pin of the LED to PWM pin 3

int STEPSIZE = 1;
int BRIGHTNESS = 200;
int DELAY = 1;
int BREAK = 99;


void setup()
{
  // nothing for setup 
}

void loop()
{
  
  
  
  //------------------------------------------------------------------
  for(int r = 0; r < BRIGHTNESS; r+=STEPSIZE) // Teal fades to Green 1
  {   
    analogWrite(BLUE, (BRIGHTNESS-r));  
    analogWrite(GREEN, BRIGHTNESS);
    delay(DELAY); 
  } 
  delay(BREAK);
  
  
  
  //------------------------------------------------------------------
  for(int r = 0; r < BRIGHTNESS; r+=STEPSIZE) //Green fades to Yellow 2
  { 
    analogWrite(GREEN, BRIGHTNESS);
    analogWrite(RED, r);
    delay(DELAY); 
  }
  delay(BREAK);
  
  
  for(int r = 0; r < BRIGHTNESS; r+=STEPSIZE) //Yellow fades to Red 3
  {
    analogWrite(GREEN, (BRIGHTNESS-r));  
    analogWrite(RED, BRIGHTNESS);
    delay(DELAY); 
  } 
  delay(BREAK);
  
  
  
  //------------------------------------------------------------------
  for(int r = 0; r < BRIGHTNESS; r+=STEPSIZE) //Red fades to Purple 4
  {    
    analogWrite(RED, BRIGHTNESS);   
    analogWrite(BLUE, r);
    delay(DELAY); 
  }
  delay(BREAK); 
  
  
  //------------------------------------------------------------------
  for(int r = 0; r < BRIGHTNESS; r+=STEPSIZE) //Purple fades to blue 5
  {    
    analogWrite(RED, (BRIGHTNESS-r));   
    analogWrite(BLUE, BRIGHTNESS);
    delay(DELAY); 
  }
  delay(BREAK);
  
  
  //------------------------------------------------------------------
  for(int r = 0; r < BRIGHTNESS; r+=STEPSIZE) //Blue fades to Teal 6
  {    
    analogWrite(BLUE, BRIGHTNESS);   
    analogWrite(GREEN, r);
    delay(DELAY); 
  }
  delay(BREAK);
  
  
  
  
}
