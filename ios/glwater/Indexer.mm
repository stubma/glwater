//
//  Indexer.m
//  glwater
//
//  Created by maruojie on 15/1/20.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "Indexer.h"
#import <vector>

using namespace std;

@interface Indexer ()

@property (strong, nonatomic) NSMutableDictionary* vertexMap;
@property (assign, nonatomic) vector<GLKVector3>* vertices;
@property (assign, nonatomic) vector<int>* indices;

@end

@implementation Indexer

- (id)init {
    if(self = [super init]) {
        self.vertexMap = [NSMutableDictionary dictionary];
        self.vertices = new vector<GLKVector3>();
        self.indices = new vector<int>();
    }
    return self;
}

- (void)dealloc {
    delete self.indices;
    delete self.vertices;
}

- (int)add:(GLKVector3)v {
    NSString* key = [NSString stringWithFormat:@"%f_%f_%f", v.x, v.y, v.z];
    if([self.vertexMap objectForKey:key]) {
        int index = [[self.vertexMap objectForKey:key] intValue];
        self.indices->push_back(index);
        return index;
    } else {
        int index = self.vertices->size();
        [self.vertexMap setObject:[NSNumber numberWithInt:index] forKey:key];
        self.vertices->push_back(v);
        self.indices->push_back(index);
        return index;
    }
}

- (int)indexAt:(int)seq {
    return self.indices->at(seq);
}

- (void)clearIndices {
    self.indices->clear();
}

- (float*)createVBuf {
    float* vbuf = (float*)malloc(self.vertices->size() * sizeof(GLKVector3));
    char* tmp = (char*)vbuf;
    for(vector<GLKVector3>::iterator iter = self.vertices->begin(); iter != self.vertices->end(); iter++) {
        GLKVector3& v = *iter;
        memcpy(tmp, &v, sizeof(GLKVector3));
        tmp += sizeof(GLKVector3);
    }
    return vbuf;
}

- (int)vertexCount {
    return self.vertices->size();
}

@end
