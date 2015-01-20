//
//  Raytracer.m
//  glwater
//
//  Created by maruojie on 15/1/11.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "Raytracer.h"
#import "GameViewController.h"

@implementation Raytracer

- (void)update:(GameViewController*)renderer {
    // get view port
    int v[4] = { 0 };
    glGetIntegerv(GL_VIEWPORT, v);
    self.viewport = GLKVector4Make(v[0], v[1], v[2], v[3]);
    
    // glk matrix is represented in row vector
    float* m = renderer.modelViewMatrix.m;
    GLKVector3 axisX = GLKVector3Make(m[0], m[1], m[2]);
    GLKVector3 axisY = GLKVector3Make(m[4], m[5], m[6]);
    GLKVector3 axisZ = GLKVector3Make(m[8], m[9], m[10]);
    GLKVector3 offset = GLKVector3Make(m[12], m[13], m[14]);
    self.eye = GLKVector3Make(-GLKVector3DotProduct(offset, axisX),
                              -GLKVector3DotProduct(offset, axisY),
                              -GLKVector3DotProduct(offset, axisZ));
    
    bool success;
    int minX = v[0], maxX = minX + v[2];
    int minY = v[1], maxY = minY + v[3];
    self.ray00 = GLKMathUnproject(GLKVector3Make(minX, minY, 1), renderer.modelViewMatrix, renderer.projectionMatrix, v, &success);
    self.ray00 = GLKVector3Subtract(self.ray00, self.eye);
    self.ray10 = GLKMathUnproject(GLKVector3Make(maxX, minY, 1), renderer.modelViewMatrix, renderer.projectionMatrix, v, &success);
    self.ray10 = GLKVector3Subtract(self.ray10, self.eye);
    self.ray01 = GLKMathUnproject(GLKVector3Make(minX, maxY, 1), renderer.modelViewMatrix, renderer.projectionMatrix, v, &success);
    self.ray01 = GLKVector3Subtract(self.ray01, self.eye);
    self.ray11 = GLKMathUnproject(GLKVector3Make(maxX, maxY, 1), renderer.modelViewMatrix, renderer.projectionMatrix, v, &success);
    self.ray11 = GLKVector3Subtract(self.ray11, self.eye);
}

- (GLKVector3)getRayForPixel:(GLKVector2)screenPoint {
    float x = (screenPoint.x - self.viewport.x) / self.viewport.z;
    float y = (screenPoint.y - self.viewport.y) / self.viewport.w;
    GLKVector3 ray0 = GLKVector3Lerp(self.ray00, self.ray10, x);
    GLKVector3 ray1 = GLKVector3Lerp(self.ray01, self.ray11, x);
    return GLKVector3Normalize(GLKVector3Lerp(ray0, ray1, y));
}

- (HitTest*)hitTestSphere:(GLKVector3)origin ray:(GLKVector3)ray center:(GLKVector3)center radius:(float)radius {
    GLKVector3 offset = GLKVector3Subtract(origin, center);
    float a = GLKVector3DotProduct(ray, ray);
    float b = 2 * GLKVector3DotProduct(ray, offset);
    float c = GLKVector3DotProduct(offset, offset) - radius * radius;
    float discriminant = b * b - 4 * a * c;
    if (discriminant > 0) {
        float t = (-b - sqrtf(discriminant)) / (2 * a);
        GLKVector3 hit = GLKVector3Add(origin, GLKVector3MultiplyScalar(ray, t));
        return [[HitTest alloc] initWithHit:t
                                        hit:hit
                                     normal:GLKVector3DivideScalar(GLKVector3Subtract(hit, center), radius)];
    }
    
    return nil;
}

@end
