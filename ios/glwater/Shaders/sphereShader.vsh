#ifdef GL_ES
precision mediump float;
#endif

attribute vec4 position;

varying vec3 vPosition;

uniform vec3 sphereCenter;
uniform float sphereRadius;
uniform mat4 modelViewProjectionMatrix;

void main() {
    vPosition = sphereCenter + position.xyz * sphereRadius;
    gl_Position = modelViewProjectionMatrix * vec4(vPosition, 1.0);
}