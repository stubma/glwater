//
//  Program.m
//  glwater
//
//  Created by maruojie on 15/1/10.
//  Copyright (c) 2015年 luma. All rights reserved.
//

#import "Program.h"

@interface Program ()

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end

@implementation Program

- (id)initWithShader:(NSString*)name {
    if(self = [super init]) {
        GLuint vertShader, fragShader;
        NSString *vertShaderPathname, *fragShaderPathname;
        
        // Create shader program.
        GLuint p = glCreateProgram();
        
        // Create and compile vertex shader.
        vertShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"vsh"];
        if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
            NSLog(@"Failed to compile vertex shader");
            return nil;
        }
        
        // Create and compile fragment shader.
        fragShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"fsh"];
        if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
            NSLog(@"Failed to compile fragment shader");
            return nil;
        }
        
        // Attach vertex shader to program.
        glAttachShader(p, vertShader);
        
        // Attach fragment shader to program.
        glAttachShader(p, fragShader);
        
        // Bind attribute locations.
        // This needs to be done prior to linking.
        glBindAttribLocation(p, GLKVertexAttribPosition, "position");
        
        // Link program.
        if (![self linkProgram:p]) {
            NSLog(@"Failed to link program: %d", p);
            
            if (vertShader) {
                glDeleteShader(vertShader);
                vertShader = 0;
            }
            if (fragShader) {
                glDeleteShader(fragShader);
                fragShader = 0;
            }
            if (p) {
                glDeleteProgram(p);
                p = 0;
            }
        } else {            
            // Release vertex and fragment shaders.
            if (vertShader) {
                glDetachShader(p, vertShader);
                glDeleteShader(vertShader);
            }
            if (fragShader) {
                glDetachShader(p, fragShader);
                glDeleteShader(fragShader);
            }
        }
        
        // save p
        self.p = p;
        self.uniforms = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc
{
    glDeleteProgram(self.p);
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (void)use {
    glUseProgram(self.p);
    for(Uniform* u in [self.uniforms allValues]) {
        if(u && u.location != -1) {
            switch (u.valueType) {
                case SAMPLER_2D:
                case SAMPLER_CUBE:
                    glUniform1i(u.location, u.value.i);
                    break;
                case BOOLEAN_TYPE:
                    glUniform1i(u.location, u.value.i);
                    break;
                case FLOAT:
                    glUniform1f(u.location, u.value.f);
                    break;
                case VECTOR_2:
                    glUniform2fv(u.location, 2, u.value.v2.v);
                    break;
                case VECTOR_3:
                    glUniform3fv(u.location, 3, u.value.v3.v);
                    break;
                case MATRIX_3:
                    glUniformMatrix3fv(u.location, 1, NO, u.value.m3.m);
                    break;
                case MATRIX_4:
                    glUniformMatrix4fv(u.location, 1, NO, u.value.m4.m);
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)setUniformValue:(UniformValue&)v byName:(NSString*)name {
    Uniform* u = [self.uniforms objectForKey:name];
    u.value = v;
}

- (void)addUniform:(Uniform*)u {
    u.location = glGetUniformLocation(self.p, [u.name cStringUsingEncoding:NSUTF8StringEncoding]);
    [self.uniforms setObject:u forKey:u.name];
}

@end
