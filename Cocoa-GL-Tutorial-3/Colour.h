//
//  Colour.h
//  Cocoa-GL-Tutorial-3
//
//  Created by Thomas Davie on 26/11/2011.
//  Copyright (c) 2011 Tom Davie. All rights reserved.
//

typedef struct
{
    GLfloat r,g,b,a;
} Colour;

Colour ColourMakeWithRGB (GLfloat r, GLfloat g, GLfloat b);
Colour ColourMakeWithRGBA(GLfloat r, GLfloat g, GLfloat b, GLfloat a);
