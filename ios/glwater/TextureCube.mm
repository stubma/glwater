//
//  TextureCube.m
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "TextureCube.h"

@implementation TextureCube

- (id)initWithNegX:(NSString*)nxFile PosX:(NSString*)pxFile NegY:(NSString*)nyFile PosY:(NSString*)pyFile NegZ:(NSString*)nzFile PosZ:(NSString*)pzFile {
    if(self = [super init]) {
        // build cubemap
        self.target = GL_TEXTURE_CUBE_MAP;
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        unsigned char* outPixel8 = [self rgb888DataFromImage:nxFile];
        glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_X, 0, GL_RGB, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, outPixel8);
        delete[] outPixel8;
        outPixel8 = [self rgb888DataFromImage:pxFile];
        glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X, 0, GL_RGB, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, outPixel8);
        delete[] outPixel8;
        outPixel8 = [self rgb888DataFromImage:pyFile];
        glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, GL_RGB, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, outPixel8);
        delete[] outPixel8;
        outPixel8 = [self rgb888DataFromImage:pyFile];
        glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Y, 0, GL_RGB, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, outPixel8);
        delete[] outPixel8;
        outPixel8 = [self rgb888DataFromImage:nzFile];
        glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, GL_RGB, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, outPixel8);
        delete[] outPixel8;
        outPixel8 = [self rgb888DataFromImage:pzFile];
        glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Z, 0, GL_RGB, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, outPixel8);
        delete[] outPixel8;
    }
    return self;
}

@end
