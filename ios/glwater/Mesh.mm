//
//  Mesh.m
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "Mesh.h"
#import <OpenGLES/ES2/glext.h>
#import <vector>
#import "Indexer.h"

using namespace std;

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

@interface Mesh ()

+ (GLKVector3)pickOctant:(int)i;
+ (float)fix:(float)x;

@end

@implementation Mesh

+ (Mesh*)cube {
    Mesh* m = [[Mesh alloc] init];
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    m.vbo = vbo;
    m.ibo = 0;
    m.mode = GL_TRIANGLES;
    m.vertices = sizeof(sCubeMesh) / sizeof(GLfloat) / 3;
    m.triangles = m.vertices / 3;
    glBufferData(GL_ARRAY_BUFFER, sizeof(sCubeMesh), sCubeMesh, GL_STATIC_DRAW);
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
    GLushort* ibuf = (GLushort*)malloc(m.triangles * 3 * sizeof(GLushort));
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
    
    // create vao, vbo, ibo
    GLuint vbo, ibo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glGenBuffers(1, &ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
    m.vbo = vbo;
    m.ibo = ibo;
    m.mode = GL_TRIANGLES;
    glBufferData(GL_ARRAY_BUFFER, vbufIndex * sizeof(float), vbuf, GL_STATIC_DRAW);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, ibufIndex * sizeof(GLushort), ibuf, GL_STATIC_DRAW);
    
    // free
    free(vbuf);
    free(ibuf);
    
    return m;
}

+ (GLKVector3)pickOctant:(int)i {
    return GLKVector3Make((i & 1) * 2 - 1, (i & 2) - 1, (i & 4) / 2 - 1);
}

+ (float)fix:(float)x {
    return x + (x - x * x) / 2;
}

+ (Mesh*)sphere {
    return [Mesh sphere:6];
}

+ (Mesh*)sphere:(int)detail {
    Mesh* m = [[Mesh alloc] init];
    Indexer* indexer = [[Indexer alloc] init];
    
    vector<int> ivec;
    for (int octant = 0; octant < 8; octant++) {
        GLKVector3 scale = [self pickOctant:octant];
        BOOL flip = scale.x * scale.y * scale.z > 0;
        [indexer clearIndices];
        for (int i = 0; i <= detail; i++) {
            // Generate a row of vertices on the surface of the sphere
            // using barycentric coordinates.
            for (int j = 0; i + j <= detail; j++) {
                float a = (float)i / detail;
                float b = (float)j / detail;
                float c = (float)(detail - i - j) / detail;
                GLKVector3 v = GLKVector3Make([self fix:a], [self fix:b], [self fix:c]);
                v = GLKVector3Normalize(v);
                v = GLKVector3Multiply(v, scale);
                [indexer add:v];
            }
            
            // Generate triangles from this row and the previous row.
            if (i > 0) {
                for (int j = 0; i + j <= detail; j++) {
                    int a = (i - 1) * (detail + 1) + ((i - 1) - (i - 1) * (i - 1)) / 2 + j;
                    int b = i * (detail + 1) + (i - i * i) / 2 + j;
                    if(flip) {
                        ivec.push_back([indexer indexAt:a]);
                        ivec.push_back([indexer indexAt:b]);
                        ivec.push_back([indexer indexAt:a + 1]);
                    } else {
                        ivec.push_back([indexer indexAt:a]);
                        ivec.push_back([indexer indexAt:a + 1]);
                        ivec.push_back([indexer indexAt:b]);
                    }
                    if (i + j < detail) {
                        if(flip) {
                            ivec.push_back([indexer indexAt:b]);
                            ivec.push_back([indexer indexAt:b + 1]);
                            ivec.push_back([indexer indexAt:a + 1]);
                        } else {
                            ivec.push_back([indexer indexAt:b]);
                            ivec.push_back([indexer indexAt:a + 1]);
                            ivec.push_back([indexer indexAt:b + 1]);
                        }
                    }
                }
            }
        }
    }
    
    // get buffer
    float* vbuf = [indexer createVBuf];
    GLushort* ibuf = (GLushort*)malloc(ivec.size() * sizeof(GLushort));
    GLushort* tmp = ibuf;
    for(vector<int>::iterator iter = ivec.begin(); iter != ivec.end(); iter++) {
        *tmp = *iter;
        tmp++;
    }
    
    // create vao, vbo, ibo
    GLuint vbo, ibo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glGenBuffers(1, &ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
    m.vbo = vbo;
    m.ibo = ibo;
    m.triangles = ivec.size() / 3;
    m.vertices = [indexer vertexCount];
    m.mode = GL_TRIANGLES;
    glBufferData(GL_ARRAY_BUFFER, m.vertices * sizeof(GLKVector3), vbuf, GL_STATIC_DRAW);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, ivec.size() * sizeof(GLushort), ibuf, GL_STATIC_DRAW);
    
    // free
    free(vbuf);
    free(ibuf);
    
    return m;
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
}

- (void)draw {
    glBindBuffer(GL_ARRAY_BUFFER, self.vbo);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 12, BUFFER_OFFSET(0));
    
    if(self.ibo > 0) {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.ibo);
        glDrawElements(self.mode, self.triangles * 3, GL_UNSIGNED_SHORT, 0);
    } else {
        glDrawArrays(self.mode, 0, self.vertices);
    }
}

@end
