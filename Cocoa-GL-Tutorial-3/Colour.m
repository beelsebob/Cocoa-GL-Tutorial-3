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
    return (Colour){.v={r, g, b, a}};
}

inline GLfloat ColourGetRed(Colour c)
{
    return c.x;
}

inline GLfloat ColourGetGreen(Colour c)
{
    return c.y;
}

inline GLfloat ColourGetBlue(Colour c)
{
    return c.z;
}

inline GLfloat ColourGetAlpha(Colour c)
{
    return c.w;
}
