//
//  Vector.m
//  Cocoa-GL-Tutorial-3
//
//  Created by Thomas Davie on 26/11/2011.
//  Copyright (c) 2011 Tom Davie. All rights reserved.
//

#import "Vector.h"

inline Vector2 Vector2Make(GLfloat x, GLfloat y)
{
    return (Vector2){.x=x, .y=y};
}

inline Vector4 Vector4Make(GLfloat x, GLfloat y, GLfloat z, GLfloat w)
{
    return (Vector4){.x=x,.y=y,.z=z,.w=w};
}

inline GLfloat Vector4GetX(Vector4 v)
{
    return v.x;
}

inline GLfloat Vector4GetY(Vector4 v)
{
    return v.y;
}


inline GLfloat Vector4GetZ(Vector4 v)
{
    return v.z;
}

inline GLfloat Vector4GetW(Vector4 v)
{
    return v.w;
}
