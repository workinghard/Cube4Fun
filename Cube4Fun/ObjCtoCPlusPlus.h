//
//  ObjCtoCPlusPlus.h
//  Performance_Console
//
//  Created by Gian Luigi Romita on 12/06/14.
//  Copyright (c) 2014 Gian Luigi Romita. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CubeNetworkObj : NSObject
+ (void) updateFrame: (const unsigned char *) frameSequence count: (UInt32) frameCount;
+ (void) sendBytes: (const unsigned char *) byteBuffer count: (u_int32_t) byteLength;
+ (void) initObjects;
+ (void) openConnection;
+ (void) closeConnection;
@end