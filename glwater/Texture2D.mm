//
//  Texture2D.m
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "Texture2D.h"

@implementation Texture2D

- (id)initWithImage:(NSString*)name {
    if(self = [super init]) {
        self.target = GL_TEXTURE_2D;
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        unsigned char* outPixel8 = [self rgb888DataFromImage:@"tiles.jpg"];
        if(outPixel8) {
            // not support NPOT yet
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, self.info->width, self.info->height, 0, GL_RGB, GL_UNSIGNED_BYTE, outPixel8);
            delete[] outPixel8;
        } else {
            return nil;
        }
    }
    return self;
}

@end
