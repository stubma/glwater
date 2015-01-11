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
    m.ibo = 0;
    m.mode = GL_TRIANGLES;
    m.vertices = sizeof(sCubeMesh) / sizeof(GLfloat) / 3;
    m.triangles = m.vertices / 3;
    glBufferData(GL_ARRAY_BUFFER, sizeof(sCubeMesh), sCubeMesh, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 12, BUFFER_OFFSET(0));
    glBindVertexArrayOES(0);
    return m;
}

+ (Mesh*)plane {
    return [Mesh plane:1];
}

+ (Mesh*)plane:(int)detail {
    Mesh* m = [[Mesh alloc] init];
    int detailX = detail;
    int detailY = detail;
    m.vertices = (detailX + 1) * (detailY + 1);
    m.triangles = detailX * detailY * 2;
    
    // build vertex and index buffer
    int vbufIndex = 0;
    int ibufIndex = 0;
    float* vbuf = (float*)malloc(m.vertices * sizeof(float) * 3);
    unsigned int* ibuf = (unsigned int*)malloc(m.triangles * 3 * sizeof(unsigned int));
    for(int y = 0; y <= detailY; y++) {
        float t = (float)y / detailY;
        for (int x = 0; x <= detailX; x++) {
            float s = (float)x / detailX;
            vbuf[vbufIndex++] = 2 * s - 1;
            vbuf[vbufIndex++] = 2 * t - 1;
            vbuf[vbufIndex++] = 0;
            
            if(x < detailX && y < detailY) {
                int i = x + y * (detailX + 1);
                ibuf[ibufIndex++] = i;
                ibuf[ibufIndex++] = i + 1;
                ibuf[ibufIndex++] = i + detailX + 1;
                ibuf[ibufIndex++] = i + detailX + 1;
                ibuf[ibufIndex++] = i + 1;
                ibuf[ibufIndex++] = i + detailX + 2;
            }
        }
    }
    
    GLuint vao, vbo, ibo;
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glGenBuffers(1, &ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
    m.vao = vao;
    m.vbo = vbo;
    m.ibo = ibo;
    m.mode = GL_TRIANGLES;
    glBufferData(GL_ARRAY_BUFFER, vbufIndex * sizeof(float), vbuf, GL_STATIC_DRAW);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, ibufIndex * sizeof(unsigned int), ibuf, GL_STATIC_DRAW);
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
    if(self.ibo > 0) {
        glDeleteBuffers(1, &_ibo);
    }
    if(self.vao > 0) {
        glDeleteVertexArraysOES(1, &_vao);
    }
}

- (void)draw {
    glBindVertexArrayOES(self.vao);
    if(self.ibo > 0) {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.ibo);
        glDrawElements(self.mode, self.triangles * 3, GL_UNSIGNED_INT, 0);
    } else {
        glDrawArrays(self.mode, 0, self.vertices);
    }
}

@end
