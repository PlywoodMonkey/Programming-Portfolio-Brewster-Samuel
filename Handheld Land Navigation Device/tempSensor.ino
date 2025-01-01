/*   
* File:                         tempSensor.ino
* Author:                       Samuel Brewster, University of Georgia
* Code used in conjuction with: convertLatLong.ino, landNavPatrolCap.ino
*
* Used in Dr. Trudgen's ELEE 4230: Sensor's and Transducer's Class.
* Used in Final Project: Land Nav Patrol Cap
* 
*/

#include <Arduino.h>

String findTemp() {
  // put your main code here, to run repeatedly:
  float inputVoltage = analogRead(4);
  float voltageUnamped;
  float voltage;
  float tempChange;
  float temperature;
  //float inputResistance = analogRead(3);

  //inputResistance = inputResistance * 1.25;

  voltageUnamped = inputVoltage; // 977
  voltage = voltageUnamped * 3.3 / 4096;
  temperature = (voltage * 56.3); 

  //temperature = 23 + tempChange;

  Serial.print("Voltage: ");
  Serial.print(voltageUnamped);

  Serial.print("     Temperature: ");
  Serial.print(temperature);

  unsigned long CHANNEL_ID = XXXXXXX;

  if (voltageUnamped > 520) {
    temperature = 93;
    // ThingSpeak.writeField(CHANNEL_ID, 1, temperature, "");
    return ("Temp: You are Hot!");
  } 
  else if (voltageUnamped < 490) {
    temperature = 105;
    // ThingSpeak.writeField(CHANNEL_ID, 1, temperature, "");
    return ("Temp: You are Cold!");
  } 
  else {
    temperature = 98.5;
    // ThingSpeak.writeField(CHANNEL_ID, 1, temperature, "");
    return "Temp: You are A-Okay";
  }

  //delay(1000);
  
}
