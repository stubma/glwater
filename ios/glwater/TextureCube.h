//
//  TextureCube.h
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "Texture.h"

@interface TextureCube : Texture

- (id)initWithNegX:(NSString*)nxFile PosX:(NSString*)pxFile NegY:(NSString*)nyFile PosY:(NSString*)pyFile NegZ:(NSString*)nzFile PosZ:(NSString*)pzFile;

@end
