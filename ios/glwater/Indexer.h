//
//  Indexer.h
//  glwater
//
//  Created by maruojie on 15/1/20.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Indexer : NSObject

- (int)add:(GLKVector3)v;
- (int)indexAt:(int)seq;
- (float*)createVBuf;
- (int)vertexCount;
- (void)clearIndices;

@end
