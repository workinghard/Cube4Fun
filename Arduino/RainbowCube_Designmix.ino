//
//  RainbowCube
//  Cube4Fun
//
//  Created by Nikolai Rinas on 27.03.15.
//  Copyright (c) 2015 Nikolai Rinas. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>

#include <Rainbowduino.h>
#include <Wire.h>

#define DEBUG

#ifdef DEBUG
  #define DEBUG_PRINTLN(x)  Serial.println (x)
  #define DEBUG_PRINT(x) Serial.print (x)
  #define DEBUG_PRINTLN_TXT(x)  Serial.println (F(x))
  #define DEBUG_PRINT_TXT(x) Serial.print (F(x))
#else
  #define DEBUG_PRINTLN(x)
  #define DEBUG_PRINT(x)
  #define DEBUG_PRINTLN_TXT(x)
  #define DEBUG_PRINT_TXT(x)
#endif 


// New balanced colors
static unsigned char RED[256] = {255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
                          255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,247,243,238,230,226,217,213,209,
                          200,196,188,183,179,171,166,158,154,145,141,137,128,124,115,111,107,98,94,85,81,77,68,64,56,51,47,39,34,
                          26,22,13,9,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,9,13,22,26,35,39,43,52,56,
                          64,68,77,81,85,94,98,107,111,115,124,128,136,141,145,153,158,166,171,179,183,188,196,200,209,213,217,226,
                          230,239,243,247,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
                          255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0};
static unsigned char GREEN[256] = {0,0,7,17,22,30,34,39,47,51,60,64,68,77,81,90,94,98,107,111,119,124,132,136,141,149,153,162,166,170,179,
                          183,192,196,200,209,213,221,226,230,238,243,251,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
                          255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
                          255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
                          255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,251,243,238,230,226,221,213,209,200,196,
                          192,183,179,170,166,158,154,149,141,136,128,124,120,111,107,98,94,90,81,77,68,64,56,52,47,39,34,26,22,18,9,
                          5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255,0};
static unsigned char BLUE[256] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,9,18,22,26,34,39,47,52,56,64,
                                  68,77,81,90,94,98,107,111,120,124,128,136,141,149,154,158,166,170,179,183,188,196,200,209,213,221,226,230,
                                  238,243,251,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
                                  255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
                                  255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
                                  255,255,255,255,255,255,255,255,251,243,239,234,226,221,213,209,200,196,192,183,179,171,166,162,153,149,141,
                                  136,132,124,120,111,107,103,94,90,81,77,68,64,60,52,47,39,35,30,22,17,255,0};

unsigned char plasmaMatrix[8][8];
unsigned char plasmaCube[4][4][4];
unsigned char buffer3D[4][4][4];
byte displayLength = 0;
char blinkColor = 'r';
boolean blinkSet = false;
boolean initAnim = true;
boolean newFrame = false;
unsigned char blinkCount = 0;
boolean streamMode = false;
long animation = 0;
unsigned long lastChangeTime = 0;
unsigned long streamStartedTime = 0;
const long animInterval = 300000; // 5 minutes
const long streamTimeoutInterval = 5000; // 5 seconds
#define BLINK_COUNT_MAX 7
const long blinkInterval = 1000;           // interval at which to blink (milliseconds)
unsigned long blinkPreviousMillis = 0;

unsigned char z,x,y,colorshift=0;
int receivePart;

// --------------- FUNCTIONS ---------------- //

void genPlasmaMatrix() {
  // Generate Plasma-Array
  for(x = 0; x < 8; x++) {
    for(y = 0; y < 8; y++) {
      int color = int(32.0 + (32.0 * sin(x / 4.0)) + 32.0 + (32.0 * sin(y / 4.0))) / 2;
      plasmaMatrix[x][y] = color;      
    }
  }
}

void genPlasmaMatrix2() {
  // Generate Plasma2-Array
  for(x = 0; x < 8; x++) {
    for(y = 0; y < 8; y++) {
      int color = int(32.0 + (32.0 * sin(x / 1.0)) + 32.0 + (32.0 * sin(y / 1.0))) / 2;
      plasmaMatrix[x][y] = color;      
    }
  }
}

void genPlasmaCube() {
  // Generate PlasmaCube-Array
  for(x = 0; x < 4; x++) {
    for(y = 0; y < 4; y++) {
      for(z = 0; z < 4; z++) {
        int color = int(32.0 + (32.0 * sin(x / 1.0))+ 32.0 + (32.0 * sin(y / 1.0)) + 32.0 + (32.0 * sin(z / 1.0))) / 3;
        plasmaCube[x][y][z] = color;      
      }   
    }
  }  
}

void genPlasmaCube2() {
  // Generate PlasmaCube2-Array
  for(x = 0; x < 4; x++) {
    for(y = 0; y < 4; y++) {
      for(z = 0; z < 4; z++) {
        int color = int(32.0 + (32.0 * sin(x / 4.0))+ 32.0 + (32.0 * sin(y / 4.0)) + 32.0 + (32.0 * sin(z / 4.0))) / 3;
        plasmaCube[x][y][z] = color;      
      }   
    }
  }
}

