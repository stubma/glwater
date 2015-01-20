//
//  GameViewController.m
//  glwater
//
//  Created by maruojie on 15/1/7.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#import "Program.h"
#import "Texture2D.h"
#import "TextureCube.h"
#import "Water.h"
#import "Mesh.h"
#import "LightGL.h"
#import "Raytracer.h"

typedef enum {
    MODE_NONE,
    MODE_MOVE_SPHERE,
    MODE_ADD_DROPS,
    MODE_ORBIT_CAMERA,
} DragMode;

@interface GameViewController ()

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) Program* cubeShader;
@property (strong, nonatomic) Program* causticsShader;
@property (strong, nonatomic) Program* waterShader;
@property (strong, nonatomic) Program* sphereShader;
@property (strong, nonatomic) Mesh* cubeMesh;
@property (strong, nonatomic) Mesh* waterMesh;
@property (strong, nonatomic) Mesh* sphereMesh;
@property (strong, nonatomic) TextureCube* sky;
@property (strong, nonatomic) Texture2D* tiles;
@property (strong, nonatomic) Texture2D* causticTex;
@property (strong, nonatomic) Water* water;
@property (strong, nonatomic) Raytracer* tracer;
@property (assign, nonatomic) float angleX;
@property (assign, nonatomic) float angleY;
@property (assign, nonatomic) GLKVector2 lastLoc;
@property (assign, nonatomic) GLKVector3 center;
@property (assign, nonatomic) GLKVector3 oldCenter;
@property (assign, nonatomic) GLKVector3 velocity;
@property (assign, nonatomic) GLKVector3 gravity;
@property (assign, nonatomic) float radius;
@property (assign, nonatomic) GLKVector3 lightDir;
@property (assign, nonatomic) DragMode mode;
@property (assign, nonatomic) GLKVector3 prevHit;
@property (assign, nonatomic) GLKVector3 planeNormal;
@property (assign, nonatomic) NSTimeInterval prevTime;

- (void)setupGL;
- (void)tearDownGL;
- (void)updateCaustics;
- (void)renderCube;
- (void)renderWater;
- (void)renderSphere;
- (GLKVector2)cg2glk:(CGPoint)loc;
- (GLKVector2)toGL:(GLKVector2)loc;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init context
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    // init gl view
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    // init projection matrix
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    self.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45), aspect, 0.01f, 100.0f);
    
    // init other gl
    [self setupGL];
}

