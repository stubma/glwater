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

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

typedef struct {
    unsigned int height;
    unsigned int width;
    int          bitsPerComponent;
    bool         hasAlpha;
    bool         isPremultipliedAlpha;
    unsigned char*  data;
} tImageInfo;

static const GLfloat sCubeMesh[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    1.0f, -1.0f, -1.0f,        1.0f, 0.0f, 0.0f,
    1.0f, 1.0f, -1.0f,         1.0f, 0.0f, 0.0f,
    1.0f, -1.0f, 1.0f,         1.0f, 0.0f, 0.0f,
    1.0f, -1.0f, 1.0f,         1.0f, 0.0f, 0.0f,
    1.0f, 1.0f, -1.0f,          1.0f, 0.0f, 0.0f,
    1.0f, 1.0f, 1.0f,         1.0f, 0.0f, 0.0f,
    
    1.0f, 1.0f, -1.0f,         0.0f, 1.0f, 0.0f,
    -1.0f, 1.0f, -1.0f,        0.0f, 1.0f, 0.0f,
    1.0f, 1.0f, 1.0f,          0.0f, 1.0f, 0.0f,
    1.0f, 1.0f, 1.0f,          0.0f, 1.0f, 0.0f,
    -1.0f, 1.0f, -1.0f,        0.0f, 1.0f, 0.0f,
    -1.0f, 1.0f, 1.0f,         0.0f, 1.0f, 0.0f,
    
    -1.0f, 1.0f, -1.0f,        -1.0f, 0.0f, 0.0f,
    -1.0f, -1.0f, -1.0f,       -1.0f, 0.0f, 0.0f,
    -1.0f, 1.0f, 1.0f,         -1.0f, 0.0f, 0.0f,
    -1.0f, 1.0f, 1.0f,         -1.0f, 0.0f, 0.0f,
    -1.0f, -1.0f, -1.0f,       -1.0f, 0.0f, 0.0f,
    -1.0f, -1.0f, 1.0f,        -1.0f, 0.0f, 0.0f,
    
    -1.0f, -1.0f, -1.0f,       0.0f, -1.0f, 0.0f,
    1.0f, -1.0f, -1.0f,        0.0f, -1.0f, 0.0f,
    -1.0f, -1.0f, 1.0f,        0.0f, -1.0f, 0.0f,
    -1.0f, -1.0f, 1.0f,        0.0f, -1.0f, 0.0f,
    1.0f, -1.0f, -1.0f,        0.0f, -1.0f, 0.0f,
    1.0f, -1.0f, 1.0f,         0.0f, -1.0f, 0.0f,
    
    1.0f, 1.0f, 1.0f,          0.0f, 0.0f, 1.0f,
    -1.0f, 1.0f, 1.0f,         0.0f, 0.0f, 1.0f,
    1.0f, -1.0f, 1.0f,         0.0f, 0.0f, 1.0f,
    1.0f, -1.0f, 1.0f,         0.0f, 0.0f, 1.0f,
    -1.0f, 1.0f, 1.0f,         0.0f, 0.0f, 1.0f,
    -1.0f, -1.0f, 1.0f,        0.0f, 0.0f, 1.0f,
    
    1.0f, -1.0f, -1.0f,        0.0f, 0.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,       0.0f, 0.0f, -1.0f,
    1.0f, 1.0f, -1.0f,         0.0f, 0.0f, -1.0f,
    1.0f, 1.0f, -1.0f,         0.0f, 0.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,       0.0f, 0.0f, -1.0f,
    -1.0f, 1.0f, -1.0f,        0.0f, 0.0f, -1.0f
};

static GLfloat sPlaneMesh[] = {
    -1, -1, 0,
    1, -1, 0,
    -1, 1, 0,
    
    -1, 1, 0,
    1, -1, 0,
    1, 1, 0
};

static bool _initWithImage(CGImageRef cgImage, tImageInfo *pImageinfo)
{
    if(cgImage == NULL)
    {
        return false;
    }
    
    // get image info
    
    pImageinfo->width = CGImageGetWidth(cgImage);
    pImageinfo->height = CGImageGetHeight(cgImage);
    
    CGImageAlphaInfo info = CGImageGetAlphaInfo(cgImage);
    pImageinfo->hasAlpha = (info == kCGImageAlphaPremultipliedLast)
        || (info == kCGImageAlphaPremultipliedFirst)
        || (info == kCGImageAlphaLast)
        || (info == kCGImageAlphaFirst);
    
    // If OS version < 5.x, add condition to support jpg
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(systemVersion < 5.0f)
    {
        pImageinfo->hasAlpha = (pImageinfo->hasAlpha || (info == kCGImageAlphaNoneSkipLast));
    }
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
    if (colorSpace)
    {
        if (pImageinfo->hasAlpha)
        {
            info = kCGImageAlphaPremultipliedLast;
            pImageinfo->isPremultipliedAlpha = true;
        }
        else
        {
            info = kCGImageAlphaNoneSkipLast;
            pImageinfo->isPremultipliedAlpha = false;
        }
    }
    else
    {
        return false;
    }
    
    // change to RGBA8888
    pImageinfo->hasAlpha = true;
    pImageinfo->bitsPerComponent = 8;
    pImageinfo->data = new unsigned char[pImageinfo->width * pImageinfo->height * 4];
    colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pImageinfo->data,
                                                 pImageinfo->width,
                                                 pImageinfo->height,
                                                 8,
                                                 4 * pImageinfo->width,
                                                 colorSpace,
                                                 info | kCGBitmapByteOrder32Big);
    
    CGContextClearRect(context, CGRectMake(0, 0, pImageinfo->width, pImageinfo->height));
    //CGContextTranslateCTM(context, 0, 0);
    CGContextDrawImage(context, CGRectMake(0, 0, pImageinfo->width, pImageinfo->height), cgImage);
    
    CGContextRelease(context);
    CFRelease(colorSpace);
    
    return true;
}

