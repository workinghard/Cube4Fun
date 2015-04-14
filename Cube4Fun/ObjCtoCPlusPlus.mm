#import "ObjCtoCPlusPlus.h"

#import "CubeNetwork.h"


@implementation CubeNetworkObj

+ (void) initObjects
{
    CubeNetwork::initObjects();
}
+ (void) updateFrame: (const unsigned char *) frameSequence count: (UInt32) frameCount
{
    CubeNetwork::updateFrame(frameSequence, frameCount);
}
+ (void) sendBytes: (const unsigned char *) byteBuffer count: (u_int32_t) byteLength
{
    CubeNetwork::sendBytes(byteBuffer, byteLength);
}
+ (void) openConnection
{
    CubeNetwork::openConnection();
}
+ (void) closeConnection
{
    CubeNetwork::closeConnection();
}


@end