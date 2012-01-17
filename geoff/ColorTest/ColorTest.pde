int redPin = 9;    // RED pin of the LED to PWM pin 9 
int greenPin = 6;  // GREEN pin of the LED to PWM pin 6
int bluePin = 3;   // BLUE pin of the LED to PWM pin 3

int STEPSIZE = 5;
int BRIGHTNESS = 200;
int DELAY = 30;
int red[] = {256,0,0};
int green[] = {0,256,0};
int blue[] = {0,0,256};
int yellow[] = {256,256,0};
int teal[] = {0,256,256};
int purple[] = {256,0,256};


void exhibitColor(int rgbMix[])
{
  for(i = 0; i < 3; i++)
  {
    analogWrite(


void setup()
{
  // nothing for setup 
}

void loop()
{ 
  
    analogWrite(redPin, 238); 
    analogWrite(greenPin, 130);  
    analogWrite(bluePin, 238);
    delay(DELAY); 
 
}


