//
//  Raytracer.m
//  glwater
//
//  Created by maruojie on 15/1/11.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "Raytracer.h"

@implementation Raytracer

- (void)update:(GLKMatrix4)modelviewMatrix {
    // get view port
    int v[4] = { 0 };
    glGetIntegerv(GL_VIEWPORT, v);
    self.viewport = GLKVector4Make(v[0], v[1], v[2], v[3]);
    
    float* m = modelviewMatrix.m;
    GLKVector3 axisX = GLKVector3Make(m[0], m[4], m[8]);
    GLKVector3 axisY = GLKVector3Make(m[1], m[5], m[9]);
    GLKVector3 axisZ = GLKVector3Make(m[2], m[6], m[10]);
    GLKVector3 offset = GLKVector3Make(m[3], m[7], m[11]);
    self.eye = GLKVector3Make(-GLKVector3DotProduct(offset, axisX),
                              -GLKVector3DotProduct(offset, axisY),
                              -GLKVector3DotProduct(offset, axisZ));
    
    int minX = v[0], maxX = minX + v[2];
    int minY = v[1], maxY = minY + v[3];
}

@end
