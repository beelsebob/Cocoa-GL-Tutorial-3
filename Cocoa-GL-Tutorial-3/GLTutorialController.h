//
//  GLTutorialController.h
//  GLTutorial
//
//  Created by Tom Davie on 20/02/2011.
//  Copyright 2011 Tom Davie. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreVideo/CVDisplayLink.h>
#import <OpenGL/gl3.h>

#import "Matrix.h"
#import "Vector.h"
#import "Colour.h"

#define kFailedToInitialiseGLException @"Failed to initialise OpenGL"

enum Uniforms
{
    kProjectionUniform = 0,
    kNumUniforms
};

@interface GLTutorialController : NSObject

@property (nonatomic, readwrite, retain) NSOpenGLView *view;
@property (nonatomic, readwrite, retain) IBOutlet NSWindow *window;

@end
