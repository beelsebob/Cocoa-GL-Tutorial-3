//
//  Matrix.h
//  GLTutorial
//
//  Created by Tom Davie on 26/11/2011.
//  Copyright 2011 Tom Davie. All rights reserved.
//

#import "Matrix.h"

inline Matrix4x4 IdentityMatrix4x4(void)
{
    return Matrix4x4Make(1.0f, 0.0f, 0.0f, 0.0f,
                         0.0f, 1.0f, 0.0f, 0.0f,
                         0.0f, 0.0f, 1.0f, 0.0f,
                         0.0f, 0.0f, 0.0f, 1.0f);
}

inline Matrix4x4 Matrix4x4Make(GLfloat m11, GLfloat m21, GLfloat m31, GLfloat m41,
                               GLfloat m12, GLfloat m22, GLfloat m32, GLfloat m42,
                               GLfloat m13, GLfloat m23, GLfloat m33, GLfloat m43,
                               GLfloat m14, GLfloat m24, GLfloat m34, GLfloat m44)
{
    return (Matrix4x4){.values={m11,m12,m13,m14,
                                m21,m22,m23,m24,
                                m31,m32,m33,m34,
                                m41,m42,m43,m44}};
}

BOOL Matrix4x4Equal(Matrix4x4 a, Matrix4x4 b)
{
    BOOL equal = YES;
    
    for (int i = 0; i < 16 && equal; i++)
    {
        equal = a.values[i] == b.values[i];
    }
    
    return equal;
}

inline Matrix4x4 TranslationMatrix(GLfloat x, GLfloat y, GLfloat z)
{
    return TranslationMatrixVec4(Vector4Make(x, y, z, 1.0f));
}

inline Matrix4x4 ScaleMatrix(GLfloat x, GLfloat y, GLfloat z)
{
    return ScaleMatrixVec4(Vector4Make(x, y, z, 1.0f));
}

inline Matrix4x4 RotationMatrix(GLfloat x, GLfloat y, GLfloat z, GLfloat alpha)
{
    return RotationMatrixVec4(Vector4Make(x, y, z, alpha));
}

inline Matrix4x4 TranslationMatrixVec4(Vector4 v)
{
    Matrix4x4 m = IdentityMatrix4x4();
    Matrix4x4SetColumn(&m, 3, v);
    return m;
}

inline Matrix4x4 ScaleMatrixVec4(Vector4 v)
{
    return Matrix4x4Make(Vector4GetX(v), 0.0f          , 0.0f          , 0.0f,
                         0.0f          , Vector4GetY(v), 0.0f          , 0.0f,
                         0.0f          , 0.0f          , Vector4GetZ(v), 0.0f,
                         0.0f          , 0.0f          , 0.0f          , Vector4GetW(v));
}

inline Matrix4x4 RotationMatrixVec4(Vector4 v)
{
    GLfloat x = Vector4GetX(v);
    GLfloat y = Vector4GetY(v);
    GLfloat z = Vector4GetZ(v);
    GLfloat alpha = Vector4GetW(v);
    
    GLfloat xsq = x * x;
    GLfloat ysq = y * y;
    GLfloat zsq = z * z;
    GLfloat c = cosf(alpha);
    GLfloat s = sinf(alpha);
    
    return Matrix4x4Make(xsq + (1 - xsq) * c    , x * y * (1 - c) - z * s, x * z * (1 - c) + y * s, 0.0f,
                         x * y * (1 - c) + z * s, ysq + (1 - ysq) * c    , y * z * (1 - c) - x * s, 0.0f,
                         x * z * (1 - c) - y * s, y * z * (1 - c) + x * s, zsq + (1 - zsq) * c    , 0.0f,
                         0.0f                   , 0.0f                   , 0.0f                   , 1.0f);
}

inline void Matrix4x4SetColumn (Matrix4x4 *m, short idx, Vector4 c)
{
    assert(0 <= idx && 3 >= idx);
    m->columns[idx] = c;
}

inline Vector4 Matrix4x4GetColumn (Matrix4x4 m, short idx)
{
    assert(0 <= idx && 3 >= idx);
    return m.columns[idx];
}

inline Matrix4x4 OrthographicMatrix(GLfloat l, GLfloat r, GLfloat b, GLfloat t, GLfloat f, GLfloat n)
{
    return Matrix4x4Make(2.0f / (r - l), 0.0f          , 0.0f           , -(r + l) / (r - l),
                         0.0f          , 2.0f / (t - b), 0.0f           , -(t + b) / (t - b),
                         0.0f          , 0.0f          , -2.0f / (f - n), -(f + n) / (f - n),
                         0.0f          , 0.0f          , 0.0f           , 1.0f              );
}

