//
//  Water.h
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture2D.h"
#import "Program.h"
#import "Mesh.h"

@interface Water : NSObject

- (void)stepSimulation;
- (void)updateNormals;
- (void)addDropAt:(CGPoint)pos withRadius:(float)radius andStrength:(float)strength;

@property (strong, nonatomic) Texture2D* texA;
@property (strong, nonatomic) Texture2D* texB;
@property (strong, nonatomic) Program* updateShader;
@property (strong, nonatomic) Program* normalShader;
@property (strong, nonatomic) Program* dropShader;
@property (strong, nonatomic) Mesh* plane;

@end
