int sensorPin = 0;    // select the input pin for the potentiometer
int sensorValue = 0;  // variable to store the value coming from the sensor

int redPin = 9;    // RED pin of the LED to PWM pin 9 
int greenPin = 6;  // GREEN pin of the LED to PWM pin 6
int bluePin = 3;   // BLUE pin of the LED to PWM pin 3


void setup() 
{  
  pinMode(bluePin, OUTPUT);  // declare the LED pins as an OUTPUT:
}

void loop() 
{
  
  sensorValue = analogRead(sensorPin);    // read the value from the sensor:
  
  digitalWrite(bluePin, HIGH);  // turn the ledPin on
  
  delay(sensorValue*8);          // stop the program for <sensorValue> milliseconds:
     
  digitalWrite(bluePin, LOW);   // turn the ledPin off:     
  
  delay(sensorValue*8);           // stop the program for for <sensorValue> milliseconds:
}