inline Matrix4x4 PerspectiveMatrix(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar)
{
    const GLfloat h = 1.0f / tanf(fovy * M_PI / 360.0f);
    float invNegDepth = 1.0f / (zNear - zFar);
    
    return Matrix4x4Make(h / aspect, 0.0f, 0.0f                        , 0.0f                             ,
                         0.0f      , h   , 0.0f                        , 0.0f                             ,
                         0.0f      , 0.0f, (zFar + zNear) * invNegDepth, 2.0f * zNear * zFar * invNegDepth,
                         0.0f      , 0.0f,-1.0f                        , 0.0f                             );
}

Matrix4x4 Matrix4x4Mult(Matrix4x4 a, Matrix4x4 b)
{
    Matrix4x4 r;
    r.values[ 0] = a.values[ 0] * b.values[ 0] + a.values[ 4] * b.values[ 1] + a.values[ 8] * b.values[ 2] + a.values[12] * b.values[ 3];
    r.values[ 1] = a.values[ 1] * b.values[ 0] + a.values[ 5] * b.values[ 1] + a.values[ 9] * b.values[ 2] + a.values[13] * b.values[ 3];
    r.values[ 2] = a.values[ 2] * b.values[ 0] + a.values[ 6] * b.values[ 1] + a.values[10] * b.values[ 2] + a.values[14] * b.values[ 3];
    r.values[ 3] = a.values[ 3] * b.values[ 0] + a.values[ 7] * b.values[ 1] + a.values[11] * b.values[ 2] + a.values[15] * b.values[ 3];
    
    r.values[ 4] = a.values[ 0] * b.values[ 4] + a.values[ 4] * b.values[ 5] + a.values[ 8] * b.values[ 6] + a.values[12] * b.values[ 7];
    r.values[ 5] = a.values[ 1] * b.values[ 4] + a.values[ 5] * b.values[ 5] + a.values[ 9] * b.values[ 6] + a.values[13] * b.values[ 7];
    r.values[ 6] = a.values[ 2] * b.values[ 4] + a.values[ 6] * b.values[ 5] + a.values[10] * b.values[ 6] + a.values[14] * b.values[ 7];
    r.values[ 7] = a.values[ 3] * b.values[ 4] + a.values[ 7] * b.values[ 5] + a.values[11] * b.values[ 6] + a.values[15] * b.values[ 7];
    
    r.values[ 8] = a.values[ 0] * b.values[ 8] + a.values[ 4] * b.values[ 9] + a.values[ 8] * b.values[10] + a.values[12] * b.values[11];
    r.values[ 9] = a.values[ 1] * b.values[ 8] + a.values[ 5] * b.values[ 9] + a.values[ 9] * b.values[10] + a.values[13] * b.values[11];
    r.values[10] = a.values[ 2] * b.values[ 8] + a.values[ 6] * b.values[ 9] + a.values[10] * b.values[10] + a.values[14] * b.values[11];
    r.values[11] = a.values[ 3] * b.values[ 8] + a.values[ 7] * b.values[ 9] + a.values[11] * b.values[10] + a.values[15] * b.values[11];
    
    r.values[12] = a.values[ 0] * b.values[12] + a.values[ 4] * b.values[13] + a.values[ 8] * b.values[14] + a.values[12] * b.values[15];
    r.values[13] = a.values[ 1] * b.values[12] + a.values[ 5] * b.values[13] + a.values[ 9] * b.values[14] + a.values[13] * b.values[15];
    r.values[14] = a.values[ 2] * b.values[12] + a.values[ 6] * b.values[13] + a.values[10] * b.values[14] + a.values[14] * b.values[15];
    r.values[15] = a.values[ 3] * b.values[12] + a.values[ 7] * b.values[13] + a.values[11] * b.values[14] + a.values[15] * b.values[15];
    return r;
}

Vector4 Matrix4x4MultVec4(Matrix4x4 m, Vector4 v)
{
    return Vector4Make(m.values[0] * Vector4GetX(v) + m.values[4] * Vector4GetY(v) + m.values[ 8] * Vector4GetZ(v) + m.values[12] * Vector4GetW(v),
                       m.values[1] * Vector4GetX(v) + m.values[5] * Vector4GetY(v) + m.values[ 9] * Vector4GetZ(v) + m.values[13] * Vector4GetW(v),
                       m.values[2] * Vector4GetX(v) + m.values[6] * Vector4GetY(v) + m.values[10] * Vector4GetZ(v) + m.values[14] * Vector4GetW(v),
                       m.values[3] * Vector4GetX(v) + m.values[7] * Vector4GetY(v) + m.values[11] * Vector4GetZ(v) + m.values[15] * Vector4GetW(v));
}
