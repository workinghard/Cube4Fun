//
//  CubeNetwork.cpp
//  Cube4Fun
//
//  Created by Nik on 28.03.15.
//  Copyright (c) 2015 DerNik. All rights reserved.
//

#include <iostream>
#include "Poco/Net/SocketAddress.h"
#include "Poco/Net/DialogSocket.h"
#include "Poco/Net/NetException.h"
#include <stdlib.h>     /* srand, rand */
#include <time.h>       /* time */
#include <chrono>

#include "CubeNetwork.h"


#ifdef WIN32
#include <windows.h>
#else
#include <unistd.h>
#endif // win32

using Poco::Net::DialogSocket;
using Poco::Net::SocketAddress;


unsigned char buffer3D[64];
unsigned char receiveBuffer[32];
int bytesReceived;
int i,x;
unsigned char color;
DialogSocket ds;
int frameChange = 0;

void sleepcp(int milliseconds) // cross-platform sleep function
{
#ifdef WIN32
    Sleep(milliseconds);
#else
    usleep(milliseconds * 1000);
#endif // win32
}

bool frame1[3][64] = { {1,0,0,1,
    0,0,0,0,
    0,0,0,0,
    1,0,0,1,
    0,0,0,0,
    0,0,0,0,          //0,1,1,0,
    0,0,0,0,          //0,1,1,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,          //0,1,1,0,
    0,0,0,0,          //0,1,1,0,
    0,0,0,0,
    1,0,0,1,
    0,0,0,0,
    0,0,0,0,
    1,0,0,1},
    {0,0,0,0,
        0,0,0,0,
        1,0,0,1,
        0,0,0,0,
        1,0,0,1,
        0,0,0,0,          //0,1,1,0,
        0,0,0,0,          //0,1,1,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,          //0,1,1,0,
        0,0,0,0,          //0,1,1,0,
        1,0,0,1,
        0,0,0,0,
        1,0,0,1,
        0,0,0,0,
        0,0,0,0},
    {0,0,0,0,
        1,0,0,1,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,            //0,1,1,0,
        0,0,0,0,            //0,1,1,0,
        1,0,0,1,
        1,0,0,1,
        0,0,0,0,            //0,1,1,0,
        0,0,0,0,            //0,1,1,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        1,0,0,1,
        0,0,0,0}};


void fillBufferWithMsg() {
    buffer3D[0] = 'G';
    buffer3D[1] = 'E';
    buffer3D[2] = 'T';
    buffer3D[3] = ' ';
    buffer3D[4] = '/';
    buffer3D[5] = '?';
    buffer3D[6] = 'S';
    buffer3D[7] = 's';
    buffer3D[8] = ' ';
    
}

void testFrame() {
//    for (color=128;color<130;color++) {
        // Create testframe
        for (x=0;x<64;x++) {
            buffer3D[x] = color;  // Red frame
        }
        if ( color > 128 ) {
            buffer3D[0]=255;
            buffer3D[3]=255;
            buffer3D[12]=255;
            buffer3D[15]=255;
            
            buffer3D[48]=255;
            buffer3D[51]=255;
            buffer3D[60]=255;
            buffer3D[63]=255;
        }else{
            buffer3D[0]=254;
            buffer3D[3]=254;
            buffer3D[12]=254;
            buffer3D[15]=254;
            
            buffer3D[48]=254;
            buffer3D[51]=254;
            buffer3D[60]=254;
            buffer3D[63]=254;
        }
        ds.sendBytes(buffer3D, 64);
  //      sleepcp(50); // 20 FPS
   // }
    
}


void testStream2() {
    int frameChange = 0;
    while (true) {
        unsigned char color = rand() % 254;
        for (i=0;i<64;i++) {
            if ( frame1[frameChange][i] == 1 ) {
                buffer3D[i] = color; // Rot
            }else{
                buffer3D[i] = 255;  // Aus
            }
        }
        ds.sendBytes(buffer3D, 64);
        sleepcp(1000); // 20 FPS
        if ( frameChange < 2 ) {
            frameChange++;
        }else{
            frameChange=0;
        }
    }
}

/*
void CubeNetwork::updateFrame() {
    unsigned char color = rand() % 254;
    for (i=0;i<64;i++) {
        if ( frame1[frameChange][i] == 1 ) {
            buffer3D[i] = color; // Rot
        }else{
            buffer3D[i] = 255;  // Aus
        }
    }
    ds.sendBytes(buffer3D, 64);
    if ( frameChange < 2 ) {
        frameChange++;
    }else{
        frameChange=0;
    }
}
*/
 
void CubeNetwork::updateFrame(const unsigned char * frameSequence, unsigned int frameCount) {
    // check for empty pointer
    if ( frameSequence != NULL ) {
        //for (startFrame = 0; startFrame<lastByte;startFrame++) {
            for (i=0;i<64;i++) {
                // Fill buffer
                buffer3D[i] = frameSequence[i+((frameCount-1)*64)];
            }
            // Send the frame
            ds.sendBytes(buffer3D, 64);
        //}
    }
}

void CubeNetwork::openConnection() {
    try {
        printf("Try open the connection\n");
        ds.connect(SocketAddress("192.168.1.79", 8081));
        fillBufferWithMsg();
        ds.sendBytes(buffer3D, 9);
    }catch (const Poco::Net::NetException & e){
        std::cerr << e.displayText() << std::endl;
    }
}

void CubeNetwork::closeConnection() {
    try {
        buffer3D[0] = 's';
        buffer3D[1] = 'S';
        ds.sendBytes(buffer3D, 2); // End the stream mode
    }catch (const Poco::Net::NetException & e){
        std::cerr << e.displayText() << std::endl;
    }
}

void CubeNetwork::initObjects() {
    srand((unsigned int)time(NULL));
    
    try {
        ds.connect(SocketAddress("192.168.1.79", 8081));
        
        fillBufferWithMsg();
        ds.sendBytes(buffer3D, 9);
        
       
        //testStream2();
        testFrame();
        
        buffer3D[0] = 's';
        buffer3D[1] = 'S';
        ds.sendBytes(buffer3D, 2); // End the stream mode
        
    }catch (const Poco::Net::NetException & e){
        std::cerr << e.displayText() << std::endl;
    }
    
    
    std::cout << "It works" << std::endl;
    
}

//void Performance_CPlusPlus::sortArray(unsigned int num_elements)
