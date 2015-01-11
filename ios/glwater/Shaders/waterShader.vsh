//
//  Shader.vsh
//  glwater
//
//  Created by maruojie on 15/1/7.
//  Copyright (c) 2015年 luma. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;

varying mediump vec3 vPosition;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform sampler2D water;


void main() {
    vec4 info = texture2D(water, position.xy * 0.5 + 0.5);
    vPosition = position.xzy;
    vPosition.y += info.r;
    gl_Position = modelViewProjectionMatrix * vec4(vPosition, 1.0);
}
