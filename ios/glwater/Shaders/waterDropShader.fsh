#ifdef GL_ES
precision highp float;
#endif

uniform sampler2D water;
uniform vec2 dropCenter;
uniform float dropRadius;
uniform float strength;

varying vec2 coord;

const float PI = 3.141592653589793;

void main() {
    /* get vertex info */
    vec4 info = texture2D(water, coord);
    
    /* add the drop to the height */
    float drop = max(0.0, 1.0 - length(dropCenter * 0.5 + 0.5 - coord) / dropRadius);
    drop = 0.5 - cos(drop * PI) * 0.5;
    info.r += drop * strength;
    
    gl_FragColor = info;
}