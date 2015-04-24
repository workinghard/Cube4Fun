//
//  Webserver4Rainbow
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

#define DEBUG

#include <Wire.h>
#include <SD.h>
#include <SPI.h>
#include <Ethernet.h>
//#include <MemoryFree.h>



#ifdef DEBUG
  #define DEBUG_PRINTLN(x)  Serial.println (x)
  #define DEBUG_PRINT(x) Serial.print (x)
  #define DEBUG_PRINT2(x,y) Serial.print (x,y)
  #define DEBUG_PRINTLN_TXT(x)  Serial.println (F(x))
  #define DEBUG_PRINT_TXT(x) Serial.print (F(x))
#else
  #define DEBUG_PRINTLN(x)
  #define DEBUG_PRINT(x)
  #define DEBUG_PRINT2(x,y)
  #define DEBUG_PRINTLN_TXT(x)
  #define DEBUG_PRINT_TXT(x)
#endif 

#define INBUFFER 65
#define MY_CUBE_ADDR 2
#define MAX_SEND_RETRY 10
#define SERVER_PORT 8081
#define ANIM_FILE_NAME "ANIMS.FRM"
#define MAX_ANIMKEY_LENGTH 12
#define MY_STREAM_KEEPALIVE_TIME 2000 // Send at least every 2 seconds one frame  
//#define MY_STREAM_TIMEOUT 30000 // Reset broken connection   

unsigned char myReadBuffer[INBUFFER];        // string for fetching data from address
unsigned char myReadBufferCount = 0;

//int getState = 0;
// Enter a MAC address for your controller below.
// Newer Ethernet shields have a MAC address printed on a sticker on the shield
byte mac[] = {
  0x90, 0xA2, 0xDA, 0x06, 0x00, 0x2A
};
// Fallback defaults
IPAddress ip(192,168,1,79);
IPAddress gateway(192,168,1, 1);
IPAddress subnet(255, 255, 255, 0);
//unsigned char x,y,z;
unsigned char mySendBuffer[32];
unsigned char myReceiveBuffer[64];

unsigned char serverMode = 0; // Default waiting for commands/requests

unsigned char myAnimationCount = 0;
unsigned int _animationSpeed = 0;
unsigned long _animationLength = 0;
unsigned long _animationStartPos = 0;
unsigned long _animationEndPos = 0;
unsigned int _animationActFrame = 0;
unsigned long _previousMillis = 0;        // will store last time animation frame was sent

unsigned long _lastTimeFrameSent = 0; // general check when last frame was sent, use for timeout

// often used chars
unsigned const char lc_b = 'b';
unsigned const char lc_g = 'g';
unsigned const char lc_r = 'r';
unsigned const char lc_n = 'n';
unsigned const char lc_f = 'f';
unsigned const char lc_F = 'F';
unsigned const char lc_s = 's';
unsigned const char lc_S = 'S';
unsigned const char lc_G = 'G';
unsigned const char lc_E = 'E';
unsigned const char lc_T = 'T';
unsigned const char lc_coma = ',';
unsigned const char lc_space = ' ';
unsigned const char lc_slash = '/';
unsigned const char lc_question = '?';
unsigned const char lc_newline = '\n';
unsigned const char lc_return = '\r';


// Initialize the Ethernet client library
// with the IP address and port of the server
// that you want to connect to (port 80 is default for HTTP):
//EthernetClient client;

// Initialize the Ethernet server library
// with the IP address and port you want to use 
EthernetServer server(SERVER_PORT);


// --- FUNCTIONS --- //
// String functions START
void appendChar2readBuffer(unsigned char c) {
  myReadBuffer[myReadBufferCount] = c;
  myReadBufferCount++;
}
int readBufferCompare2(const char* c, int count) {
  int result = 0 - count;
  for (unsigned char x=0;x<count;x++) {
    if (myReadBuffer[x] == c[x]) {
      result++;
    }
  }
  return result;  
}
//--String functions END

