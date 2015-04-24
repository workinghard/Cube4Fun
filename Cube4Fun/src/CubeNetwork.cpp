//
//  CubeNetwork.cpp
//  Cube4Fun
//
//  Created by Nikolai Rinas on 28.03.15.
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

#include "CubeNetwork.h"


#ifdef WIN32
#include <windows.h>
#else
#include <unistd.h>
#endif // win32

using Poco::Net::DialogSocket;
using Poco::Net::SocketAddress;
using Poco::Exception;

unsigned char buffer3D[64];
unsigned char receiveBuffer[32];
int bytesReceived;
int i,x;
unsigned char color;
DialogSocket ds;
int frameChange = 0;
int streamMode = 0; // 0 = off, 1 = frameStream, 2 = writeStream

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

bool connectionEstablished = false;

void byte2uint32(unsigned char* bytes, u_int32_t msgLength) {
    unsigned char *vp = (unsigned char *)&msgLength;
    bytes[0] = vp[0];  // int32 to byte array conversion
    bytes[1] = vp[1];
    bytes[2] = vp[2];
    bytes[3] = vp[3];
}

void msgCloseFrameStream() {
    try {
        buffer3D[0] = 's';
        buffer3D[1] = 'S';
        ds.sendBytes(buffer3D, 2); // End the stream mode
    }catch (const Poco::Net::NetException & e){
        std::cerr << e.displayText() << std::endl;
    }
}

void msgOpenFrameStream() {
    try {
        buffer3D[0] = 'G';
        buffer3D[1] = 'E';
        buffer3D[2] = 'T';
        buffer3D[3] = ' ';
        buffer3D[4] = '/';
        buffer3D[5] = '?';
        buffer3D[6] = 'S';
        buffer3D[7] = 's';
        buffer3D[8] = ' ';
      ds.sendBytes(buffer3D, 9);
    }catch (const Poco::Net::NetException & e){
        std::cerr << e.displayText() << std::endl;
    }
}

void msgStartWrite(u_int32_t msgLength) {
    unsigned char myBuffer[4];
    byte2uint32(myBuffer, msgLength);
    try{
        buffer3D[0] = 'G';
        buffer3D[1] = 'E';
        buffer3D[2] = 'T';
        buffer3D[3] = ' ';
        buffer3D[4] = '/';
        buffer3D[5] = '?';
        buffer3D[6] = 'W';
        buffer3D[7] = 'w';
        buffer3D[8] = myBuffer[0];  // int32 to byte array conversion
        buffer3D[9] = myBuffer[1];
        buffer3D[10] = myBuffer[2];
        buffer3D[11] = myBuffer[3];
        buffer3D[12] = ' ';
        
        printf("sending Length:\n");
        printf("0: %u\n", myBuffer[0]);
        printf("1: %u\n", myBuffer[1]);
        printf("2: %u\n", myBuffer[2]);
        printf("3: %u\n", myBuffer[3]);
        
        ds.sendBytes(buffer3D, 13);
    }catch (const Poco::Net::NetException & e){
        std::cerr << e.displayText() << std::endl;
    }
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

void CubeNetwork::sendBytes(const unsigned char* byteBuffer, unsigned int byteLength) {
    printf("sendBytes called\n");
    if ( connectionEstablished) {
    if ( streamMode == 1 ) {
        // End the frameStreammode first
        msgCloseFrameStream();
        streamMode = 2;
    }
    if ( byteBuffer != NULL ) {
        try {
            printf("Open connection for writing\n");
            //ds.connect(SocketAddress("192.168.1.79", 8081));
            // let arduino knows what to expect
            msgStartWrite(byteLength);
            unsigned char myBuffer[4];
            int ret = ds.receiveRawBytes(myBuffer, 4);
            printf("received Length:\n");
            printf("0: %u\n", myBuffer[0]);
            printf("1: %u\n", myBuffer[1]);
            printf("2: %u\n", myBuffer[2]);
            printf("3: %u\n", myBuffer[3]);
            printf("ret: %u\n", ret);
            
            // send bytes to write
            ds.sendBytes(byteBuffer, byteLength);
            //ds.close();
            // Reset to the frameStream mode
            if ( streamMode == 2 ) {
                msgOpenFrameStream();
                streamMode = 1;
            }
        }catch (const Poco::Net::NetException & e){
            std::cerr << e.displayText() << std::endl;
        }
    }
    }
    
}


void CubeNetwork::updateFrame(const unsigned char * frameSequence, unsigned int frameCount) {
    if (connectionEstablished) {
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
    
}

bool CubeNetwork::openConnection(const char* ipAddr, unsigned int port) {
    connectionEstablished = false;
    printf("Try to open the connection\n");
    std::string ipAddr_str(reinterpret_cast<const char*>(ipAddr));
    Poco::UInt16 portNr = port;
    try {
        ds.connect(SocketAddress(ipAddr_str, portNr), Poco::Timespan(10, 0));

        msgOpenFrameStream();
        streamMode = 1;
        connectionEstablished = true;
    }catch (Poco::Net::NetException & e){
        std::cerr << e.displayText() << std::endl;
        ds.close();
    }catch (Poco::TimeoutException & e) {
        std::cerr << e.displayText() << std::endl;
        ds.close();
    }catch (Exception e){
        std::cerr << e.displayText() << std::endl;
        ds.close();
    }
    return connectionEstablished;
}

void CubeNetwork::closeConnection() {
    try {
        connectionEstablished = false;
        msgCloseFrameStream();
        ds.close();
    }catch (const Poco::Net::NetException & e){
        std::cerr << e.displayText() << std::endl;
    }
    streamMode = 0;
}

bool CubeNetwork::connected() {
    return connectionEstablished;
}

/*

void CubeNetwork::initObjects() {
    srand((unsigned int)time(NULL));
    
    try {
        ds.connect(SocketAddress("192.168.1.79", 8081));
        
        fillBufferWithMsgStartStream();
        ds.sendBytes(buffer3D, 9);
        
       
        //testStream2();
        testFrame();
        
        msgCloseFrameStream();
        
    }catch (const Poco::Net::NetException & e){
        std::cerr << e.displayText() << std::endl;
    }
    
    
    //std::cout << "It works" << std::endl;
    
}

*/
//void Performance_CPlusPlus::sortArray(unsigned int num_elements)
