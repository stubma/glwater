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

varying mediump vec3 vPosition;

uniform mat4 modelViewProjectionMatrix;

const float poolHeight = 1.0;

void main() {
    vPosition = position.xyz;
    vPosition.y = ((1.0 - vPosition.y) * (7.0 / 12.0) - 1.0) * poolHeight;
    gl_Position = modelViewProjectionMatrix * vec4(vPosition, 1.0);
}