void clearSavedAnimation() {
  DEBUG_PRINTLN("Anim reset");
  // Reset the animation
  _animationLength = 0; 
  _animationStartPos = 0;
  _animationEndPos = 0;
  _animationActFrame = 0; 
  _animationSpeed = 0; 
}

void clearBufferedFrame() {
  for (unsigned char x=0;x<64;x++) {
    mySendBuffer[x] = myReceiveBuffer[255];
  }
}

void sendStartFrameStream() {
  mySendBuffer[0] = lc_s;
  wireSendBytes(mySendBuffer, 1);
  DEBUG_PRINTLN_TXT("Frm strmmd started");  
}

void sendEndFrameStream() {
  sendEmptyFrame();  // Send last frame
  mySendBuffer[0] = lc_S;
  wireSendBytes(mySendBuffer, 1);
  DEBUG_PRINTLN_TXT("Frm strmmd ended");  
}

// We need this function to change properly between different modes
void setServerMode(unsigned char newMode) {
  if ( serverMode != newMode ) {
    DEBUG_PRINT(serverMode);
    DEBUG_PRINT_TXT(" -> ");
    DEBUG_PRINTLN(newMode);
    // Transition from 0 -> 1
    if ( serverMode == 0 && newMode == 1 ) { 
      clearBufferedFrame();
      sendStartFrameStream();
    // Transition from 0 -> 2
    }else if ( serverMode == 0 && newMode == 2 ) {
      clearBufferedFrame();
      sendStartFrameStream();
    // Transition from 1 -> 0
    }else if ( serverMode == 1 && newMode == 0 ) {
      sendEndFrameStream();
    // Transition from 2 -> 0  
    }else if ( serverMode == 2 && newMode == 0 ) {
      sendEndFrameStream();
      clearSavedAnimation();
    // Transition from 2 -> 1
    }else if ( serverMode == 2 && newMode == 1 ) {
      // Don't display saved animation again
      //   this behaviour may be changed if prefered
      clearBufferedFrame();
      clearSavedAnimation();
    }
    // Transition from 1 -> 2
    //   nothing special to do
  
    serverMode = newMode;
  }
}

unsigned char checkRequest(unsigned char c, unsigned char readState) {
// Check for GET request and safe the data
  switch (readState) {
    case 0:
      if ( c == lc_G ) { readState = 1; }; break;
    case 1:
      if ( c == lc_E ) { readState = 2; }else{ readState = 0; }; break;
    case 2:
      if ( c == lc_T ) { readState = 3; }else{ readState = 0; }; break;
    case 3:
      if ( c == lc_space ) { readState = 4; }else{ readState = 0; }; break;
    case 4:
      if ( c == lc_slash ) { readState = 5; }else{ readState = 0; }; break;
    case 5:
      if ( c == lc_question ) { readState = 6; }else{ readState = 0; }; break;
    case 6:
      // Falls der Buffer noch nicht voll
      if ( myReadBufferCount < INBUFFER ) {
        if ( c == lc_space || c == lc_return || c == lc_newline ) {
          // Less data than buffersize
          readState = 7;
        }else{
          // Fille the buffer
          appendChar2readBuffer(c);
        }
      }else{
        // More data than buffersize
        readState = 7;
      }
      break;
    default:
      // Reset the state for unknown data
      readState = 0;
  }
  return readState;
}

