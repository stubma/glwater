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
        BOOL canUseFloatTextureColorBuffer = [LightGL isExtensionSupported:"GL_EXT_color_buffer_float"];
        BOOL canUseHalfFloatTextureColorBuffer = [LightGL isExtensionSupported:"GL_EXT_color_buffer_half_float"];
        if(!((canUseFloatTexture && canUseFloatTextureColorBuffer) || (canUseHalfFloatTexture && canUseHalfFloatTextureColorBuffer))) {
            NSLog(@"This demo requires the OES_texture_float&GL_EXT_color_buffer_float or OES_texture_half_float&GL_EXT_color_buffer_half_float extension");
        }

        // texture
        if(canUseFloatTexture && canUseFloatTextureColorBuffer) {
            self.texA = [[Texture2D alloc] initWithSize:CGSizeMake(256, 256) withType:GL_FLOAT];
            self.texB = [[Texture2D alloc] initWithSize:CGSizeMake(256, 256) withType:GL_FLOAT];
        } else if(canUseHalfFloatTexture && canUseHalfFloatTextureColorBuffer) {
            self.texA = [[Texture2D alloc] initWithSize:CGSizeMake(256, 256) withType:GL_HALF_FLOAT_OES];
            self.texB = [[Texture2D alloc] initWithSize:CGSizeMake(256, 256) withType:GL_HALF_FLOAT_OES];
        }
        
        // shaders
        self.updateShader = [[Program alloc] initWithShader:@"waterUpdateShader"];
        [self.updateShader addUniform:UNIFORM_WATER];
        [self.updateShader addUniform:UNIFORM_DELTA];
        self.normalShader = [[Program alloc] initWithShader:@"waterNormalShader"];
        [self.normalShader addUniform:UNIFORM_WATER];
        [self.normalShader addUniform:UNIFORM_DELTA];
        self.dropShader = [[Program alloc] initWithShader:@"waterDropShader"];
        [self.dropShader addUniform:UNIFORM_WATER];
        [self.dropShader addUniform:UNIFORM_DROPCENTER];
        [self.dropShader addUniform:UNIFORM_STRENGTH];
        [self.dropShader addUniform:UNIFORM_DROPRADIUS];
        self.sphereShader = [[Program alloc] initWithShader:@"waterSphereShader"];
        [self.sphereShader addUniform:UNIFORM_WATER];
        [self.sphereShader addUniform:UNIFORM_NEWCENTER];
        [self.sphereShader addUniform:UNIFORM_OLDCENTER];
        [self.sphereShader addUniform:UNIFORM_SPHERERADIUS];
        
        // mesh
        self.plane = [Mesh plane];
    }
    return self;
}

- (void)addDropAt:(CGPoint)pos withRadius:(float)radius andStrength:(float)strength {
    [self.texA bind:0];
    [self.texA bindUniform:UNIFORM_NAME_WATER ofProgram:self.dropShader];
    
    UniformValue v;
    v.v2 = GLKVector2Make(pos.x, pos.y);
    [self.dropShader setUniformValue:v byName:UNIFORM_NAME_DROPCENTER];
    v.f = radius;
    [self.dropShader setUniformValue:v byName:UNIFORM_NAME_DROPRADIUS];
    v.f = strength;
    [self.dropShader setUniformValue:v byName:UNIFORM_NAME_STRENGTH];
    
    [self.texB setAsTarget];
    [self.dropShader use];
    [self.plane draw];
    [self.texB restoreTarget];
    
    [self.texA unbind:0];
    
    // swap
    Texture2D* tmp = self.texA;
    self.texA = self.texB;
    self.texB = tmp;
}

- (void)stepSimulation {
    UniformValue v;
    v.v2 = GLKVector2Make(1.0f / self.texA.info->width, 1.0f / self.texA.info->height);
    [self.updateShader setUniformValue:v byName:UNIFORM_NAME_DELTA];
    
    [self.texB setAsTarget];
    [self.texA bind:0];
    [self.texA bindUniform:UNIFORM_NAME_WATER ofProgram:self.updateShader];
    [self.updateShader use];
    [self.plane draw];
    [self.texB restoreTarget];
    
    [self.texA unbind:0];
    
    // swap
    Texture2D* tmp = self.texA;
    self.texA = self.texB;
    self.texB = tmp;
}

- (void)updateNormals {
    UniformValue v;
    v.v2 = GLKVector2Make(1.0f / self.texA.info->width, 1.0f / self.texA.info->height);
    [self.normalShader setUniformValue:v byName:UNIFORM_NAME_DELTA];
    
    [self.texB setAsTarget];
    [self.texA bind:0];
    [self.texA bindUniform:UNIFORM_NAME_WATER ofProgram:self.normalShader];
    [self.normalShader use];
    [self.plane draw];
    [self.texB restoreTarget];
    
    [self.texA unbind:0];
    
    // swap
    Texture2D* tmp = self.texA;
    self.texA = self.texB;
    self.texB = tmp;
}

- (void)moveSphere:(GLKVector3)oldCenter center:(GLKVector3)center radius:(float)radius {
    UniformValue v;
    v.v3 = oldCenter;
    [self.sphereShader setUniformValue:v byName:UNIFORM_NAME_OLDCENTER];
    v.v3 = center;
    [self.sphereShader setUniformValue:v byName:UNIFORM_NAME_NEWCENTER];
    v.f = radius;
    [self.sphereShader setUniformValue:v byName:UNIFORM_NAME_SPHERERADIUS];
    
    [self.texB setAsTarget];
    [self.texA bind:0];
    [self.texA bindUniform:UNIFORM_NAME_WATER ofProgram:self.sphereShader];
    [self.sphereShader use];
    [self.plane draw];
    [self.texB restoreTarget];
    [self.texA unbind:0];
    
    // swap
    Texture2D* tmp = self.texA;
    self.texA = self.texB;
    self.texB = tmp;
}

@end