static unsigned char* getImageData(NSString* file) {
    CGImageRef cgImage = [[UIImage imageNamed:file] CGImage];
    tImageInfo info;
    _initWithImage(cgImage, &info);
    unsigned int* inPixel32 = (unsigned int*)info.data;
    unsigned char* tempData = new unsigned char[info.width * info.height * 3];
    unsigned char* outPixel8 = tempData;
    
    unsigned int length = info.width * info.height;
    for(unsigned int i = 0; i < length; ++i, ++inPixel32) {
        *outPixel8++ = (*inPixel32 >> 0) & 0xFF; // R
        *outPixel8++ = (*inPixel32 >> 8) & 0xFF; // G
        *outPixel8++ = (*inPixel32 >> 16) & 0xFF; // B
    }
    return tempData;
}

@interface GameViewController () {
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}
@property (strong, nonatomic) EAGLContext *context;
@property (assign, nonatomic) BOOL canUseFloatTexture;
@property (assign, nonatomic) BOOL canUseHalfFloatTexture;
@property (strong, nonatomic) Program* cubeShader;
@property (assign, nonatomic) GLuint cubemap;
@property (assign, nonatomic) GLuint tiles;
@property (assign, nonatomic) GLuint waterA;
@property (assign, nonatomic) GLuint waterB;
@property (assign, nonatomic) float angleX;
@property (assign, nonatomic) float angleY;
@property (assign, nonatomic) CGPoint lastLoc;
@property (assign, nonatomic) GLKMatrix4 projectionMatrix;
@property (assign, nonatomic) GLKMatrix3 normalMatrix;
@property (assign, nonatomic) GLKMatrix4 modelViewProjectionMatrix;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)isExtensionSupported:(const char*)name;

@end

@implementation GameViewController

- (void)viewDidLoad
{
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

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
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

- (BOOL)isExtensionSupported:(const char*)name {
    const char* extensions = (const char*)glGetString(GL_EXTENSIONS);
    return extensions == NULL ? false : (strstr(extensions, name) != NULL);
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    self.cubeShader = [[Program alloc] initWithShader:@"cubeShader"];
    [self.cubeShader addUniform:UNIFORM_MVP_MATRIX];
    [self.cubeShader addUniform:UNIFORM_NORMAL_MATRIX];
    [self.cubeShader addUniform:UNIFORM_TILES];
    
    self.angleX = -25;
    self.angleY = -200;
    
    // cube vao
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sCubeMesh), sCubeMesh, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    glBindVertexArrayOES(0);
    
    // build cubemap
    glGenTextures(1, &_cubemap);
    glBindTexture(GL_TEXTURE_CUBE_MAP, self.cubemap);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    unsigned char* outPixel8 = getImageData(@"xneg.jpg");
    glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_X, 0, GL_RGB, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, outPixel8);
    delete[] outPixel8;
    outPixel8 = getImageData(@"xpos.jpg");
    glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X, 0, GL_RGB, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, outPixel8);
    delete[] outPixel8;
    outPixel8 = getImageData(@"ypos.jpg");
    glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, GL_RGB, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, outPixel8);
    delete[] outPixel8;
    outPixel8 = getImageData(@"ypos.jpg");
    glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Y, 0, GL_RGB, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, outPixel8);
    delete[] outPixel8;
    outPixel8 = getImageData(@"zneg.jpg");
    glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, GL_RGB, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, outPixel8);
    delete[] outPixel8;
    outPixel8 = getImageData(@"zpos.jpg");
    glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Z, 0, GL_RGB, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, outPixel8);
    delete[] outPixel8;
    
    // tile
    glGenTextures(1, &_tiles);
    glBindTexture(GL_TEXTURE_2D, self.tiles);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    outPixel8 = getImageData(@"tiles.jpg");
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 512, 512, 0, GL_RGB, GL_UNSIGNED_BYTE, outPixel8);
    delete[] outPixel8;
    
    // check extension
    self.canUseFloatTexture = [self isExtensionSupported:"OES_texture_float"];
    self.canUseHalfFloatTexture = [self isExtensionSupported:"OES_texture_half_float"];
    if(!self.canUseFloatTexture && !self.canUseHalfFloatTexture) {
        NSLog(@"This demo requires the OES_texture_float extension");
    }
    
    // water texture a
    glGenTextures(1, &_waterA);
    glBindTexture(GL_TEXTURE_2D, self.waterA);
    if(self.canUseFloatTexture) {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 256, 256, 0, GL_RGBA, GL_FLOAT, nullptr);
    } else if(self.canUseHalfFloatTexture) {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 256, 256, 0, GL_RGBA, GL_HALF_FLOAT_OES, nullptr);
    }
    
    // water texture b
    glGenTextures(1, &_waterB);
    glBindTexture(GL_TEXTURE_2D, self.waterB);
    if(self.canUseFloatTexture) {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 256, 256, 0, GL_RGBA, GL_FLOAT, nullptr);
    } else if(self.canUseHalfFloatTexture) {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 256, 256, 0, GL_RGBA, GL_HALF_FLOAT_OES, nullptr);
    }
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    glDeleteTextures(1, &_cubemap);
    glDeleteTextures(1, &_tiles);
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
    
    glBindVertexArrayOES(_vertexArray);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.tiles);
    
    UniformValue v;
    v.i = 1;
    [self.cubeShader setUniformValue:v byName:UNIFORM_NAME_TILES];
    [self.cubeShader use];
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, 0);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
}

@end
