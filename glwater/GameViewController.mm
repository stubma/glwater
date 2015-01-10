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

@interface GameViewController ()

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) Program* cubeShader;
@property (strong, nonatomic) Mesh* cubeMesh;
@property (strong, nonatomic) TextureCube* sky;
@property (strong, nonatomic) Texture2D* tiles;
@property (strong, nonatomic) Texture2D* causticTex;
@property (strong, nonatomic) Water* water;
@property (assign, nonatomic) float angleX;
@property (assign, nonatomic) float angleY;
@property (assign, nonatomic) CGPoint lastLoc;
@property (assign, nonatomic) GLKMatrix4 projectionMatrix;
@property (assign, nonatomic) GLKMatrix3 normalMatrix;
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
    self.radius = 0;
    self.gravity = GLKVector3Make(0, -4, 0);
    self.velocity = GLKVector3Make(0, 0, 0);
    self.lightDir = GLKVector3Normalize(GLKVector3Make(2.0, 2.0, -1.0));
    
    // cube shader
    self.cubeShader = [[Program alloc] initWithShader:@"cubeShader"];
    [self.cubeShader addUniform:UNIFORM_MVP_MATRIX];
    [self.cubeShader addUniform:UNIFORM_TILES];
    [self.cubeShader addUniform:UNIFORM_SPHERECENTER];
    [self.cubeShader addUniform:UNIFORM_SPHERERADIUS];
    [self.cubeShader addUniform:UNIFORM_LIGHT];
    [self.cubeShader addUniform:UNIFORM_WATER];
    [self.cubeShader addUniform:UNIFORM_CAUSTIC];
    
    // mesh
    self.cubeMesh = [Mesh cube];
    
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
    
}

- (void)update
{
    // update normal matrix and mvp matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-self.angleX), 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-self.angleY), 0, 1, 0);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0.5f, 0);
    self.normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    self.modelViewProjectionMatrix = GLKMatrix4Multiply(self.projectionMatrix, modelViewMatrix);
    
    // update cube shader uniform
    UniformValue v;
    v.m3 = self.normalMatrix;
    [self.cubeShader setUniformValue:v byName:UNIFORM_NAME_NORMAL_MATRIX];
    v.m4 = self.modelViewProjectionMatrix;
    [self.cubeShader setUniformValue:v byName:UNIFORM_NAME_MVP_MATRIX];
    v.v3 = self.center;
    [self.cubeShader setUniformValue:v byName:UNIFORM_NAME_SPHERECENTER];
    v.f = self.radius;
    [self.cubeShader setUniformValue:v byName:UNIFORM_NAME_SPHERERADIUS];
    v.v3 = self.lightDir;
    [self.cubeShader setUniformValue:v byName:UNIFORM_NAME_LIGHT];
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    [self.water stepSimulation];
    [self.water stepSimulation];
    [self.water updateNormals];
    [self updateCaustics];
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    [self.tiles bind:1];
    [self.tiles bindUniform:UNIFORM_NAME_TILES ofProgram:self.cubeShader];
    [self.water.texA bind:0];
    [self.water.texA bindUniform:UNIFORM_NAME_WATER ofProgram:self.cubeShader];
    [self.causticTex bind:2];
    [self.causticTex bindUniform:UNIFORM_NAME_CAUSTIC ofProgram:self.cubeShader];
    
    [self.cubeShader use];
    
    [self.cubeMesh draw];
    
    [self.water.texA unbind:0];
    [self.tiles unbind:1];
    [self.causticTex unbind:2];
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
}

@end
