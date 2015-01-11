//
//  Program.h
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Uniform.h"

@interface Program : NSObject

- (id)initWithShader:(NSString*)name;
- (void)addUniform:(Uniform*)u;
- (void)setUniformValue:(UniformValue&)v byName:(NSString*)name;
- (void)use;

@property (assign, nonatomic) GLuint p;
@property (strong, nonatomic) NSMutableDictionary* uniforms;

@end
