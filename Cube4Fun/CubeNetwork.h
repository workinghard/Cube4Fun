//
//  CubeNetwork.h
//  Cube4Fun
//
//  Created by Nik on 28.03.15.
//  Copyright (c) 2015 DerNik. All rights reserved.
//

#ifndef __Cube4Fun__CubeNetwork__
#define __Cube4Fun__CubeNetwork__

class CubeNetwork
{
public:
   
    static void initObjects();
    static void updateFrame(const unsigned char * frameSequence = NULL, unsigned int frameCount = 0);
    static void openConnection();
    static void closeConnection();
    
};

#endif /* defined(__Cube4Fun__CubeNetwork__) */
