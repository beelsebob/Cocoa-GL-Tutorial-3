//
//  Vector.h
//  Cocoa-GL-Tutorial-3
//
//  Created by Thomas Davie on 26/11/2011.
//  Copyright (c) 2011 Tom Davie. All rights reserved.
//

typedef union
{
    struct
    {
        GLfloat x, y;
    };
    GLfloat v[2];
} Vector2;

typedef union
{
    struct
    {
        GLfloat x, y, z, w;
    };
    GLfloat v[4];
} Vector4;

Vector2 Vector2Make(GLfloat x, GLfloat y);
Vector4 Vector4Make(GLfloat x, GLfloat y, GLfloat z, GLfloat w);

GLfloat Vector4GetX(Vector4 v);
GLfloat Vector4GetY(Vector4 v);
GLfloat Vector4GetZ(Vector4 v);
GLfloat Vector4GetW(Vector4 v);
