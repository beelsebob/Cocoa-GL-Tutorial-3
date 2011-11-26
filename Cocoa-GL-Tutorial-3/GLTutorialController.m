//
//  GLTutorialController.m
//  GLTutorial
//
//  Created by Tom Davie on 20/02/2011.
//  Copyright 2011 Tom Davie. All rights reserved.
//

#import "GLTutorialController.h"

#import "error.h"

typedef struct
{
    Vector4 position;
    Colour colour;
} Vertex;

@interface GLTutorialController ()

- (void)createOpenGLView;

- (void)createDisplayLink;

- (void)createOpenGLResources;
- (void)loadShader;
- (GLuint)compileShaderOfType:(GLenum)type file:(NSString *)file;
- (void)linkProgram:(GLuint)program;
- (void)validateProgram:(GLuint)program;

- (void)loadBufferData;

- (void)renderForTime:(CVTimeStamp)time;

@end

CVReturn displayCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext);

CVReturn displayCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext)
{
    GLTutorialController *controller = (GLTutorialController *)displayLinkContext;
    [controller renderForTime:*inOutputTime];
    return kCVReturnSuccess;
}

@implementation GLTutorialController
{
    CVDisplayLinkRef displayLink;
    
    GLuint shaderProgram;
    GLuint vertexArrayObject;
    GLuint vertexBuffer;
    GLuint indexBuffer;
    
    GLint uniforms[kNumUniforms];
    
    GLint colourAttribute;
    GLint positionAttribute;
}

@synthesize view;
@synthesize window;

- (void)awakeFromNib
{
    [self createOpenGLView];
    [self createOpenGLResources];
    [self createDisplayLink];
}

- (void)createOpenGLView
{
    NSOpenGLPixelFormatAttribute pixelFormatAttributes[] =
    {
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        NSOpenGLPFAColorSize    , 24                           ,
        NSOpenGLPFAAlphaSize    , 8                            ,
        NSOpenGLPFADepthSize    , 32                           ,
        NSOpenGLPFADoubleBuffer ,
        NSOpenGLPFAAccelerated  ,
        NSOpenGLPFANoRecovery   ,
        0
    };
    NSOpenGLPixelFormat *pixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes] autorelease];
    [self setView:[[[NSOpenGLView alloc] initWithFrame:[[[self window] contentView] bounds] pixelFormat:pixelFormat] autorelease]];
    [[[self window] contentView] addSubview:[self view]];
}

- (void)createDisplayLink
{
    CGDirectDisplayID displayID = CGMainDisplayID();
    CVReturn error = CVDisplayLinkCreateWithCGDisplay(displayID, &displayLink);
    
    if (kCVReturnSuccess == error)
    {
        CVDisplayLinkSetOutputCallback(displayLink, displayCallback, self);
        CVDisplayLinkStart(displayLink);
    }
    else
    {
        NSLog(@"Display Link created with error: %d", error);
        displayLink = NULL;
    }
}

- (void)createOpenGLResources
{
    [[[self view] openGLContext] makeCurrentContext];
    
    [self loadShader];
    [self loadBufferData];
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
}

