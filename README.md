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

![alt text][overview1]

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

## Arduino with network shield and sd-card
This piece is a main controller. The main objectives are:
 * Handle the communcation like receiving animation requests and process 
 * Save and read animations from SD card
 * Send data to the Rainbowduino
TODO: More details to come

## Rainbowduino:
This piece receives data over I2C protocol and displays it on the cube.
It has also some animations. In case there is no data to display it plays default animations.
There is not much logic on this side. For more details please check the [Rainbowduino Wiki](http://www.seeedstudio.com/wiki/Rainbow_Cube)


[logo]: http://cube4fun.net/public/Cube6-128j.png "Logo"
[overview1]: http://cube4fun.net/public/Overview-Pic1.png "Overview"
