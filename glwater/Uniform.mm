//
//  Uniform.m
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "Uniform.h"

@implementation Uniform

- (id)initWithName:(NSString*)name andType:(UniformValueType)type {
    if(self = [super init]) {
        self.name = name;
        self.valueType = type;
        self.location = -1;
        memset(&_value, 0, sizeof(UniformValue));
    }
    return self;
}

@end
