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
    BOOLEAN_TYPE,
    FLOAT,
    VECTOR_2,
    VECTOR_3,
    MATRIX_3,
    MATRIX_4
} UniformValueType;

typedef union {
    GLint i;
    GLfloat f;
    GLKVector2 v2;
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
#define UNIFORM_NAME_CAUSTIC @"causticTex"
#define UNIFORM_NAME_EYE @"eye"
#define UNIFORM_NAME_WATER @"water"
#define UNIFORM_NAME_SKY @"sky"
#define UNIFORM_NAME_LIGHT @"light"
#define UNIFORM_NAME_SPHERECENTER @"sphereCenter"
#define UNIFORM_NAME_SPHERERADIUS @"sphereRadius"
#define UNIFORM_NAME_DELTA @"delta"
#define UNIFORM_NAME_UNDERWATER @"underwater"
#define UNIFORM_NAME_STRENGTH @"strength"
#define UNIFORM_NAME_DROPCENTER @"dropCenter"
#define UNIFORM_NAME_DROPRADIUS @"dropRadius"
#define UNIFORM_NORMAL_MATRIX \
    [[Uniform alloc] initWithName:UNIFORM_NAME_NORMAL_MATRIX andType:MATRIX_3]
#define UNIFORM_MVP_MATRIX \
    [[Uniform alloc] initWithName:UNIFORM_NAME_MVP_MATRIX andType:MATRIX_4]
#define UNIFORM_EYE \
    [[Uniform alloc] initWithName:UNIFORM_NAME_EYE andType:VECTOR_3]
#define UNIFORM_TILES \
    [[Uniform alloc] initWithName:UNIFORM_NAME_TILES andType:SAMPLER_2D]
#define UNIFORM_WATER \
    [[Uniform alloc] initWithName:UNIFORM_NAME_WATER andType:SAMPLER_2D]
#define UNIFORM_SKY \
    [[Uniform alloc] initWithName:UNIFORM_NAME_SKY andType:SAMPLER_CUBE]
#define UNIFORM_LIGHT \
    [[Uniform alloc] initWithName:UNIFORM_NAME_LIGHT andType:VECTOR_3]
#define UNIFORM_SPHERECENTER \
    [[Uniform alloc] initWithName:UNIFORM_NAME_SPHERECENTER andType:VECTOR_3]
#define UNIFORM_SPHERERADIUS \
    [[Uniform alloc] initWithName:UNIFORM_NAME_SPHERERADIUS andType:FLOAT]
#define UNIFORM_CAUSTIC \
    [[Uniform alloc] initWithName:UNIFORM_NAME_CAUSTIC andType:SAMPLER_2D]
#define UNIFORM_DELTA \
    [[Uniform alloc] initWithName:UNIFORM_NAME_DELTA andType:VECTOR_2]
#define UNIFORM_UNDERWATER \
    [[Uniform alloc] initWithName:UNIFORM_NAME_UNDERWATER andType:BOOLEAN_TYPE]
#define UNIFORM_STRENGTH \
    [[Uniform alloc] initWithName:UNIFORM_NAME_STRENGTH andType:FLOAT]
#define UNIFORM_DROPCENTER \
    [[Uniform alloc] initWithName:UNIFORM_NAME_DROPCENTER andType:VECTOR_2]
#define UNIFORM_DROPRADIUS \
    [[Uniform alloc] initWithName:UNIFORM_NAME_DROPRADIUS andType:FLOAT]