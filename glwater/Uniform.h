//
//  Uniform.h
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef enum {
    SAMPLER_2D,
    SAMPLER_CUBE,
    FLOAT,
    VECTOR_3,
    MATRIX_3,
    MATRIX_4
} UniformValueType;

typedef union {
    GLint i;
    GLfloat f;
    GLKVector3 v3;
    GLKMatrix4 m4;
    GLKMatrix3 m3;
} UniformValue;

@interface Uniform : NSObject

- (id)initWithName:(NSString*)name andType:(UniformValueType)type;

@property (assign, nonatomic) GLint location;
@property (strong, nonatomic) NSString* name;
@property (assign, nonatomic) UniformValueType valueType;
@property (assign, nonatomic) UniformValue value;

@end

// predefined uniforms
#define UNIFORM_NAME_NORMAL_MATRIX @"normalMatrix"
#define UNIFORM_NAME_MVP_MATRIX @"modelViewProjectionMatrix"
#define UNIFORM_NAME_TILES @"tiles"
#define UNIFORM_NAME_EYE @"eye"
#define UNIFORM_NORMAL_MATRIX \
    [[Uniform alloc] initWithName:UNIFORM_NAME_NORMAL_MATRIX andType:MATRIX_3]
#define UNIFORM_MVP_MATRIX \
    [[Uniform alloc] initWithName:UNIFORM_NAME_MVP_MATRIX andType:MATRIX_4]
#define UNIFORM_EYE \
    [[Uniform alloc] initWithName:UNIFORM_NAME_EYE andType:VECTOR_3]
#define UNIFORM_TILES \
    [[Uniform alloc] initWithName:UNIFORM_NAME_TILES andType:SAMPLER_2D]
