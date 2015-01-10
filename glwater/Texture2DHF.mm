//
//  Texture2DHF.m
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "Texture2DHF.h"
#import <OpenGLES/ES2/glext.h>

@implementation Texture2DHF

- (id)initWithSize:(CGSize)size {
    if(self = [super init]) {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)size.width, (int)size.height, 0, GL_RGBA, GL_HALF_FLOAT_OES, nullptr);
    }
    return self;
}

@end
