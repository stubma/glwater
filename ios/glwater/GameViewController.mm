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

@interface GameViewController ()

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) Program* cubeShader;
@property (strong, nonatomic) Program* causticsShader;
@property (strong, nonatomic) Program* waterShader;
@property (strong, nonatomic) Mesh* cubeMesh;
@property (strong, nonatomic) Mesh* waterMesh;
@property (strong, nonatomic) TextureCube* sky;
@property (strong, nonatomic) Texture2D* tiles;
@property (strong, nonatomic) Texture2D* causticTex;
@property (strong, nonatomic) Water* water;
@property (strong, nonatomic) Raytracer* tracer;
@property (assign, nonatomic) float angleX;
@property (assign, nonatomic) float angleY;
@property (assign, nonatomic) CGPoint lastLoc;
@property (assign, nonatomic) GLKMatrix4 projectionMatrix;
@property (assign, nonatomic) GLKMatrix3 normalMatrix;
@property (assign, nonatomic) GLKMatrix4 modelViewMatrix;
@property (assign, nonatomic) GLKMatrix4 modelViewProjectionMatrix;
@property (assign, nonatomic) GLKVector3 center;
@property (assign, nonatomic) GLKVector3 oldCenter;
@property (assign, nonatomic) GLKVector3 velocity;
@property (assign, nonatomic) GLKVector3 gravity;
@property (assign, nonatomic) float radius;
@property (assign, nonatomic) GLKVector3 lightDir;

- (void)setupGL;
- (void)tearDownGL;
- (void)updateCaustics;
- (void)renderCube;
- (void)renderWater;
- (void)renderSphere;

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
    
    // mesh
    self.cubeMesh = [Mesh cube];
    self.waterMesh = [Mesh plane:200];
    
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
    for (int i = 0; i < 20; i++) {
        [self.water addDropAt:CGPointMake(rand() * 2 - 1, rand() * 2 - 1)
                   withRadius:0.03
                  andStrength:(i & 1) ? 0.01 : -0.01];
    }
}

- (void)tearDownGL {
    [EAGLContext setCurrentContext:self.context];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = touches.anyObject;
    self.lastLoc = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = touches.anyObject;
    CGPoint loc = [touch locationInView:self.view];
    self.angleY -= loc.x - self.lastLoc.x;
    self.angleX -= loc.y - self.lastLoc.y;
    self.angleX = MAX(-89.999, MIN(89.999, self.angleX));
    self.lastLoc = loc;
    
//    float theta = GLKMathDegreesToRadians(90 - self.angleY);
//    float phi = GLKMathDegreesToRadians(-self.angleX);
//    self.lightDir = GLKVector3Make(cosf(theta) * cosf(phi), sinf(phi), sinf(theta) * cosf(phi));
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
    // update normal matrix and mvp matrix
    self.modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    self.modelViewMatrix = GLKMatrix4Rotate(self.modelViewMatrix, GLKMathDegreesToRadians(-self.angleX), 1, 0, 0);
    self.modelViewMatrix = GLKMatrix4Rotate(self.modelViewMatrix, GLKMathDegreesToRadians(-self.angleY), 0, 1, 0);
    self.modelViewMatrix = GLKMatrix4Translate(self.modelViewMatrix, 0, 0.5f, 0);
    self.normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(self.modelViewMatrix), NULL);
    self.modelViewProjectionMatrix = GLKMatrix4Multiply(self.projectionMatrix, self.modelViewMatrix);
    
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
    
    [self.water stepSimulation];
    [self.water stepSimulation];
//    [self.water updateNormals];
//    [self updateCaustics];
}

- (void)renderCube {
    glEnable(GL_CULL_FACE);
    
    [self.water.texA bind:0];
    [self.water.texA bindUniform:UNIFORM_NAME_WATER ofProgram:self.cubeShader];
    [self.tiles bind:1];
    [self.tiles bindUniform:UNIFORM_NAME_TILES ofProgram:self.cubeShader];
    [self.causticTex bind:2];
    [self.causticTex bindUniform:UNIFORM_NAME_CAUSTIC ofProgram:self.cubeShader];
    
    [self.cubeShader use];
    
    [self.cubeMesh draw];
    
    [self.water.texA unbind:0];
    [self.tiles unbind:1];
    [self.causticTex unbind:2];
    
    glDisable(GL_CULL_FACE);
}

- (void)renderWater {
    glEnable(GL_CULL_FACE);
    
    [self.tracer update:self.modelViewMatrix];
    
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
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    [self renderCube];
    [self renderWater];
    [self renderSphere];
    
    glDisable(GL_DEPTH_TEST);
}

@end