void processRequest(EthernetClient client) {
  boolean debugFunc = false;
#ifdef DEBUG  
  // check the form
  if(readBufferCompare2("2=red", 5) > -1) {
    sentBlink(lc_r);
    DEBUG_PRINTLN_TXT("Red blink sent");
    debugFunc = true;
  }else if(readBufferCompare2("3=blue", 6) > -1) {
    sentBlink(lc_b);
    DEBUG_PRINTLN_TXT("Blue blink sent");
    debugFunc = true;
  }else if(readBufferCompare2("4=green", 7) > -1) {
    sentBlink(lc_g);
    DEBUG_PRINTLN_TXT("Green blink sent");
    debugFunc = true;
  }else if(readBufferCompare2("5=send", 6) > -1) {
    setFrame();
    DEBUG_PRINTLN_TXT("Frametest started");
    debugFunc = true;
  }else if(readBufferCompare2("6=start", 7) > -1) {
    sendStream();
    DEBUG_PRINTLN_TXT("Streamtest started");
    debugFunc = true;
  }else if(readBufferCompare2("7=file", 6) > -1) {
    printFileContent();
    DEBUG_PRINTLN_TXT("File content");
    debugFunc = true;
  } 
#endif

  if ( debugFunc == false ) {
    if (readBufferCompare2("Ss", 2) > -1) { // Streammode, expect frames
      DEBUG_PRINTLN_TXT("Set mode to 1");
      setServerMode(1);
    }else if(readBufferCompare2("Ww", 2) > -1 ) { // Stream write mode
      writeAnimationSDCard(client); // blocking mode !!
    }else{ 
      checkAnimationSDCard();  // Check if we have animations on the SD card
    } 
  }
}

void wireSendBytes(const uint8_t *data, size_t quantity) {
  boolean try_again = true;
  uint8_t error;
  unsigned char send_retries = 0;
  while ( try_again == true ) {
    Wire.beginTransmission(MY_CUBE_ADDR);
    if ( quantity == 1 ) { 
      Wire.write(data[0]);
    }else{
      Wire.write(data, quantity);
    }
    error = Wire.endTransmission();
    if ( error == 0 || send_retries > MAX_SEND_RETRY ) {
      // everything went well or timeout 
      try_again = false;
    }else{
      // Something went wrong
      DEBUG_PRINTLN_TXT("Send failed"); 
    }
    delayMicroseconds(10);
  }
  send_retries++;
}


void sentBlink(unsigned char color) {
  mySendBuffer[0] = lc_b;
  mySendBuffer[1] = color;
  wireSendBytes(mySendBuffer, 2);
}

void setFrame() {
  int color = 0;
  int pos = random(0,64);
  mySendBuffer[0] = lc_f;
  wireSendBytes(mySendBuffer, 1);
  for (unsigned char x=0;x<32;x++) {
    if ( x == pos ) { color = random(0,64);}
    mySendBuffer[x] = color;
    color = 0;
  }
  wireSendBytes(mySendBuffer, 32);
  for (unsigned char x=0;x<32;x++) {
    if ( x+32 == pos ) { color = random(0,64);}
    mySendBuffer[x] = color;
    color = 0;
  }
  wireSendBytes(mySendBuffer, 32);
  mySendBuffer[0] = lc_F;    
  mySendBuffer[1] = 50; // Show for two seconds
  wireSendBytes(mySendBuffer, 2);
}

void sendStream() {
  unsigned char pos;

  // Set to the stream mode
  mySendBuffer[0] = lc_s;
  wireSendBytes(mySendBuffer,1);
  // Begin data transmission
  for ( pos=0;pos<64;pos++ ) {
    //DEBUG_PRINT_TXT("Sende frame: ");
    //DEBUG_PRINTLN(pos);
    // Send walking led   
    int color = 0;
    for (unsigned char x=0;x<32;x++) { // First half frame
      if ( x == pos ) { color = 128;}
      mySendBuffer[x] = color;
      color = 0;
    }
    wireSendBytes(mySendBuffer, 32);

    for (unsigned char x=0;x<32;x++) {
      if ( x+32 == pos ) { color = 128;}
      mySendBuffer[x] = color;
      color = 0;
    }
    wireSendBytes(mySendBuffer, 32);

    // call for new frame
    if ( pos<63 ) {
      mySendBuffer[0] = lc_n;
      wireSendBytes(mySendBuffer, 1);
    } 
    
    // Delay for 200ms
    delay(50);
  }
  // End the stream mode
  mySendBuffer[0] = lc_S;
  wireSendBytes(mySendBuffer, 1);

}

