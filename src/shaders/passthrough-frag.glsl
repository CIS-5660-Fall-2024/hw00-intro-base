#version 300 es
precision highp float;

uniform sampler2D u_Texture;
uniform vec4 u_Color;

in vec4 fs_Col;
in vec4 fs_Nor;
in vec4 fs_Pos;
in vec2 fs_UVs;

out vec4 out_Col;

void main () {
    out_Col = vec4(texture(u_Texture, fs_UVs).rgb * u_Color.rgb, 1.0);
} 