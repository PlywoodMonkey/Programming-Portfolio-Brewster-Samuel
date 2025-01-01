/* 
* File:                         landNavPatrolCap.ino
* Author:                       Samuel Brewster, University of Georgia
* Code used in conjuction with: convertLatLong.ino, tempSensor.ino
*
* Used in Dr. Trudgen's ELEE 4230: Sensor's and Transducer's Class.
* Used in Final Project: Land Nav Patrol Cap
* 
*/

#include <LiquidCrystal_I2C.h>
#include <Wire.h> //Needed for I2C to GNSS
#include <SparkFun_u-blox_GNSS_Arduino_Library.h> //http://librarymanager/All#SparkFun_u-blox_GNSS

SFE_UBLOX_GNSS myGNSS;

long lastTime = 0; //Simple local timer. Limits amount if I2C traffic to u-blox module.

LiquidCrystal_I2C lcd(0x27, 20, 4);  // set the LCD address to 0x27 for a 16 chars and 2 line display

void setup() {
  // put your setup code here, to run once:

  // Initialize Target Grid
  String tarGrid;
  tarGrid = "80400 57910 ";

  // Setup pin for Temperature Input
  pinMode(9, INPUT);

  lcd.init();           // initialize the LCD 
  lcd.display();        
  lcd.backlight();      // Setup Backlight for the LCD Screen
  
  // Welcome the User with a friendly Greeting
  lcd.setCursor(0,0);
  lcd.clear();
  lcd.print("    Welcome User!  ");
  lcd.setCursor(0,1);
  lcd.printstr(" You're looking for:");
  lcd.setCursor(0,2);
  lcd.printstr(" 17 S KT ");
  lcd.print(tarGrid);
  lcd.setCursor(0,3);
  lcd.printstr(" Be All You Can Be! ");

  // Allow the user to read the message
  delay(10000);  

  Serial.begin(9600);
  while (!Serial); //Wait for user to open terminal
  Serial.println("SparkFun u-blox Example");

  Wire.begin();

  // Begin the GPS Sensor
  if (myGNSS.begin(Wire, 0x42) == false) //Connect to the u-blox module using Wire port
  {
    Serial.println(F("u-blox GNSS not detected at default I2C address. Please check wiring. Freezing."));
    while (1);
  }

  myGNSS.setI2COutput(COM_TYPE_UBX); //Set the I2C port to output UBX only (turn off NMEA noise)
 
  myGNSS.saveConfigSelective(VAL_CFG_SUBSEC_IOPORT); //Save (only) the communications port settings to flash and BBR
}

void loop()
{

  // Initialize Strings
  String gridLocation;
  String firstTerm;
  String secondTerm;
  String tarGrid;
  String status;

  // Set the Target Grid
  tarGrid = "80400 57910";

  //The module only responds when a new position is available, prevents I2C traffic
  if (millis() - lastTime > 1000)
  {
    lastTime = millis(); //Update the timer
    
    // Get latitude
    double latitude = myGNSS.getLatitude();
    latitude = latitude/10000000;
    
    // Get longitude
    double longitude = myGNSS.getLongitude();
    longitude = longitude/10000000;
    
    // Get altitude
    float altitude = myGNSS.getAltitude();
    altitude = altitude / 1000;

    byte SIV = myGNSS.getSIV();
        
    // Call the lat long converter
    gridLocation = LLtoUTM(latitude, longitude);

    // Parse the First 5 Digits
    for (int i = 10; i < 15; i++) {

      firstTerm += gridLocation.charAt(i);

    }

    // Parse the Second 5 Digits
    for (int i = 21; i < 26; i++) {

      secondTerm += gridLocation.charAt(i);

    }

    // Sanity Check
    Serial.println(firstTerm);
    Serial.println(secondTerm);
    
    // Output to LCD
    lcd.clear();
    lcd.print("CG: KT ");
    lcd.print(firstTerm);
    lcd.print(" ");
    lcd.print(secondTerm);

    lcd.setCursor(0,1);
    lcd.print("TG: KT ");
    lcd.print(tarGrid);

    lcd.setCursor(0,2);
    lcd.print("Alt: ");
    lcd.print(altitude);
    lcd.print(" meters");

    status = findTemp();
    lcd.setCursor(0,3);
    lcd.print(status);

    delay(100);
  }
}