void sendBufferedFrame() {
  // Split the received Buffer in two parts and send them to the LED shield
  
  for (unsigned char x=0;x<32;x++) { // First half frame
    mySendBuffer[x] = myReceiveBuffer[x];
  }
  wireSendBytes(mySendBuffer, 32);
  for (unsigned char x=0;x<32;x++) {  // Second half frame
    mySendBuffer[x] = myReceiveBuffer[x+32];
  }
  wireSendBytes(mySendBuffer, 32);
  
  mySendBuffer[0] = lc_n;
  wireSendBytes(mySendBuffer, 1);
  
  // Remember when the frame was sent las time
  _lastTimeFrameSent = millis();
}

void sendEmptyFrame() {  // Because we need last frame for the LED shield
  for (unsigned char x=0;x<32;x++) { // First half frame
    mySendBuffer[x] = 0;
  }
  wireSendBytes(mySendBuffer, 32);
  wireSendBytes(mySendBuffer, 32);  
}

int sendFrameCached(unsigned char c, int bufferSize) {
  myReceiveBuffer[bufferSize] = c;
  if ( bufferSize<63 ) {
    bufferSize++;
  }else{
    // send the buffer
    sendBufferedFrame();
    bufferSize=0;
  }
  return bufferSize;
}

void printFileContent() {
  File myProjectFile = SD.open(ANIM_FILE_NAME, FILE_READ);
  if (myProjectFile) {
    while (myProjectFile.available()) {
      unsigned char myC = myProjectFile.read();
      DEBUG_PRINTLN(myC);
    } 
  }
}


void checkAnimationSDCard() {
  // Open File for read
  File myProjectFile = SD.open(ANIM_FILE_NAME, FILE_READ);
  if (myProjectFile) {
    DEBUG_PRINTLN_TXT("Reading keys");
    
    unsigned char myReadStatus = 0; // 0 = expect key
    unsigned char myC = 0;
    unsigned char myKeyBuffer[MAX_ANIMKEY_LENGTH]; // maximum length for the key
    unsigned char myKeyLength = 0;
    unsigned char myIntBuffer[2]; // Byte to int
    unsigned char myIntBufferLength = 0;     
    
    while (myProjectFile.available() && myReadStatus < 20) {
      myC = myProjectFile.read();
     
      switch (myReadStatus) {
        case 0: // expect key
          if ( myC == lc_coma ) {
            myReadStatus = 1; // Startkey found  
          }
          break;
        case 1: // expect keyline confirmation
          if ( myC == lc_F ) {
            myReadStatus = 2; //  Key-line confirmed
          }else{
            myReadStatus = 0; // Reset 
          }
          break;
        case 2: // Reading animation key
          if ( myC == lc_coma ) {
            myReadStatus = 3; // change to read next element
          }else if ( myKeyLength < MAX_ANIMKEY_LENGTH ) { // Fill till max buffer
            myKeyBuffer[myKeyLength] = myC;
            myKeyLength++;
          }
          break;
        case 3: // Save playtime
          if ( myIntBufferLength < 2 ) { // Save playtime value
            myIntBuffer[myIntBufferLength] = myC;
            myIntBufferLength++;
          }
          if ( myIntBufferLength == 2 ) { // Buffer is full, set values
            unsigned int animationLength = word(myIntBuffer[1], myIntBuffer[0]);
            // Save the time the animation will end
            _animationLength = animationLength * 1000 + millis();
            // clear buffer
            myIntBufferLength = 0;
            // expect next value
            myReadStatus = 4;
          }
          break;
        case 4: // Save speed
          if ( myIntBufferLength < 2 ) { // Save speed value
            myIntBuffer[myIntBufferLength] = myC;
            myIntBufferLength++;
          }
          if ( myIntBufferLength == 2 ) { // Buffer is full, set values
            _animationSpeed = word(myIntBuffer[1], myIntBuffer[0]);
            // clear buffer
            myIntBufferLength = 0;
            // expect next value
            myReadStatus = 5;
          }
          break;
        case 5: // Save frames
          if ( myIntBufferLength < 2 ) { // Save speed value
            myIntBuffer[myIntBufferLength] = myC;
            myIntBufferLength++;
          }
          if ( myIntBufferLength == 2 ) { // Buffer is full, set values
            // set to complete read
            myReadStatus = 6;
            unsigned int animationFrames = word(myIntBuffer[1], myIntBuffer[0]);
            // Calculate start and end position
            _animationStartPos = myProjectFile.position() + 1;
            _animationEndPos = _animationStartPos + 65 * animationFrames;
            // Check if the key matches
            if(readBufferCompare2(reinterpret_cast<const char*>(myKeyBuffer), myKeyLength) > -1) {
              // We found animation
              DEBUG_PRINTLN_TXT("Found animation");
               myReadStatus = 20; // End search, we found our animation
            }else{
              DEBUG_PRINTLN_TXT("No animation found");
              if (_animationEndPos > _animationStartPos ) { 
                // Goto next frame 
                myProjectFile.seek(_animationEndPos);
              }
            }
            
            // clear buffer
            myIntBufferLength = 0;
          }
          break;
        case 6:
          if( myC == lc_newline ) { // uncomplete keyline or no animation found
            // check for values
            if ( _animationEndPos > 0 && _animationStartPos > 0 && _animationSpeed > 0 ) {
              DEBUG_PRINTLN_TXT("Anim key found");
            }else{
              DEBUG_PRINTLN_TXT("--keyline failed--");
              // Reset everything
              myReadStatus = 0; 
              myKeyLength = 0;
              myIntBufferLength = 0;
              clearSavedAnimation();
            }
          }            
          break;
      }
    } 
  }
  myProjectFile.close();
}

