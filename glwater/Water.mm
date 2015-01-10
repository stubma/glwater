//
//  Water.m
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "Water.h"
#include "LightGL.h"

@implementation Water

- (id)init {
    if(self = [super init]) {
        // check extension
        BOOL canUseFloatTexture = [LightGL isExtensionSupported:"OES_texture_float"];
        BOOL canUseHalfFloatTexture = [LightGL isExtensionSupported:"OES_texture_half_float"];
        if(!canUseFloatTexture && !canUseHalfFloatTexture) {
            NSLog(@"This demo requires the OES_texture_float extension");
        }

        // texture
        if(canUseFloatTexture) {
            self.texA = [[Texture2DF alloc] initWithSize:CGSizeMake(256, 256)];
            self.texB = [[Texture2DF alloc] initWithSize:CGSizeMake(256, 256)];
        } else if(canUseHalfFloatTexture) {
            self.texA = [[Texture2DHF alloc] initWithSize:CGSizeMake(256, 256)];
            self.texB = [[Texture2DHF alloc] initWithSize:CGSizeMake(256, 256)];
        }
    }
    return self;
}

@end
