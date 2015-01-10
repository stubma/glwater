//
//  Texture.m
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "Texture.h"

@implementation Texture

- (id)init {
    if(self = [super init]) {
        self.info = (tImageInfo*)calloc(1, sizeof(tImageInfo));
        self.target = 0;
        glGenTextures(1, &_t);
        glBindTexture(GL_TEXTURE_2D, self.t);
    }
    return self;
}

- (void)dealloc
{
    if(self.t > 0) {
        glDeleteTextures(1, &_t);
    }
    if(self.info->data) {
        delete[] self.info->data;
    }
    free(self.info);
}

- (void)bind:(int)tnum {
    glActiveTexture(GL_TEXTURE0 + tnum);
    glBindTexture(self.target, self.t);
}

- (void)unbind:(int)tnum {
    glActiveTexture(GL_TEXTURE0 + tnum);
    glBindTexture(self.target, 0);
}

- (BOOL)rgba8888DataFromImage:(NSString*)file {
    CGImageRef cgImage = [[UIImage imageNamed:file] CGImage];
    if(cgImage == NULL) {
        return false;
    }
    
    // get image info
    self.info->width = CGImageGetWidth(cgImage);
    self.info->height = CGImageGetHeight(cgImage);
    
    CGImageAlphaInfo info = CGImageGetAlphaInfo(cgImage);
    self.info->hasAlpha = (info == kCGImageAlphaPremultipliedLast)
        || (info == kCGImageAlphaPremultipliedFirst)
        || (info == kCGImageAlphaLast)
        || (info == kCGImageAlphaFirst);
        
    // If OS version < 5.x, add condition to support jpg
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(systemVersion < 5.0f)
    {
        self.info->hasAlpha = (self.info->hasAlpha || (info == kCGImageAlphaNoneSkipLast));
    }
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
    if (colorSpace)
    {
        if (self.info->hasAlpha)
        {
            info = kCGImageAlphaPremultipliedLast;
            self.info->isPremultipliedAlpha = true;
        }
        else
        {
            info = kCGImageAlphaNoneSkipLast;
            self.info->isPremultipliedAlpha = false;
        }
    }
    else
    {
        return false;
    }
    
    // change to RGBA8888
    self.info->hasAlpha = true;
    self.info->bitsPerComponent = 8;
    self.info->data = new unsigned char[self.info->width * self.info->height * 4];
    colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(self.info->data,
                                                 self.info->width,
                                                 self.info->height,
                                                 8,
                                                 4 * self.info->width,
                                                 colorSpace,
                                                 info | kCGBitmapByteOrder32Big);
    
    CGContextClearRect(context, CGRectMake(0, 0, self.info->width, self.info->height));
    //CGContextTranslateCTM(context, 0, 0);
    CGContextDrawImage(context, CGRectMake(0, 0, self.info->width, self.info->height), cgImage);
    
    CGContextRelease(context);
    CFRelease(colorSpace);
    
    return true;
}

- (unsigned char*)rgb888DataFromImage:(NSString*)file {
    if([self rgba8888DataFromImage:file]) {
        unsigned int* inPixel32 = (unsigned int*)self.info->data;
        unsigned char* tempData = new unsigned char[self.info->width * self.info->height * 3];
        unsigned char* outPixel8 = tempData;
        
        unsigned int length = self.info->width * self.info->height;
        for(unsigned int i = 0; i < length; ++i, ++inPixel32) {
            *outPixel8++ = (*inPixel32 >> 0) & 0xFF; // R
            *outPixel8++ = (*inPixel32 >> 8) & 0xFF; // G
            *outPixel8++ = (*inPixel32 >> 16) & 0xFF; // B
        }
        return tempData;
    } else {
        return nullptr;
    }
}

@end
