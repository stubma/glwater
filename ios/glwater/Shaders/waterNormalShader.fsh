//
//  Shader.fsh
//  glwater
//
//  Created by maruojie on 15/1/7.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D water;
uniform vec2 delta;
varying vec2 coord;

void main() {
    /* get vertex info */
    vec4 info = texture2D(water, coord);
    
    /* update the normal */
    vec3 dx = vec3(delta.x, texture2D(water, vec2(coord.x + delta.x, coord.y)).r - info.r, 0.0);
    vec3 dy = vec3(0.0, texture2D(water, vec2(coord.x, coord.y + delta.y)).r - info.r, delta.y);
    info.ba = normalize(cross(dy, dx)).xz;
    
    gl_FragColor = info;
}