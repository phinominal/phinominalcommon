#include <AFMotor.h>
#include <Servo.h> 

Servo frontServo;  // create servo object to control a servo 

int servoPin = 9;    // motor connected to digital pin 9

int DELAY = 1600;

//int position = 8;

int increment = 20;

int rotations = 200;



void setup() 
{ 
  frontServo.attach(servoPin);  // attaches the servo on pin 9 to the servo object 
} 

void loop() 
{ 
  
  for(int i = 0; i <= rotations; i+=increment)
  {
    frontServo.write(i);
    delay(DELAY);
  }
  
  
} 
