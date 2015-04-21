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
+ (bool) openConnection: (const char *) ipAddress port: (UInt32) port
{
    bool success = false;
    success = CubeNetwork::openConnection(ipAddress, port);
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