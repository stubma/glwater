//
//  Shader.fsh
//  glwater
//
//  Created by maruojie on 15/1/7.
//  Copyright (c) 2015年 luma. All rights reserved.
//

varying lowp vec4 colorVarying;

void main() {
    gl_FragColor = colorVarying;
}
