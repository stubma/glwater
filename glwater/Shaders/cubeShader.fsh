//
//  Shader.fsh
//  glwater
//
//  Created by maruojie on 15/1/7.
//  Copyright (c) 2015年 luma. All rights reserved.
//

precision mediump float;

uniform sampler2D tiles;

varying vec3 vPosition;

const vec3 lightDir = normalize(vec3(2.0, 2.0, -1.0));
const vec3 underwaterColor = vec3(0.4, 0.9, 1.0);
const vec3 sphereCenter = vec3(0.0, 0.0, 0.0);
const float sphereRadius = 0.0;

vec3 getWallColor(vec3 point) {
    float scale = 0.5;
    vec3 wallColor;
    vec3 normal;
    if (abs(point.x) > 0.999) {
        wallColor = texture2D(tiles, point.yz * 0.5 + vec2(1.0, 0.5)).rgb;
        normal = vec3(-point.x, 0.0, 0.0);
    } else if (abs(point.z) > 0.999) {
        wallColor = texture2D(tiles, point.yx * 0.5 + vec2(1.0, 0.5)).rgb;
        normal = vec3(0.0, 0.0, -point.z);
    } else {
        wallColor = texture2D(tiles, point.xz * 0.5 + 0.5).rgb;
        normal = vec3(0.0, 1.0, 0.0);
    }
    
    scale /= length(point);
    scale *= 1.0 - 0.9 / pow(length(point - sphereCenter) / sphereRadius, 4.0);
    
    return wallColor * scale;
}

void main() {
    gl_FragColor = vec4(getWallColor(vPosition), 1.0);
}
