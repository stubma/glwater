//
//  Mesh.h
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Mesh : NSObject

+ (Mesh*)cube;
+ (Mesh*)plane;
+ (Mesh*)plane:(int)detail;
+ (Mesh*)sphere;
+ (Mesh*)sphere:(int)detail;

- (void)draw;

@property (assign, nonatomic) GLuint vbo;
@property (assign, nonatomic) GLenum mode;
@property (assign, nonatomic) GLuint ibo;
@property (assign, nonatomic) int vertices;
@property (assign, nonatomic) int triangles;

@end
