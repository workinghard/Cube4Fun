//
//  CubeNetwork.h
//  Cube4Fun
//
//  Created by Nik on 28.03.15.
//  Copyright (c) 2015 DerNik. All rights reserved.
//

#ifndef __Cube4Fun__CubeNetwork__
#define __Cube4Fun__CubeNetwork__

#include <iostream>
#include "Poco/Foundation.h"
#include "Poco/Net/SocketAddress.h"
#include "Poco/Net/DialogSocket.h"
#include "Poco/Net/NetException.h"
#include "Poco/Exception.h"
#include <stdlib.h>     /* srand, rand */
#include <time.h>       /* time */
#include <chrono>

class CubeNetwork
{
public:
    static bool connected();
    //static void initObjects();
    static void updateFrame(const unsigned char * frameSequence = NULL, unsigned int frameCount = 0);
    static void sendBytes(const unsigned char* byteBuffer = NULL, u_int32_t byteLength=0);
    static bool openConnection(const char* ipAddr, unsigned int port);
    //static void openConnection();
    static void closeConnection();
};

#endif /* defined(__Cube4Fun__CubeNetwork__) */
