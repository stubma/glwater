//
//  Texture2D.h
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "Texture.h"

@interface Texture2D : Texture

- (id)initWithImage:(NSString*)name;
- (id)initWithSize:(CGSize)size;
- (id)initWithSize:(CGSize)size withType:(GLenum)type;
- (void)setAsTarget;
- (void)restoreTarget;

@end
