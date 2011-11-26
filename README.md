# Cocoa GL Tutorial Part 3

This tutorial builds on my first and second OpenGL tutorial and explains a common model for dealing with 3D.  This time, only a tiny amount of the added code is specific to Cocoa, so if you're learning OpenGL, just dive right in.  The code is of course Objective-C, but I'm sure you can cope.

## Indexed Vertex Data

In the previous two tutorials we have dealt with only a single quad drawn to the screen.  To show off our 3D effect better here, we're going to use a cube instead.  The cube is made up of several quads, each of which shares some vertices with the other quads.  To make this nice and efficient we don't want to provide the same vertices to OpenGL over and over as we ask it to draw them.  Instead, we want to provide the vertex data once, and then index into it when we draw.  To do this, we first need to set up our index data in OpenGL's element array buffer:

     GLubyte indices[36] = {
         0,1,2, 0,2,3,
         4,6,5, 4,7,6,
         0,4,5, 0,5,1,
         1,5,6, 1,6,2,
         2,6,7, 2,7,3,
         3,7,4, 3,4,0
     };
    
     glGenBuffers(1, &indexBuffer);
     GetError();
     glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
     GetError();
     glBufferData(GL_ELEMENT_ARRAY_BUFFER, 36 * sizeof(GLubyte), indices, GL_STATIC_DRAW);
     GetError();

We use this later when we draw.  Notice in the code that our call to glDrawArrays has been replaced with a call to glDrawElements.  This asks OpenGL to draw the elements specified in the element array buffer.  In this case we can see from the data above that we ask OpenGL to make a triangle out of the 0th, 1st and 2nd vertex; then another out of the 0th, 2nd and 3rd vertex, etc.

     glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_BYTE, 0);
     GetError();

## 3D Projection

In order to render our cube in 3D we need to simulate the perspective effect we see in the real world.  This is done by setting up a 4x4 projection matrix to perform a perspective projection:

     Matrix4x4 projectionMatirx = PerspectiveMatrix(45.0f, [[self view] bounds].size.width / [[self view] bounds].size.height, 0.1f, 100.0f);

We won't go into how a perspective matrix is constructed in this tutorial and why it works.  To fully understand that I highly recommend that you get yourself a good book on linear algebra, or watch the various free lectures on iTunes U.  For the moment, all you need to understand is that a matrix can be used as a representation for a conversion from one coordinate space to another.  In this case, it represents conversion from "view" space - i.e. the position of vertices in front of the camera, to "clip" space - a cube from -1 to 1 on each axis which OpenGL maps to the screen.

We also set up two other matrices, which also represent coordinate space transforms:

     Matrix4x4 viewMatrix = TranslationMatrix(0.0f, 0.0f, -5.0f);
     Matrix4x4 modelMatrix = RotationMatrix(0.707f, 0.3f, 0.64f, timeValue);

The view matrix we use to convert from "world" space - i.e. the position of vertices in the world, to "view" space.  The model matrix we use to convert from "model" space - i.e. the position of vertices relative to the model's origin, to "world" space.

Finally, we want to combine all these coordinate space transforms, so that we end up with one single transform that takes us all the way from the position of the vertices in the model, to clip space.  We do this by multiplying the various transformation matrices together:

     Matrix4x4 mvpMatrix = Matrix4x4Mult(projectionMatirx, Matrix4x4Mult(viewMatrix, modelMatrix));

Finally, this "model/view/projection" matrix is uploaded to our shader in a uniform:

     glUniformMatrix4fv(uniforms[kProjectionUniform], 1, GL_FALSE, (const GLfloat *)&mvpMatrix);

In our vertex shader, we use this matrix to transform each vertex that comes through.  We apply the transformation simply by pre-multiplying the vertex:


     uniform mat4 mvp;
     ...
         gl_Position = mvp * position;

## Depth Testing

OpenGL draws primitives in the order that you give them.  This means that any later drawing will draw over the top of earlier drawing.  When drawing in 3D this typically is not what we want to happen, instead, we want objects near to the camera to be drawn on top of objects further away from the camera.

To achieve this, we use OpenGL's depth buffer.  To use this, we first need to request that we get a depth buffer when we create our OpenGL context:

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

This buffer holds the depth of the currently drawn fragment for each pixel.  We then use OpenGL's depth function to only render new fragments who's depth vale is less than the existing one:

     glEnable(GL_DEPTH_TEST);
     glDepthFunc(GL_LESS);

