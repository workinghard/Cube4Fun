# Cube4Fun
![alt text][logo]

## Index
 1. [Overview](#overview)
 2. [Requirements](#requirements)
 3. [Software](##software)
 4. [Hardware](##hardware)
 5. [Arduino controller](#arduino-with-network-shield-and-sd-card)

## Overview
* Create your own cool 3D animations and tag them
* Upload to your Cube4Fun
* Use the animation-tag from any internet service/device by sending GET/  request to activate animations
* Share your animations with everybody on [this site:](http://www.cube4fun.net)

![alt text][overviewIMG1]

## Requirements
### Software
* MacOS 10.10 or higher
* Cube4Fun Application (TODO: Link)
* Arduino Image (TODO: Link)
* Rainbowduino Image (TODO: Link)
 
### Hardware
* Arduino Uno or Arduino Mega
* Arduino network shield
* SD card
* Rainbowduino + RGB Cube [check this Wiki for more details](http://www.seeedstudio.com/wiki/Rainbow_Cube)

----

## Arduino with network shield and SD card
This component is a main controller. The main objectives are:
 * Handle the communication like receiving animation requests and process 
 * Save and read animations from SD card
 * Send data to the Rainbowduino
 
TODO: More details to come

## Rainbowduino:
This component receives data over I2C protocol and displays it on the cube.
It has also some animations. In case there is no data to display it plays default animations.
There is no much logic on this side. For more details please check the [Rainbowduino Wiki](http://www.seeedstudio.com/wiki/Rainbow_Cube)

### Implemented functions:
The communication is only one way and without call backs to achive maximum frames per second. Every sent character or number is exactly one byte. So basically it's a byte stream with following format:
| Command               | Format        | Description | Examples | 
| --------------------- | ------------- | ----------- | -------- |
| Blink red/green/blue  | b(r|g|b)      | Blink for couple of seconds with specified color | br |
| Clear frame           | d             | Turn all LEDs off | d |
| Stream mode           | s<64 bytes>n<64 bytes>S | Displays an unlimited number of frames in stream mode. Draws a frame as soon as 64 bytes (one frame) are received | 



## Cube4Fun Application
The application is written in a new apple programming language [Swift](https://developer.apple.com/swift/). The communication part is using the [Poco Library](http://pocoproject.org/) which is written in C++. So it's easy to create a new application for any other device and don't care about TCP/IP communication.



[logo]: http://cube4fun.net/public/Cube6-128j.png "Logo"
[overviewIMG1]: http://cube4fun.net/public/Overview-Pic1.png "Overview"
