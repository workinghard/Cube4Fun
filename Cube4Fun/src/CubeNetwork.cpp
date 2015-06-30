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

//using Poco::Net::DialogSocket;
//using Poco::Net::SocketAddress;
//using Poco::Exception;

TCPConnector* connector;

unsigned char buffer3D[64];
unsigned char receiveBuffer[32];
int bytesReceived;
int i,x;
unsigned char color;
int frameChange = 0;
int streamMode = 0; // 0 = off, 1 = frameStream, 2 = writeStream
TCPStream* stream;


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

void byte2uint32(unsigned char* bytes, u_int32_t msgLength) {
    unsigned char *vp = (unsigned char *)&msgLength;
    bytes[0] = vp[0];  // int32 to byte array conversion
    bytes[1] = vp[1];
    bytes[2] = vp[2];
    bytes[3] = vp[3];
}

void msgCloseFrameStream() {
    if (stream) {
        buffer3D[0] = 's';
        buffer3D[1] = 'S';
        stream->send(reinterpret_cast<const char*>(buffer3D), 2); // End the stream mode
    }
}

void msgOpenFrameStream() {
    if (stream) {
        buffer3D[0] = 'G';
        buffer3D[1] = 'E';
        buffer3D[2] = 'T';
        buffer3D[3] = ' ';
        buffer3D[4] = '/';
        buffer3D[5] = '?';
        buffer3D[6] = 'S';
        buffer3D[7] = 's';
        buffer3D[8] = ' ';
        stream->send(reinterpret_cast<const char*>(buffer3D), 9);
    }
}

void msgStartWrite(u_int32_t msgLength) {
    unsigned char myBuffer[4];
    byte2uint32(myBuffer, msgLength);
    if (stream) {
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
        
        stream->send(reinterpret_cast<const char*>(buffer3D), 13);
    }
}




void testFrame() {
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
    stream->send(reinterpret_cast<const char*>(buffer3D), 64);
}


void testStream2() {
    if (stream) {
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
            stream->send(reinterpret_cast<const char*>(buffer3D), 64);
            sleepcp(1000); // 20 FPS
            if ( frameChange < 2 ) {
                frameChange++;  
            }else{
                frameChange=0;
            }
        }
    }
}

void CubeNetwork::sendBytes(const unsigned char* byteBuffer, unsigned int byteLength) {
    printf("sendBytes called\n");
    if (stream) {
        if ( streamMode == 1 ) {
            // End the frameStreammode first    
            msgCloseFrameStream();
            streamMode = 2;
        }
        if ( byteBuffer != NULL ) {
            // let arduino knows what to expect
            msgStartWrite(byteLength);
            char myBuffer[4];
            long ret = stream->receive(myBuffer,4);
            printf("received Length:\n");
            printf("0: %u\n", myBuffer[0]);
            printf("1: %u\n", myBuffer[1]);
            printf("2: %u\n", myBuffer[2]);
            printf("3: %u\n", myBuffer[3]);
            printf("ret: %lu\n", ret);
            
            // send bytes to write
            stream->send(reinterpret_cast<const char*>(byteBuffer), byteLength);
            // Reset to the frameStream mode
            if ( streamMode == 2 ) {
                msgOpenFrameStream();
                streamMode = 1;
            }
        }
    }
}


void CubeNetwork::updateFrame(const unsigned char * frameSequence, unsigned int frameCount) {
    if (stream) {
        // check for empty pointer
        if ( frameSequence != NULL ) {
            for (i=0;i<64;i++) {
                // Fill buffer
                buffer3D[i] = frameSequence[i+((frameCount-1)*64)];
            }
            // Send the frame
            stream->send(reinterpret_cast<const char*>(buffer3D), 64);
        }
    }
    
}

bool CubeNetwork::openConnection(const char* ipAddr, unsigned int port) {
    bool connectionEstablished = false;
    printf("Try to open the connection\n");
    //std::string ipAddr_str(reinterpret_cast<const char*>(ipAddr));
    //Poco::UInt16 portNr = port;
    connector = new TCPConnector();
    stream = connector->connect(ipAddr, port, 10); //Connect with 10 seconds timout 
    if (stream) {
      msgOpenFrameStream();
      streamMode = 1;
      connectionEstablished = true;
    }

    return connectionEstablished;
}

void CubeNetwork::closeConnection() {
    msgCloseFrameStream();
    delete stream;
    streamMode = 0;
}

bool CubeNetwork::connected() {
    if (stream) {
        return true;
    }else{
        return false;
    }
}