boolean readAnimationSD() {
  unsigned char myC;
  unsigned char myBytes = 0;
  // Read SD Card
  File myProjectFile = SD.open(ANIM_FILE_NAME, FILE_READ);
  // Goto start position
  if ( myProjectFile.available() ) {
    unsigned long _animationPos = _animationStartPos + _animationActFrame * 65; // startPos + offset
    if ( _animationPos < _animationEndPos ) { 
      myProjectFile.seek(_animationPos);
    }else{
      _animationActFrame = 0; // Start at the first frame again
      myProjectFile.seek(_animationStartPos);
    }
  }
  // Read one frame
  while ( myProjectFile.available() && myBytes < 64 ) { 
    myC = myProjectFile.read();
    myReceiveBuffer[myBytes] = myC;
    myBytes++; 
  } 

  // close the file:
  myProjectFile.close();
  
  // If we have complete frame, return true
  if ( myBytes > 63 ) { 
    // read successfull
    _animationActFrame++;
    return true;
  }else{
    return false;
  }
}

unsigned long byte2Long(unsigned char* byteArray) {
  // little endian conversion
  unsigned long retval;
  retval  = (unsigned long) byteArray[3] << 24 | (unsigned long) byteArray[2] << 16;
  retval |= (unsigned long) byteArray[1] << 8 | byteArray[0];  
  return retval;
}
void writeAnimationSDCard(EthernetClient client) {
  // Send answer
  unsigned char readBuffer[4];
  readBuffer[0] = myReadBuffer[2];
  readBuffer[1] = myReadBuffer[3];
  readBuffer[2] = myReadBuffer[4];
  readBuffer[3] = myReadBuffer[5];
  unsigned long fileSize = byte2Long(readBuffer);

//  DEBUG_PRINT_TXT("fileSizeBuffer: ");
  for (unsigned char i=0; i<4; i++ ) {
    client.write(readBuffer[i]);
//    DEBUG_PRINT(readBuffer[i]);
  }
  client.write(lc_return);
  client.write(lc_newline);
//  DEBUG_PRINTLN_TXT(" ");

  
  
//  DEBUG_PRINT_TXT("Filesize expected:");
//  DEBUG_PRINTLN(fileSize);
  
  // Blocking mode to write receiving data to file
  if (client) {
    // Remove file if exists
    if ( SD.exists(ANIM_FILE_NAME) ) {
      SD.remove(ANIM_FILE_NAME);
    }
    
    File myProjectFile = SD.open(ANIM_FILE_NAME, FILE_WRITE);
    unsigned long receivedBytes = 0;
    
    if (myProjectFile) {
      while (client.connected() && receivedBytes < fileSize) {
        if (client.available()) {
          unsigned char c = client.read();
          //writing bytes
          myProjectFile.write(c);
          receivedBytes++;
        } 
      }
    }
/*
    if ( receivedBytes == fileSize ) {
      DEBUG_PRINTLN_TXT("Complete data received\n");
    }else{
      DEBUG_PRINTLN_TXT("Data incomplete\n");
    }
    DEBUG_PRINT_TXT("Expected:");
    DEBUG_PRINTLN(fileSize);
    DEBUG_PRINT_TXT("Received:");
    DEBUG_PRINTLN(receivedBytes);
*/
    myProjectFile.close();
  }
}