void genPlasmaCube3() {
  // Generate PlasmaCube3-Array
  for(x = 0; x < 4; x++) {
    for(y = 0; y < 4; y++) {
      for(z = 0; z < 4; z++) {
        int color = int(32.0 + (32.0 * sin(x / 8.0))+ 32.0 + (32.0 * sin(y / 8.0)) + 32.0 + (32.0 * sin(z / 8.0))) / 3;
        plasmaCube[x][y][z] = color;      
      }   
    }
  }
}

void setByteColor2D() {  
  unsigned char color255 = (plasmaMatrix[x][y] * 4 + colorshift ) % 256; // Transform to 8 Bit color
  if ( color255 > 0 ) {
    if ( color255 > 253 ) { // 254 and 255 are reserved
      color255 = 253;
    }
  }else{
    color255 = 0;
  } // Range 0 ... 253
  
  Rb.setPixelXY(x,y,RED[color255],GREEN[color255],BLUE[color255]);
}

void setByteColor3D() {  
  unsigned char color255 = (plasmaCube[x][y][z] * 4 + colorshift ) % 256; // Transform to 8 Bit color
  if ( color255 > 0 ) {
    if ( color255 > 253 ) { // 254 and 255 are reserved
      color255 = 253;
    }
  }else{
    color255 = 0;
  } // Range 0 ... 253
  
  Rb.setPixelZXY(z,x,y,RED[color255],GREEN[color255],BLUE[color255]);
}


void draw2D() {
  for(x=0;x<8;x++) {
    for(y=0;y<8;y++) {
      setByteColor2D();
    }
  }
}

void draw3D() {
  for(x=0;x<4;x++)  {
    for(y=0;y<4;y++)  {
      for(z=0;z<4;z++) {
        setByteColor3D();
      }
    }
  }
}


void drawMoodlamp() {
  for(z=0; z<254 ;z++) {
    for(x=0;x<8;x++) {
      for(y=0;y<8;y++) {
        //Paint random colors
        Rb.setPixelXY(x,y,RED[z],GREEN[z],BLUE[z]); //uses R, G and B color bytes
      }
    }
    delay(100);
  }
  for(z=253; z > 0 ;z--) {
    for(x=0;x<8;x++) {
      for(y=0;y<8;y++) {
        //Paint random colors
        Rb.setPixelXY(x,y,RED[z],GREEN[z],BLUE[z]); //uses R, G and B color bytes
      }
    }
    delay(100);
  }  
}

void drawNewFrame() {
  for(x=0;x<4;x++) {
    for(y=0;y<4;y++) {
      for(z=0;z<4;z++) {
        Rb.setPixelZXY(z,x,y,(RED[buffer3D[x][y][z]]),(GREEN[buffer3D[x][y][z]]),(BLUE[buffer3D[x][y][z]])); //uses R, G and B color bytes
      }
    }
  }
  newFrame = false;
  // Update the timeout timer
  streamStartedTime = millis();
  
  if (displayLength > 0 ) {
    delay(displayLength*100); // Delay (max 6 seconds)
  }
  displayLength = 0;
}

void performBlink() {
  unsigned char r = 255;
  unsigned char g = 0;
  unsigned char b = 0;

  switch (blinkColor) {
    case 'g' : // green
	  r = 0;
	  g = 255;
	  b = 0;
	  break;
	case 'b' : // blue
	  r = 0;
	  g = 0;
	  b = 255;
	  break;
	// default red
  }

  unsigned long currentMillis = millis();
  if (currentMillis - blinkPreviousMillis >= blinkInterval) {
    // save the last time you blinked the LED 
    blinkPreviousMillis = currentMillis;   
    blinkCount++;
  }
  
  if ( blinkCount % 2 == 0 ) {
    for(x=0;x<8;x++) {
      for(y=0;y<8;y++) {
        Rb.setPixelXY(x,y,r,g,b); //uses R, G and B color bytes
      }
    }
  }else{
    Rb.blankDisplay();
  }
  delay(100);
  
  if ( blinkCount > BLINK_COUNT_MAX ) {
    blinkSet = false;
    blinkCount = 0;
  }
}

void performClearScreen() {
  Rb.blankDisplay();
}

void changeAnim() {
  animation = random(0,5);
  initAnim = true;
}


