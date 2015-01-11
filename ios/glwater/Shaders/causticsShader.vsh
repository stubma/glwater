#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D water;
uniform vec3 light;

attribute vec4 position;

varying mediump vec3 newPos;

const float IOR_AIR = 1.0;
const float IOR_WATER = 1.333;
const float poolHeight = 1.0;

vec2 intersectCube(vec3 origin, vec3 ray, vec3 cubeMin, vec3 cubeMax) {
    vec3 tMin = (cubeMin - origin) / ray;
    vec3 tMax = (cubeMax - origin) / ray;
    vec3 t1 = min(tMin, tMax);
    vec3 t2 = max(tMin, tMax);
    float tNear = max(max(t1.x, t1.y), t1.z);
    float tFar = min(min(t2.x, t2.y), t2.z);
    return vec2(tNear, tFar);
}

/* project the ray onto the plane */
vec3 project(vec3 origin, vec3 ray, vec3 refractedLight) {
    vec2 tcube = intersectCube(origin, ray, vec3(-1.0, -poolHeight, -1.0), vec3(1.0, 2.0, 1.0));
    origin += ray * tcube.y;
    float tplane = (-origin.y - 1.0) / refractedLight.y;
    return origin + refractedLight * tplane;
}

void main() {
    vec4 info = texture2D(water, position.xy * 0.5 + 0.5);
    info.ba *= 0.5;
    vec3 normal = vec3(info.b, sqrt(1.0 - dot(info.ba, info.ba)), info.a);
    
    /* project the vertices along the refracted vertex ray */
    vec3 refractedLight = refract(-light, vec3(0.0, 1.0, 0.0), IOR_AIR / IOR_WATER);
    vec3 ray = refract(-light, normal, IOR_AIR / IOR_WATER);
    vec3 oldPos = project(position.xzy, refractedLight, refractedLight);
    newPos = project(position.xzy + vec3(0.0, info.r, 0.0), ray, refractedLight);
    
    gl_Position = vec4(0.75 * (newPos.xz + refractedLight.xz / refractedLight.y), 0.0, 1.0);
}