- (void)loadShader
{
    GLuint vertexShader;
    GLuint fragmentShader;
    
    vertexShader   = [self compileShaderOfType:GL_VERTEX_SHADER   file:[[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"]];
    fragmentShader = [self compileShaderOfType:GL_FRAGMENT_SHADER file:[[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"]];
    
    if (0 != vertexShader && 0 != fragmentShader)
    {
        shaderProgram = glCreateProgram();
        GetError();
        
        glAttachShader(shaderProgram, vertexShader  );
        GetError();
        glAttachShader(shaderProgram, fragmentShader);
        GetError();
        
        glBindFragDataLocation(shaderProgram, 0, "fragColour");
        
        [self linkProgram:shaderProgram];
        
        uniforms[kProjectionUniform] = glGetUniformLocation(shaderProgram, "mvp");
        GetError();
        for (int uniformNumber = 0; uniformNumber < kNumUniforms; uniformNumber++)
        {
            if (uniforms[uniformNumber] < 0)
            {
                [NSException raise:kFailedToInitialiseGLException format:@"Shader is missing a uniform."];
            }
        }
        colourAttribute   = glGetAttribLocation(shaderProgram, "colour"  );
        GetError();
        if (colourAttribute < 0)
        {
            [NSException raise:kFailedToInitialiseGLException format:@"Shader did not contain the 'colour' attribute."];
        }
        positionAttribute = glGetAttribLocation(shaderProgram, "position");
        GetError();
        if (positionAttribute < 0)
        {
            [NSException raise:kFailedToInitialiseGLException format:@"Shader did not contain the 'position' attribute."];
        }
        
        glDeleteShader(vertexShader  );
        GetError();
        glDeleteShader(fragmentShader);
        GetError();
    }
    else
    {
        [NSException raise:kFailedToInitialiseGLException format:@"Shader compilation failed."];
    }
}

- (GLuint)compileShaderOfType:(GLenum)type file:(NSString *)file
{
    GLuint shader;
    const GLchar *source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSASCIIStringEncoding error:nil] cStringUsingEncoding:NSASCIIStringEncoding];
    
    if (nil == source)
    {
        [NSException raise:kFailedToInitialiseGLException format:@"Failed to read shader file %@", file];
    }
    
    shader = glCreateShader(type);
    GetError();
    glShaderSource(shader, 1, &source, NULL);
    GetError();
    glCompileShader(shader);
    GetError();
    
#if defined(DEBUG)
    GLint logLength;
    
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
    GetError();
    if (logLength > 0)
    {
        GLchar *log = malloc((size_t)logLength);
        glGetShaderInfoLog(shader, logLength, &logLength, log);
        GetError();
        NSLog(@"Shader compilation failed with error:\n%s", log);
        free(log);
    }
#endif
    
    GLint status;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    GetError();
    if (0 == status)
    {
        glDeleteShader(shader);
        GetError();
        [NSException raise:kFailedToInitialiseGLException format:@"Shader compilation failed for file %@", file];
    }
    
    return shader;
}

- (void)linkProgram:(GLuint)program
{
    glLinkProgram(program);
    GetError();
    
#if defined(DEBUG)
    GLint logLength;
    
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    GetError();
    if (logLength > 0)
    {
        GLchar *log = malloc((size_t)logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        GetError();
        NSLog(@"Shader program linking failed with error:\n%s", log);
        free(log);
    }
#endif
    
    GLint status;
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    GetError();
    if (0 == status)
    {
        [NSException raise:kFailedToInitialiseGLException format:@"Failed to link shader program"];
    }
}

- (void)validateProgram:(GLuint)program
{
    GLint logLength;
    
    glValidateProgram(program);
    GetError();
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    GetError();
    if (logLength > 0)
    {
        GLchar *log = malloc((size_t)logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        GetError();
        NSLog(@"Program validation produced errors:\n%s", log);
        free(log);
    }
    
    GLint status;
    glGetProgramiv(program, GL_VALIDATE_STATUS, &status);
    GetError();
    if (0 == status)
    {
        [NSException raise:kFailedToInitialiseGLException format:@"Failed to link shader program"];
    }
}

- (void)loadBufferData
{
    Vertex vertexData[8] = {
        { .position = Vector4Make(-0.5f,-0.5f,-0.5f, 1.0f), .colour = ColourMakeWithRGB(0.0f, 0.0f, 0.0f) },
        { .position = Vector4Make(-0.5f, 0.5f,-0.5f, 1.0f), .colour = ColourMakeWithRGB(0.0f, 1.0f, 0.0f) },
        { .position = Vector4Make( 0.5f, 0.5f,-0.5f, 1.0f), .colour = ColourMakeWithRGB(1.0f, 1.0f, 0.0f) },
        { .position = Vector4Make( 0.5f,-0.5f,-0.5f, 1.0f), .colour = ColourMakeWithRGB(1.0f, 0.0f, 0.0f) },
        { .position = Vector4Make(-0.5f,-0.5f, 0.5f, 1.0f), .colour = ColourMakeWithRGB(0.0f, 0.0f, 1.0f) },
        { .position = Vector4Make(-0.5f, 0.5f, 0.5f, 1.0f), .colour = ColourMakeWithRGB(0.0f, 1.0f, 1.0f) },
        { .position = Vector4Make( 0.5f, 0.5f, 0.5f, 1.0f), .colour = ColourMakeWithRGB(1.0f, 1.0f, 1.0f) },
        { .position = Vector4Make( 0.5f,-0.5f, 0.5f, 1.0f), .colour = ColourMakeWithRGB(1.0f, 0.0f, 1.0f) }
    };
    
    GLubyte indices[36] = {
        0,1,2, 0,2,3,
        4,6,5, 4,7,6,
        0,4,5, 0,5,1,
        1,5,6, 1,6,2,
        2,6,7, 2,7,3,
        3,7,4, 3,4,0
    };
    
    glGenVertexArrays(1, &vertexArrayObject);
    GetError();
    glBindVertexArray(vertexArrayObject);
    GetError();
    
    glGenBuffers(1, &vertexBuffer);
    GetError();
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GetError();
    glBufferData(GL_ARRAY_BUFFER, 8 * sizeof(Vertex), vertexData, GL_STATIC_DRAW);
    GetError();
    
    glGenBuffers(1, &indexBuffer);
    GetError();
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    GetError();
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 36 * sizeof(GLubyte), indices, GL_STATIC_DRAW);
    GetError();
    
    glEnableVertexAttribArray((GLuint)positionAttribute);
    GetError();
    glEnableVertexAttribArray((GLuint)colourAttribute  );
    GetError();
    glVertexAttribPointer((GLuint)positionAttribute, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, position));
    GetError();
    glVertexAttribPointer((GLuint)colourAttribute  , 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, colour  ));
    GetError();
}

- (void)renderForTime:(CVTimeStamp)time
{
    [[[self view] openGLContext] makeCurrentContext];
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    GetError();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    GetError();
    
    glUseProgram(shaderProgram);
    GetError();
    
    GLfloat timeValue = (GLfloat)(time.videoTime) / (GLfloat)(time.videoTimeScale);
    Matrix4x4 projectionMatirx = PerspectiveMatrix(45.0f, [[self view] bounds].size.width / [[self view] bounds].size.height, 0.1f, 100.0f);
    Matrix4x4 viewMatrix = TranslationMatrix(0.0f, 0.0f, -5.0f);
    Matrix4x4 modelMatrix = RotationMatrix(0.707f, 0.3f, 0.64f, timeValue);
    Matrix4x4 mvpMatrix = Matrix4x4Mult(projectionMatirx, Matrix4x4Mult(viewMatrix, modelMatrix));
    glUniformMatrix4fv(uniforms[kProjectionUniform], 1, GL_FALSE, (const GLfloat *)&mvpMatrix);
    GetError();
    
    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_BYTE, 0);
    GetError();
    
    [[[self view] openGLContext] flushBuffer];
}

- (void)dealloc
{
    glDeleteProgram(shaderProgram);
    GetError();
    glDeleteBuffers(1, &vertexBuffer);
    GetError();
    
    CVDisplayLinkStop(displayLink);
    CVDisplayLinkRelease(displayLink);
    [view release];
    
    [super dealloc];
}

@end
