//
//  Texture.h
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Program.h"

typedef struct {
    unsigned int height;
    unsigned int width;
    int          bitsPerComponent;
    bool         hasAlpha;
    bool         isPremultipliedAlpha;
    unsigned char*  data;
} tImageInfo;

@interface Texture : NSObject

- (void)bind:(int)tnum;
- (void)unbind:(int)tnum;
- (void)bindUniform:(NSString*)u ofProgram:(Program*)p;
- (BOOL)rgba8888DataFromImage:(NSString*)file;
- (unsigned char*)rgb888DataFromImage:(NSString*)file;

@property (assign, nonatomic) GLuint unit;
@property (assign, nonatomic) GLuint t;
@property (assign, nonatomic) tImageInfo* info;
@property (assign, nonatomic) GLenum target;

@end
