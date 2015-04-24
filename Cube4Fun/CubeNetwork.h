//
//  CubeNetwork.h
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
