#include <AFMotor.h>
#include <Servo.h>

Servo frontServo;  // create servo object to control a servo 

//int motorPin = 11;    // motor connected to digital pin 9
int servoPin = 10;

//int stopSpeed = 127;
//int maxSpeed = 145;

//int turnTime = 2000;
int straightTime = 300;

//int leftTurn = 75;
//int rightTurn = 135;
int straight = 105;

void setup() 
{ 
  frontServo.attach(servoPin);  // attaches the servo on pin 9 to the servo object 
} 

void loop() 
{
  frontServo.write(straight);
  delay(straightTime); 
  
  /*for(int thrustValue = stopSpeed ; thrustValue >= maxSpeed; thrustValue +=5) 
  { 
    // sets the value (range from 0 to 255):
    analogWrite(motorPin, thrustValue);                                    
  }
  
  frontServo.write(straight);
  delay(straightTime);
  frontServo.write(leftTurn);
  delay(turnTime);
  frontServo.write(straight);
  delay(straightTime);
  frontServo.write(rightTurn);
  delay(turnTime);
  
  for(int thrustValue = maxSpeed; thrustValue >= stopSpeed; thrustValue -=5) 
  { 
    analogWrite(motorPin, thrustValue);                                  
  }*/
  
  
} 


