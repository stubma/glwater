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
+ (Mesh*)sphere;

- (void)draw;

@property (assign, nonatomic) GLuint vao;
@property (assign, nonatomic) GLuint vbo;
@property (assign, nonatomic) int vertices;

@end