// function that executes whenever data is received from master
// this function is registered as an event, see setup()
void receiveEvent(int howMany) {
  if(Wire.available() > 0) {
  // receive Data in parts
  if ( receivePart > 0 && receivePart < 3 && Wire.available() == 32) {
      switch (receivePart) {
        unsigned char receivedValue;
        case 1 : // Part 1
          for(y=0;y<4;y++)  {
            for(z=0;z<4;z++) {
              receivedValue = Wire.read();
              buffer3D[0][y][z] = receivedValue;
              //DEBUG_PRINT(receivedValue);
            }
          }
          for(y=0;y<4;y++)  {
            for(z=0;z<4;z++) {
              receivedValue = Wire.read();
              buffer3D[1][y][z] = receivedValue;
              //DEBUG_PRINT(receivedValue);
            }
          }
          receivePart++;
          break;
        case 2 : // Part2
          for(y=0;y<4;y++)  {
            for(z=0;z<4;z++) {
              receivedValue = Wire.read();
              buffer3D[2][y][z] = receivedValue; // integer read
              //DEBUG_PRINT(receivedValue);
            }
          }
          for(y=0;y<4;y++)  {
            for(z=0;z<4;z++) {
              receivedValue = Wire.read();
              buffer3D[3][y][z] = receivedValue; // integer read
              //DEBUG_PRINT(receivedValue);
            }
          }
          if ( true == streamMode ) {
            receivePart = 0;
            newFrame = true;
          }else{
            receivePart++;
          }
          break;
        default:
          receivePart++;
      }
      return; // go back
    
  }
  if ( receivePart > 3 ) { // Reset if something went wrong
    DEBUG_PRINTLN_TXT("Incomplete data received. receivePart > 3");
    receivePart = 0;
  }

 
  char c = Wire.read(); // first char identify the command
  //DEBUG_PRINTLN_TXT("Data received");
  //DEBUG_PRINT(c);
  switch (c) {
    case 'f' : // Frame was sent
      DEBUG_PRINTLN_TXT("Frame receive started");
      receivePart = 1;       
      break;
    case 'F' : // Frame completed     
      displayLength = Wire.read(); // how long should it be displayed
      DEBUG_PRINT(displayLength);
      if ( receivePart == 3 ) {
        newFrame = true;
        DEBUG_PRINTLN_TXT("Frame data received");
      }
      receivePart = 0; // Reset the counter
      break;
    case 'b' : // Blink command
      blinkSet = true;
      blinkColor = Wire.read();
      blinkCount = 0;
      DEBUG_PRINTLN_TXT("Blink data received");
      break;
    case 'd' : // Delete screen
      performClearScreen();
      DEBUG_PRINTLN_TXT("Clear screen received");
      break;
    case 's' : // Stream mode
      DEBUG_PRINTLN_TXT("Stream mode set");
      streamMode = true;
      receivePart = 1; 
      streamStartedTime = millis();
      break;
    case 'n' : // Next frame
      //DEBUG_PRINTLN_TXT("Expect next frame");
      receivePart = 1; 
      break; 
    case 'S' : // Stream mode ended
      DEBUG_PRINTLN_TXT("Stream mode ended");
      streamMode = false;
      receivePart = 0;
      return;
      break;
  }
  
  if ( newFrame == false && blinkSet == false && receivePart < 1) {
    DEBUG_PRINTLN_TXT("Incomplete data received");
    DEBUG_PRINTLN(streamMode);
    //streamMode = false;
    blinkSet = false;
    receivePart = 0;
    // clear rest buffer
    while ( Wire.available() > 0 ) {
      char c = Wire.read();
    } 
  }
  }
}


// ---------------- MAIN --------------- //

void setup() {
  Rb.init(); //initialize Rainbowduino driver
  Wire.begin(2); // initialize wire connection as slave #2
  Wire.onReceive(receiveEvent); // set function to be called
  
#ifdef DEBUG
  Serial.begin(9600);
#endif
  DEBUG_PRINTLN_TXT("Empfaenger 2");
  
  randomSeed(analogRead(0)); // Init randomizer
  
  changeAnim(); // First random animation
}


void loop()
{
  unsigned long currentMillis;
  
  if ( true == newFrame ) {
    drawNewFrame();
  }
  // In the streamMode we are only waiting for new frames and display them 
  if ( false == streamMode ) {
    // Event based animations
    if ( true == blinkSet ) {
      performBlink();
    }else{
      currentMillis = millis();
      if ( currentMillis - lastChangeTime > animInterval) {
        lastChangeTime = currentMillis;
        changeAnim();
      }
  
      switch (animation) {
        case 0:  // Plasma1
          // Create the animation array 
          if ( true == initAnim ) {
	    genPlasmaMatrix();
	    initAnim = false;
          }
          draw2D();
          break;
        case 1:  // Plasma2
          // Create the animation array 
          if ( true == initAnim ) {
	    genPlasmaMatrix2();
	    initAnim = false;
          }
          draw2D();
          break;
        case 2: // Cube3
          if ( true == initAnim ) {
            genPlasmaCube3();
	    initAnim = false;
          }
          draw3D();
          break;
        case 3: // Cube1
          if ( true == initAnim ) {
            genPlasmaCube();
	    initAnim = false;
          }
          draw3D();
          break;
        case 4: // Cube2
          if ( true == initAnim ) {
            genPlasmaCube2();
	    initAnim = false;
          }
          draw3D();
          break;
        default:  
          if ( true == initAnim ) {
            genPlasmaCube();
	    initAnim = false;
          }
          draw3D();
      }
      delay(100);
      colorshift = colorshift + 1;  
    }        
  }else{
    // Timeout for unexpected situations
    currentMillis = millis();
    if ( currentMillis - streamStartedTime > streamTimeoutInterval) {
      DEBUG_PRINTLN_TXT("Stream Timeout");
      newFrame = false;
      streamMode = false;
    }
  }
  
}

