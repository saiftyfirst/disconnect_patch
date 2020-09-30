int sensorPin = A0;
int pwmPin = 2;
int digitalValue = 0;
float voltage = 0;

void setup() {
  Serial.begin(9600);
}

void loop() {
  digitalValue = analogRead(sensorPin);
  voltage = digitalValue * (5 / 1023.0);
  Serial.println(voltage);     
  delay(200);
}
