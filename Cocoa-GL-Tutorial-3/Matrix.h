//
//  Matrix.h
//  GLTutorial
//
//  Created by Tom Davie on 26/11/2011.
//  Copyright 2011 Tom Davie. All rights reserved.
//

#import <OpenGL/gl3.h>

#import "Vector.h"

typedef union
{
    GLfloat values[16];
    Vector4 columns[4];
} Matrix4x4;

Matrix4x4 IdentityMatrix4x4(void);
Matrix4x4 Matrix4x4Make(GLfloat m11, GLfloat m21, GLfloat m31, GLfloat m41,
                        GLfloat m12, GLfloat m22, GLfloat m32, GLfloat m42,
                        GLfloat m13, GLfloat m23, GLfloat m33, GLfloat m43,
                        GLfloat m14, GLfloat m24, GLfloat m34, GLfloat m44);
BOOL Matrix4x4Equal(Matrix4x4 a, Matrix4x4 b);

void Matrix4x4SetColumn(Matrix4x4 *m, short idx, Vector4 c);
Vector4 Matrix4x4GetColumn(Matrix4x4 m, short idx);

Matrix4x4 TranslationMatrix(GLfloat x, GLfloat y, GLfloat z);
Matrix4x4 ScaleMatrix(GLfloat x, GLfloat y, GLfloat z);
Matrix4x4 RotationMatrix(GLfloat x, GLfloat y, GLfloat z, GLfloat alpha);

Matrix4x4 TranslationMatrixVec4(Vector4 v);
Matrix4x4 ScaleMatrixVec4      (Vector4 v);
Matrix4x4 RotationMatrixVec4   (Vector4 v);

Matrix4x4 OrthographicMatrix(GLfloat l, GLfloat r, GLfloat b, GLfloat t, GLfloat f, GLfloat n);
Matrix4x4 PerspectiveMatrix (GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar);

Matrix4x4 Matrix4x4Mult(Matrix4x4 a, Matrix4x4 b);
Vector4 Matrix4x4MultVec4(Matrix4x4 m, Vector4 v);
