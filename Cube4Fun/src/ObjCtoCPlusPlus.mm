
//  ObjCtoCPlusPlus.mm
//
//  Created by Nikolai Rinas on 02/02/2015.
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

#import "ObjCtoCPlusPlus.h"

#import "CubeNetwork.h"


@implementation CubeNetworkObj

/*
+ (void) initObjects
{
    CubeNetwork::initObjects();
}
 */
+ (void) updateFrame: (const unsigned char *) frameSequence count: (UInt32) frameCount
{
    CubeNetwork::updateFrame(frameSequence, frameCount);
}
+ (void) sendBytes: (const unsigned char *) byteBuffer count: (u_int32_t) byteLength
{
    CubeNetwork::sendBytes(byteBuffer, byteLength);
}
//+ (void) openConnection
+ (bool) openConnection: (const char *) ipAddress port: (UInt32) port passwd:(const char *)myPasswd
{
    bool success = false;
    success = CubeNetwork::openConnection(ipAddress, port, myPasswd);
    return success;
}
+ (void) closeConnection
{
    CubeNetwork::closeConnection();
}

+ (bool) connected
{
    return CubeNetwork::connected();
}

@end