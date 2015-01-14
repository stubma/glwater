//
//  Texture2D.m
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "Texture2D.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "ieeehalfprecision.h"

@interface Texture2D ()

@property (assign, nonatomic) GLuint framebuffer;
@property (assign, nonatomic) GLuint renderbuffer;
@property (assign, nonatomic) GLint oldFramebuffer;
@property (assign, nonatomic) GLKVector4 oldViewport;

- (void)saveViewport;
- (void)createFrameBuffer;

@end

@implementation Texture2D

- (void)dealloc {
    if(self.framebuffer > 0) {
        glDeleteFramebuffers(1, &_framebuffer);
    }
    if(self.renderbuffer > 0) {
        glDeleteRenderbuffers(1, &_renderbuffer);
    }
}

- (id)initWithSize:(CGSize)size {
    if(self = [super init]) {
        self.target = GL_TEXTURE_2D;
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)size.width, (int)size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, nullptr);
        self.framebuffer = 0;
        self.renderbuffer = 0;
        self.info->width = size.width;
        self.info->height = size.height;
    }
    return self;
}

- (id)initWithSize:(CGSize)size withType:(GLenum)type {
    if(self = [super init]) {
        self.target = GL_TEXTURE_2D;
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)size.width, (int)size.height, 0, GL_RGBA, type, nullptr);
        glBindTexture(GL_TEXTURE_2D, 0);
        self.framebuffer = 0;
        self.renderbuffer = 0;
        self.info->width = size.width;
        self.info->height = size.height;
    }
    return self;
}

- (id)initWithImage:(NSString*)name {
    if(self = [super init]) {
        self.target = GL_TEXTURE_2D;
        self.framebuffer = 0;
        self.renderbuffer = 0;
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
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

- (void)saveViewport {
    int viewport[4] = { 0 };
    glGetIntegerv(GL_VIEWPORT, viewport);
    self.oldViewport = GLKVector4Make(viewport[0], viewport[1], viewport[2], viewport[3]);
}

- (void)createFrameBuffer {
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, self.framebuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, self.t, 0);
    
    glGenRenderbuffers(1, &_renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, self.renderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.info->width, self.info->height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, self.renderbuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to set texture as target: %x", status);
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void)setAsTarget {
    [self saveViewport];
    if(self.framebuffer <= 0 || self.renderbuffer <= 0) {
        [self createFrameBuffer];
    }
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, self.framebuffer);
    glViewport(0, 0, self.info->width, self.info->height);
    
    glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

- (void)printData {
    int pixels = self.info->width * self.info->height;
    uint8_t* hfbuffer = new uint8_t[pixels * 8];
    glReadPixels(0, 0, self.info->width, self.info->height, GL_RGBA, GL_HALF_FLOAT_OES, hfbuffer);
    float* fbuffer = new float[pixels * 4];
    halfp2singles(fbuffer, hfbuffer, pixels * 4);
    int y = 127;
    int x = 127;
    int i = x + y * self.info->width;
    NSLog(@"(%d:%d): r: %f, g: %f, b: %f, a: %f", y, x, fbuffer[i * 4], fbuffer[i * 4 + 1], fbuffer[i * 4 + 2], fbuffer[i * 4 + 3]);
//    for(int y = 0; y < self.info->height; y += 32) {
//        for(int x = 0; x < self.info->width; x += 32) {
//            int i = x + y * self.info->width;
//            NSLog(@"(%d:%d): r: %f, g: %f, b: %f, a: %f", y, x, fbuffer[i * 4], fbuffer[i * 4 + 1], fbuffer[i * 4 + 2], fbuffer[i * 4 + 3]);
//        }
//    }
}

- (void)restoreTarget {
    glBindFramebuffer(GL_FRAMEBUFFER, self.oldFramebuffer);
    glViewport((int)self.oldViewport.x, (int)self.oldViewport.y, (int)self.oldViewport.z, (int)self.oldViewport.w);
}

@end
