//
//  HitTest.h
//  glwater
//
//  Created by maruojie on 15/1/20.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface HitTest : NSObject

- (id)initWithHit:(float)t hit:(GLKVector3)hit normal:(GLKVector3)normal;

@property (assign, nonatomic) float t;
@property (assign, nonatomic) GLKVector3 hit;
@property (assign, nonatomic) GLKVector3 normal;

@end
