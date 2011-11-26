#version 150

uniform mat4 mvp;

in vec4 position;
in vec4 colour;

out vec4 colourV;

void main (void)
{
    colourV     = colour;
    gl_Position = mvp * position;
}