void displaySavedAnimation() {
  if ( _animationLength > 0 ) { // Animation was set
    unsigned long currentMillis = millis();
    // Display animation set over the network
    if ( currentMillis < _animationLength ) { // __animationLength = startTime + animLengthTime
      if ( _animationStartPos > 0 && _animationEndPos > 0 && _animationSpeed > 0){ // validity check
        if ( _animationEndPos > _animationStartPos ) {
          //DEBUG_PRINTLN_TXT("Setting mode to 2");
          setServerMode(2); // Switch the server mode
          if ( currentMillis - _previousMillis >= _animationSpeed ) { // Sent data with the set speed
            // save the last time you sent frame
            _previousMillis = currentMillis;  
            // Fill Buffer
            if ( true == readAnimationSD() ) {
              // Send buffered frame
              sendBufferedFrame();
            } 
          }
        }     
      } 
    }else{
      // End the stream mode
      setServerMode(0);
    }
  }   
}

void keepAliveFrame() {
  // Check if we need to send a keep alive frame
  if ( millis() - _lastTimeFrameSent > MY_STREAM_KEEPALIVE_TIME ) {
    // Send buffered frame
    sendBufferedFrame();
  }
}

// --------- MAIN ---------- //

void setup() {
  // put your setup code here, to run once:
  Wire.begin();
  
#ifdef DEBUG
  Serial.begin(9600);
#endif
  DEBUG_PRINTLN_TXT("Sender1");

  DEBUG_PRINTLN_TXT("Init SD card...");
  // On the Ethernet Shield, CS is pin 4. It's set as an output by default.
  // Note that even if it's not used as the CS pin, the hardware SS pin
  // (10 on most Arduino boards, 53 on the Mega) must be left as an output
  // or the SD library functions will not work.
  // disable w5100 SPI
  pinMode(10, OUTPUT);
  //digitalWrite(10,HIGH);
  
  if (!SD.begin(4)) {
    DEBUG_PRINTLN_TXT("init failed!");
    // TODO: deny some functions
  }else{
    DEBUG_PRINTLN_TXT("init done.");
  }

  // start the Ethernet connection:
  Ethernet.begin(mac, ip, gateway, subnet); 

// ----------------------
/* Sorry, but had to drop DHCP support due to missing memory
// If you have a MEGA, feel free to use it 
  if (Ethernet.begin(mac) == 0) {
    DEBUG_PRINTLN_TXT("Failed to configure Ethernet using DHCP");
    DEBUG_PRINTLN_TXT("Using defaults 192.168.1.79");
    // initialize the ethernet device not using DHCP:
    Ethernet.begin(mac, ip, gateway, subnet); 
  }
*/
// -----------------------

#ifdef DEBUG
  // print your local IP address:
  DEBUG_PRINTLN_TXT("My IP: ");
  for (byte thisByte = 0; thisByte < 4; thisByte++) {
    // print the value of each byte of the IP address:
    DEBUG_PRINT2(Ethernet.localIP()[thisByte], DEC);
    DEBUG_PRINT(".");
  }
  DEBUG_PRINTLN_TXT("");
#endif

  // Print free memory
  //DEBUG_PRINT("freeMemory()=");
  //DEBUG_PRINTLN(freeMemory());
}


