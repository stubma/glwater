//
//  Texture2DF.m
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "Texture2DF.h"

@implementation Texture2DF

- (id)initWithSize:(CGSize)size {
    if(self = [super init]) {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)size.width, (int)size.height, 0, GL_RGBA, GL_FLOAT, nullptr);
    }
    return self;
}

@end
