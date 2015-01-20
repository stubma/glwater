//
//  HitTest.m
//  glwater
//
//  Created by maruojie on 15/1/20.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "HitTest.h"

@implementation HitTest

- (id)initWithHit:(float)t hit:(GLKVector3)hit normal:(GLKVector3)normal {
    if(self = [super init]) {
        self.t = t;
        self.hit = hit;
        self.normal = normal;
    }
    return self;
}

@end
