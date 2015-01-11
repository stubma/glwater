//
//  Mesh.m
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "Mesh.h"
#import <OpenGLES/ES2/glext.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

static const GLfloat sCubeMesh[] = {
    1.0f, -1.0f, -1.0f,
    1.0f, 1.0f, -1.0f,
    1.0f, -1.0f, 1.0f,
    1.0f, -1.0f, 1.0f,
    1.0f, 1.0f, -1.0f,
    1.0f, 1.0f, 1.0f,
    
    1.0f, 1.0f, -1.0f,
    -1.0f, 1.0f, -1.0f,
    1.0f, 1.0f, 1.0f,
    1.0f, 1.0f, 1.0f,
    -1.0f, 1.0f, -1.0f,
    -1.0f, 1.0f, 1.0f,
    
    -1.0f, 1.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,
    -1.0f, 1.0f, 1.0f,
    -1.0f, 1.0f, 1.0f,
    -1.0f, -1.0f, -1.0f,
    -1.0f, -1.0f, 1.0f,
    
    -1.0f, -1.0f, -1.0f,
    1.0f, -1.0f, -1.0f,
    -1.0f, -1.0f, 1.0f,
    -1.0f, -1.0f, 1.0f,
    1.0f, -1.0f, -1.0f,
    1.0f, -1.0f, 1.0f,
    
    1.0f, 1.0f, 1.0f,
    -1.0f, 1.0f, 1.0f,
    1.0f, -1.0f, 1.0f,
    1.0f, -1.0f, 1.0f,
    -1.0f, 1.0f, 1.0f,
    -1.0f, -1.0f, 1.0f,
    
    1.0f, -1.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,
    1.0f, 1.0f, -1.0f,
    1.0f, 1.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,
    -1.0f, 1.0f, -1.0f,
};

static GLfloat sPlaneMesh[] = {
    -1, -1, 0,
    1, -1, 0,
    -1, 1, 0,
    
    -1, 1, 0,
    1, -1, 0,
    1, 1, 0
};

@implementation Mesh

+ (Mesh*)cube {
    Mesh* m = [[Mesh alloc] init];
    GLuint vao, vbo;
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    m.vao = vao;
    m.vbo = vbo;
    m.vertices = sizeof(sCubeMesh) / sizeof(GLfloat) / 3;
    glBufferData(GL_ARRAY_BUFFER, sizeof(sCubeMesh), sCubeMesh, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 12, BUFFER_OFFSET(0));
    glBindVertexArrayOES(0);
    return m;
}

+ (Mesh*)plane {
    Mesh* m = [[Mesh alloc] init];
    GLuint vao, vbo;
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    m.vao = vao;
    m.vbo = vbo;
    m.vertices = sizeof(sPlaneMesh) / sizeof(GLfloat) / 3;
    glBufferData(GL_ARRAY_BUFFER, sizeof(sPlaneMesh), sPlaneMesh, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 12, BUFFER_OFFSET(0));
    glBindVertexArrayOES(0);
    return m;
}

+ (Mesh*)sphere {
    return nil;
}

- (id)init {
    if(self = [super init]) {
    }
    return self;
}

- (void)dealloc {
    if(self.vbo > 0) {
        glDeleteBuffers(1, &_vbo);
    }
    if(self.vao > 0) {
        glDeleteVertexArraysOES(1, &_vao);
    }
}

- (void)draw {
    glBindVertexArrayOES(self.vao);
    glDrawArrays(GL_TRIANGLES, 0, self.vertices);
}

@end