- (void)dealloc {
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupGL {
    [EAGLContext setCurrentContext:self.context];
    
    self.angleX = -25;
    self.angleY = -200;
    self.center = self.oldCenter = GLKVector3Make(-0.4f, -0.75f, 0.2f);
    self.radius = 0.25;
    self.gravity = GLKVector3Make(0, -4, 0);
    self.velocity = GLKVector3Make(0, 0, 0);
    self.lightDir = GLKVector3Normalize(GLKVector3Make(2.0f, 2.0f, -1.0f));
    self.tracer = [[Raytracer alloc] init];
    self.prevTime = [NSDate timeIntervalSinceReferenceDate];
    self.mode = MODE_NONE;
    
    // cube shader
    self.cubeShader = [[Program alloc] initWithShader:@"cubeShader"];
    [self.cubeShader addUniform:UNIFORM_MVP_MATRIX];
    [self.cubeShader addUniform:UNIFORM_TILES];
    [self.cubeShader addUniform:UNIFORM_SPHERECENTER];
    [self.cubeShader addUniform:UNIFORM_SPHERERADIUS];
    [self.cubeShader addUniform:UNIFORM_LIGHT];
    [self.cubeShader addUniform:UNIFORM_WATER];
    [self.cubeShader addUniform:UNIFORM_CAUSTIC];
    
    // caustic shader
    self.causticsShader = [[Program alloc] initWithShader:@"causticsShader"];
    [self.causticsShader addUniform:UNIFORM_SPHERECENTER];
    [self.causticsShader addUniform:UNIFORM_SPHERERADIUS];
    [self.causticsShader addUniform:UNIFORM_LIGHT];
    [self.causticsShader addUniform:UNIFORM_WATER];
    
    // water shader
    self.waterShader = [[Program alloc] initWithShader:@"waterShader"];
    [self.waterShader addUniform:UNIFORM_MVP_MATRIX];
    [self.waterShader addUniform:UNIFORM_TILES];
    [self.waterShader addUniform:UNIFORM_SPHERECENTER];
    [self.waterShader addUniform:UNIFORM_SPHERERADIUS];
    [self.waterShader addUniform:UNIFORM_LIGHT];
    [self.waterShader addUniform:UNIFORM_WATER];
    [self.waterShader addUniform:UNIFORM_CAUSTIC];
    [self.waterShader addUniform:UNIFORM_SKY];
    [self.waterShader addUniform:UNIFORM_EYE];
    [self.waterShader addUniform:UNIFORM_UNDERWATER];
    
    // sphere shader
    self.sphereShader = [[Program alloc] initWithShader:@"sphereShader"];
    [self.sphereShader addUniform:UNIFORM_MVP_MATRIX];
    [self.sphereShader addUniform:UNIFORM_SPHERECENTER];
    [self.sphereShader addUniform:UNIFORM_SPHERERADIUS];
    [self.sphereShader addUniform:UNIFORM_LIGHT];
    [self.sphereShader addUniform:UNIFORM_WATER];
    [self.sphereShader addUniform:UNIFORM_CAUSTIC];
    
    // mesh
    self.cubeMesh = [Mesh cube];
    self.waterMesh = [Mesh plane:200];
    self.sphereMesh = [Mesh sphere:10];
    
    // water
    self.water = [[Water alloc] init];
    
    // sky cubemap
    self.sky = [[TextureCube alloc] initWithNegX:@"xneg.jpg"
                                            PosX:@"xpos.jpg"
                                            NegY:@"ypos.jpg"
                                            PosY:@"ypos.jpg"
                                            NegZ:@"zneg.jpg"
                                            PosZ:@"zpos.jpg"];
    
    // texture
    self.tiles = [[Texture2D alloc] initWithImage:@"tiles.jpg"];
    self.causticTex = [[Texture2D alloc] initWithSize:CGSizeMake(1024, 1024)];
    
    // add drop
    srand(0);
    for (int i = 0; i < 20; i++) {
        [self.water addDropAt:CGPointMake((float)rand() / RAND_MAX * 2 - 1, (float)rand() / RAND_MAX * 2 - 1)
                   withRadius:0.03
                  andStrength:(i & 1) ? 0.04 : -0.04];
    }
}

- (void)tearDownGL {
    [EAGLContext setCurrentContext:self.context];
}

- (GLKVector2)cg2glk:(CGPoint)loc {
    return GLKVector2Make(loc.x, loc.y);
}

- (GLKVector2)toGL:(GLKVector2)loc {
    float factor = [self.view contentScaleFactor];
    loc = GLKVector2MultiplyScalar(loc, factor);
    loc.y = self.view.bounds.size.height * factor - loc.y;
    return loc;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = touches.anyObject;
    self.lastLoc = [self cg2glk:[touch locationInView:self.view]];
    [self.tracer update:self];
    GLKVector3 ray = [self.tracer getRayForPixel:[self toGL:self.lastLoc]];
    GLKVector3 pointOnPlane = GLKVector3Add(self.tracer.eye, GLKVector3MultiplyScalar(ray, -self.tracer.eye.y / ray.y));
    HitTest* sphereHitTest = [self.tracer hitTestSphere:self.tracer.eye
                                                    ray:ray
                                                 center:self.center
                                                 radius:self.radius];
    if(sphereHitTest) {
        // clear sphere velocity
        self.velocity = GLKVector3Make(0, 0, 0);
        
        // get hit
        float factor = [self.view contentScaleFactor];
        self.prevHit = sphereHitTest.hit;
        self.mode = MODE_MOVE_SPHERE;
        self.planeNormal = [self.tracer getRayForPixel:GLKVector2Make(self.view.bounds.size.width * factor / 2, self.view.bounds.size.height * factor / 2)];
        self.planeNormal = GLKVector3Negate(self.planeNormal);
    } else if(fabs(pointOnPlane.x) < 1 && fabs(pointOnPlane.z) < 1) {
        self.mode = MODE_ADD_DROPS;
    } else {
        self.mode = MODE_ORBIT_CAMERA;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = touches.anyObject;
    GLKVector2 loc = [self cg2glk:[touch locationInView:self.view]];
    GLKVector2 glLoc = [self toGL:loc];
    switch (self.mode) {
        case MODE_MOVE_SPHERE:
        {
            // calculate hit
            [self.tracer update:self];
            GLKVector3 ray = [self.tracer getRayForPixel:GLKVector2Make(glLoc.x, glLoc.y)];
            float t = -GLKVector3DotProduct(self.planeNormal, GLKVector3Subtract([self.tracer eye], self.prevHit)) / GLKVector3DotProduct(self.planeNormal, ray);
            GLKVector3 nextHit = GLKVector3Add([self.tracer eye], GLKVector3MultiplyScalar(ray, t));
            self.center = GLKVector3Add(self.center, GLKVector3Subtract(nextHit, self.prevHit));
            self.center = GLKVector3Make(MAX(self.radius - 1, MIN(1 - self.radius, self.center.x)),
                                         MAX(self.radius - 1, MIN(10, self.center.y)),
                                         MAX(self.radius - 1, MIN(1 - self.radius, self.center.z)));
            self.prevHit = nextHit;
            break;
        }
        case MODE_ORBIT_CAMERA:
            self.angleY -= loc.x - self.lastLoc.x;
            self.angleX -= loc.y - self.lastLoc.y;
            self.angleX = MAX(-89.999, MIN(89.999, self.angleX));
            break;
        case MODE_ADD_DROPS:
        {
            [self.tracer update:self];
            GLKVector3 ray = [self.tracer getRayForPixel:[self toGL:self.lastLoc]];
            GLKVector3 pointOnPlane = GLKVector3Add(self.tracer.eye, GLKVector3MultiplyScalar(ray, -self.tracer.eye.y / ray.y));
            [self.water addDropAt:CGPointMake(pointOnPlane.x, pointOnPlane.z) withRadius:0.03f andStrength:0.01f];
            break;
        }
        default:
            break;
    }
    self.lastLoc = loc;
    
//    float theta = GLKMathDegreesToRadians(90 - self.angleY);
//    float phi = GLKMathDegreesToRadians(-self.angleX);
//    self.lightDir = GLKVector3Make(cosf(theta) * cosf(phi), sinf(phi), sinf(theta) * cosf(phi));
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.mode = MODE_NONE;
}

- (void)updateCaustics {
    [self.water.texA bind:0];
    [self.water.texA bindUniform:UNIFORM_NAME_WATER ofProgram:self.causticsShader];
    
    UniformValue v;
    v.v3 = self.lightDir;
    [self.causticsShader setUniformValue:v byName:UNIFORM_NAME_LIGHT];
    v.v3 = self.center;
    [self.causticsShader setUniformValue:v byName:UNIFORM_NAME_SPHERECENTER];
    v.f = self.radius;
    [self.causticsShader setUniformValue:v byName:UNIFORM_NAME_SPHERERADIUS];
    
    [self.causticTex setAsTarget];
    [self.causticsShader use];
    glClear(GL_COLOR_BUFFER_BIT);
    [self.waterMesh draw];
    [self.causticTex restoreTarget];
    
    [self.water.texA unbind:0];
}

- (void)update {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    float seconds = now - self.prevTime;
    self.prevTime = now;
    
    // update normal matrix and mvp matrix
    self.modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    self.modelViewMatrix = GLKMatrix4Rotate(self.modelViewMatrix, GLKMathDegreesToRadians(-self.angleX), 1, 0, 0);
    self.modelViewMatrix = GLKMatrix4Rotate(self.modelViewMatrix, GLKMathDegreesToRadians(-self.angleY), 0, 1, 0);
    self.modelViewMatrix = GLKMatrix4Translate(self.modelViewMatrix, 0, 0.5f, 0);
    self.normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(self.modelViewMatrix), NULL);
    self.modelViewProjectionMatrix = GLKMatrix4Multiply(self.projectionMatrix, self.modelViewMatrix);
    
    // update sphere
    if(self.mode != MODE_MOVE_SPHERE) {
        // Fall down with viscosity under water
        float percentUnderWater = MAX(0, MIN(1, (self.radius - self.center.y) / (2 * self.radius)));
        self.velocity = GLKVector3Add(self.velocity, GLKVector3MultiplyScalar(self.gravity, seconds - 1.1f * seconds * percentUnderWater));
        self.velocity = GLKVector3Subtract(self.velocity, GLKVector3MultiplyScalar(GLKVector3Normalize(self.velocity), percentUnderWater * seconds * GLKVector3DotProduct(self.velocity, self.velocity)));
        self.center = GLKVector3Add(self.center, GLKVector3MultiplyScalar(self.velocity, seconds));
        
        // Bounce off the bottom
        if (self.center.y < self.radius - 1) {
            self.center = GLKVector3Make(self.center.x, self.radius - 1, self.center.z);
            self.velocity = GLKVector3Make(self.velocity.x, fabs(self.velocity.y) * 0.7f, self.velocity.z);
        }
    }
    [self.water moveSphere:self.oldCenter center:self.center radius:self.radius];
    self.oldCenter = self.center;
    
    [self.water stepSimulation];
    [self.water stepSimulation];
    [self.water updateNormals];
    [self updateCaustics];
}

- (void)renderCube {
    glEnable(GL_CULL_FACE);
    
    [self.water.texA bind:0];
    [self.water.texA bindUniform:UNIFORM_NAME_WATER ofProgram:self.cubeShader];
    [self.tiles bind:1];
    [self.tiles bindUniform:UNIFORM_NAME_TILES ofProgram:self.cubeShader];
    [self.causticTex bind:2];
    [self.causticTex bindUniform:UNIFORM_NAME_CAUSTIC ofProgram:self.cubeShader];
    
    // update cube shader uniform
    UniformValue v;
    v.m4 = self.modelViewProjectionMatrix;
    [self.cubeShader setUniformValue:v byName:UNIFORM_NAME_MVP_MATRIX];
    v.v3 = self.center;
    [self.cubeShader setUniformValue:v byName:UNIFORM_NAME_SPHERECENTER];
    v.f = self.radius;
    [self.cubeShader setUniformValue:v byName:UNIFORM_NAME_SPHERERADIUS];
    v.v3 = self.lightDir;
    [self.cubeShader setUniformValue:v byName:UNIFORM_NAME_LIGHT];
    
    [self.cubeShader use];
    [self.cubeMesh draw];
    
    [self.water.texA unbind:0];
    [self.tiles unbind:1];
    [self.causticTex unbind:2];
    
    glDisable(GL_CULL_FACE);
}

- (void)renderWater {
    glEnable(GL_CULL_FACE);
    
    [self.tracer update:self];
    
    [self.water.texA bind:0];
    [self.water.texA bindUniform:UNIFORM_NAME_WATER ofProgram:self.waterShader];
    [self.tiles bind:1];
    [self.tiles bindUniform:UNIFORM_NAME_TILES ofProgram:self.waterShader];
    [self.sky bind:2];
    [self.sky bindUniform:UNIFORM_NAME_SKY ofProgram:self.waterShader];
    [self.causticTex bind:3];
    [self.causticTex bindUniform:UNIFORM_NAME_CAUSTIC ofProgram:self.waterShader];
    
    UniformValue v;
    v.m4 = self.modelViewProjectionMatrix;
    [self.waterShader setUniformValue:v byName:UNIFORM_NAME_MVP_MATRIX];
    v.v3 = self.center;
    [self.waterShader setUniformValue:v byName:UNIFORM_NAME_SPHERECENTER];
    v.f = self.radius;
    [self.waterShader setUniformValue:v byName:UNIFORM_NAME_SPHERERADIUS];
    v.v3 = self.lightDir;
    [self.waterShader setUniformValue:v byName:UNIFORM_NAME_LIGHT];
    v.v3 = self.tracer.eye;
    [self.waterShader setUniformValue:v byName:UNIFORM_NAME_EYE];
    
    for(int i = 0; i < 2; i++) {
        // i == 1 means underwater
        bool underwater = i == 1;
        v.i = underwater;
        [self.waterShader setUniformValue:v byName:UNIFORM_NAME_UNDERWATER];
        
        glCullFace(underwater ? GL_BACK : GL_FRONT);
        [self.waterShader use];
        [self.waterMesh draw];
    }
    
    [self.water.texA unbind:0];
    [self.tiles unbind:1];
    [self.sky unbind:2];
    [self.causticTex unbind:3];
    
    glDisable(GL_CULL_FACE);
}

- (void)renderSphere {
    [self.water.texA bind:0];
    [self.water.texA bindUniform:UNIFORM_NAME_WATER ofProgram:self.sphereShader];
    [self.causticTex bind:1];
    [self.causticTex bindUniform:UNIFORM_NAME_CAUSTIC ofProgram:self.sphereShader];
    
    UniformValue v;
    v.m4 = self.modelViewProjectionMatrix;
    [self.sphereShader setUniformValue:v byName:UNIFORM_NAME_MVP_MATRIX];
    v.v3 = self.center;
    [self.sphereShader setUniformValue:v byName:UNIFORM_NAME_SPHERECENTER];
    v.f = self.radius;
    [self.sphereShader setUniformValue:v byName:UNIFORM_NAME_SPHERERADIUS];
    v.v3 = self.lightDir;
    [self.sphereShader setUniformValue:v byName:UNIFORM_NAME_LIGHT];
    
    [self.sphereShader use];
    [self.sphereMesh draw];
    
    [self.water.texA unbind:0];
    [self.causticTex unbind:1];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glDepthMask(true);
    glEnable(GL_DEPTH_TEST);
    
    [self renderCube];
    [self renderWater];
    [self renderSphere];
    
    glDisable(GL_DEPTH_TEST);
}

@end
