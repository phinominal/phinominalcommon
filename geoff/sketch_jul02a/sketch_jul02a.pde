#include <AFMotor.h>

#include <Servo.h> 


Servo frontServo;  // create servo object to control a servo 
//Servo backServo;


int frontPos = 105;    // variable to store the servo position 
//int backPos = 0;
int motorPin = 9;    // LED connected to digital pin 9
//int incomingByte = 0;

int waitTime = 800;

void setup() 
{ 
  frontServo.attach(10);  // attaches the servo on pin 9 to the servo object 
  //backServo.attach(11);
  
  //Serial.begin(9600);
} 

void loop() 
{ 
  
 
  /*frontServo.write(frontPos);
  delay(waitTime);
  
  Serial.print("frontPos: ");
  Serial.println(frontPos);
  
  if (Serial.available() > 0) 
  {
		// read the incoming byte:
    incomingByte = Serial.read();
    frontPos = incomingByte;

		// say what you got:
    Serial.print("incomingByte: ");
    Serial.println(incomingByte);
  }*/

  frontServo.write(105);
  for(int thrustValue = 127 ; thrustValue >= 19; thrustValue -=5) 
  { 
    // sets the value (range from 0 to 255):
    analogWrite(motorPin, thrustValue);         
    // wait for 30 milliseconds to see the dimming effect    
    delay(300);                            
  }
  for(int thrustValue = 190 ; thrustValue >= 127; thrustValue -=5) 
  { 
    // sets the value (range from 0 to 255):
    analogWrite(motorPin, thrustValue);         
    // wait for 30 milliseconds to see the dimming effect    
    delay(30);                            
  }
  delay(waitTime);
  frontServo.write(120);
  delay(waitTime);
  frontServo.write(150);
  delay(waitTime);
  
  
  
  
  /*for(int fadeValue = 128 ; fadeValue <= 190; fadeValue +=5) { 
    // sets the value (range from 0 to 255):
    analogWrite(ledPin, fadeValue);         
    // wait for 30 milliseconds to see the dimming effect    
    delay(30);                            
  } */
  
  /*for(int frontPos = 0; frontPos < 180; frontPos += 10)  // goes from 0 degrees to 180 degrees 
  {                                  // in steps of 1 degree 
    frontServo.write(frontPos);              // tell servo to go to position in variable 'pos' 
    delay(15);                       // waits 15ms for the servo to reach the position 
  } */
  
  /*for(int frontPos = 110; frontPos >= 90; frontPos-=1)     // goes from 180 degrees to 0 degrees 
  {                                
    frontServo.write(frontPos);              // tell servo to go to position in variable 'pos' 
    delay(15);                       // waits 15ms for the servo to reach the position 
  } */

  // fade out from max to min in increments of 5 points:
 /* for(int fadeValue = 190 ; fadeValue >= 127; fadeValue -=5) { 
    // sets the value (range from 0 to 255):
    analogWrite(ledPin, fadeValue);         
    // wait for 30 milliseconds to see the dimming effect    
    delay(30);                            
  }*/
  
  
} 

