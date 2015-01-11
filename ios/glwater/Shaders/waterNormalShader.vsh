//
//  Shader.vsh
//  glwater
//
//  Created by maruojie on 15/1/7.
//  Copyright (c) 2015年 luma. All rights reserved.
//
#ifdef GL_ES
precision mediump float;
#endif

attribute vec4 position;
varying mediump vec2 coord;

void main() {
    coord = position.xy * 0.5 + 0.5;
    gl_Position = vec4(position.xyz, 1.0);
}