void loop() {
  // Process Server requests
  //   listen for incoming clients
  EthernetClient client = server.available();
  
  if (client) { // Client connected and sending data
    DEBUG_PRINTLN_TXT("Client attached");
    // Init status
    unsigned char readState = 0;
    unsigned char lastChar = 0; // Make sure you never check for 0-value !!!
    int bufferSize = 0;
    // If we receive data, interrupt other states
    setServerMode(0);
    
    // Read incoming data
    while (client.connected()) {
      if (client.available()) {
        // get incoming byte
        unsigned char c = client.read();
        
        // check for server mode
        switch (serverMode) {
          case 0:
            // Checking incoming requests
            readState = checkRequest(c, readState);
            
            // Processing if request is recognized
            if ( readState == 7 ) { // HTTP GET recognized
              processRequest(client);
              // process only one time
              readState = 0;
              myReadBufferCount = 0;
            }
            break;
            
          case 1:
            // Streaming frames
            bufferSize = sendFrameCached(c, bufferSize);
            
            // Check for streaming end
            if ( c == lc_S && lastChar == lc_s ) { // "sS" received
              //sendEndFrameStream();
              setServerMode(0);
              bufferSize = 0;
            }
            
            break;
        }
        
        // if we got whole HTTP Head and still waiting for commands,
        //   send HTTP answer
        if ( serverMode == 0 && c == lc_newline && lastChar == lc_return ) { // \r\n was send
            // send a standard http response header
            client.println(F("HTTP/1.1 200 OK\nContent-Type: text/html\r\n\n<html><head><title>Rainbowduino Webserver</title></head><body><br><hr/><h1><div align=center>Rainbowduino Webserver 1.0</div></h1><hr /><br><div align=left>Functions:</div><br><table border=1 width=500 cellpadding=5><tr><td>Blink:<br></td><td align=center><form method=get><input type=submit name=2 value=red></form><form method=get><input type=submit name=3 value=blue></form><form method=get><input type=submit name=4 value=green></form></td></tr><tr><td>Frametest<br></td><td align=center><form method=get><input type=submit name=5 value=send></form></td></tr><tr><td>Streamtest<br></td><td align=center><form method=get><input type=submit name=6 value=start></form></td></tr><tr><td>Print file to serial<br></td><td align=center><form method=get><input type=submit name=7 value=file></form></td></tr></table><br></body></html>"));
            // Close the connection
            client.stop();  
        }
        
        lastChar = c;
      }
      
      // If we are in the streaming mode and don't receive any frames,
      //   check for timeout
      if ( serverMode == 1 ) {
        // keep the connection to the Rainbowduino alive
        keepAliveFrame();
      }
    }    

    // give web browser time to receive the data
    delay(1);
    // close the connection
    client.stop();    
  }
  
  if ( serverMode == 1 && client == false) {
    // If client closed the connection and we are still in the
    //   stream mode, reset to normal operation
    setServerMode(0);
  }
  
  // ------------------------------------------------//
  // Display Animation
  displaySavedAnimation();

}
