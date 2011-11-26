//
//  Colour.m
//  Cocoa-GL-Tutorial-3
//
//  Created by Thomas Davie on 26/11/2011.
//  Copyright (c) 2011 Tom Davie. All rights reserved.
//

#import "Colour.h"

inline Colour ColourMakeWithRGB (GLfloat r, GLfloat g, GLfloat b)
{
    return ColourMakeWithRGBA(r, g, b, 1.0f);
}

inline Colour ColourMakeWithRGBA(GLfloat r, GLfloat g, GLfloat b, GLfloat a)
{
    return (Colour){.r=r, .g=g, .b=b, .a=a};
}
