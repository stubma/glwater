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
#import "Texture2DF.h"
#import "Texture2DHF.h"
#import "Water.h"
#import "Mesh.h"

@interface GameViewController ()

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) Program* cubeShader;
@property (strong, nonatomic) Mesh* cubeMesh;
@property (strong, nonatomic) TextureCube* sky;
@property (strong, nonatomic) Texture2D* tiles;
@property (strong, nonatomic) Water* water;
@property (assign, nonatomic) float angleX;
@property (assign, nonatomic) float angleY;
@property (assign, nonatomic) CGPoint lastLoc;
@property (assign, nonatomic) GLKMatrix4 projectionMatrix;
@property (assign, nonatomic) GLKMatrix3 normalMatrix;
@property (assign, nonatomic) GLKMatrix4 modelViewProjectionMatrix;

- (void)setupGL;
- (void)tearDownGL;

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
    
    // cube shader
    self.cubeShader = [[Program alloc] initWithShader:@"cubeShader"];
    [self.cubeShader addUniform:UNIFORM_MVP_MATRIX];
    [self.cubeShader addUniform:UNIFORM_TILES];
    
    // mesh
    self.cubeMesh = [Mesh cube];
    
    // rotation
    self.angleX = -25;
    self.angleY = -200;
    
    // build sky
    self.sky = [[TextureCube alloc] initWithNegX:@"xneg.jpg"
                                                PosX:@"xpos.jpg"
                                                NegY:@"ypos.jpg"
                                                PosY:@"ypos.jpg"
                                                NegZ:@"zneg.jpg"
                                                PosZ:@"zpos.jpg"];
    
    // tile
    self.tiles = [[Texture2D alloc] initWithImage:@"tiles.jpg"];
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
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    [self.tiles bind:1];
    
    UniformValue v;
    v.i = 1;
    [self.cubeShader setUniformValue:v byName:UNIFORM_NAME_TILES];
    [self.cubeShader use];
    
    [self.cubeMesh draw];
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
}

@end
