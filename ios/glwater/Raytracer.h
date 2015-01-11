//
//  Raytracer.h
//  glwater
//
//  Created by maruojie on 15/1/11.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Raytracer : NSObject

- (void)update:(GLKMatrix4)modelviewMatrix;

@property (assign, nonatomic) GLKVector3 eye;
@property (assign, nonatomic) GLKVector3 ray00;
@property (assign, nonatomic) GLKVector3 ray10;
@property (assign, nonatomic) GLKVector3 ray01;
@property (assign, nonatomic) GLKVector3 ray11;
@property (assign, nonatomic) GLKVector4 viewport;

@end
