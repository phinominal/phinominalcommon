int RED = 9;    // RED pin of the LED to PWM pin 9
int GREEN = 6;  // GREEN pin of the LED to PWM pin 6
int BLUE = 3;   // BLUE pin of the LED to PWM pin 3

int STEPSIZE = 1;
int BRIGHTNESS = 200;
int DELAY = 2000;



void setup()
{
  Serial.begin(9600);
   
}

void loop()
{ 
  int incomingByte = 0;
  Serial.print("Enter brightness. ");
  
  if (Serial.available() > 0) // read the incoming byte:
  {	
    incomingByte = Serial.read();	
    Serial.print("incomingByte: ");  // say what you got:
    Serial.println(incomingByte);
  }
  analogWrite(BLUE, incomingByte);
  delay(DELAY);
 
}
