//
//  LightGL.m
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "LightGL.h"

@implementation LightGL

+ (BOOL)isExtensionSupported:(const char*)name {
    const char* extensions = (const char*)glGetString(GL_EXTENSIONS);
    return extensions == NULL ? false : (strstr(extensions, name) != NULL);
}

@end
