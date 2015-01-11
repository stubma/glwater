//
//  LightGL.h
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

@interface LightGL : NSObject

+ (BOOL)isExtensionSupported:(const char*)name;

@end
