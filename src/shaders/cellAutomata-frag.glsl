#version 300 es
precision highp float;

uniform sampler2D u_Texture;

uniform float u_gridSize;
uniform float u_offsetSize;
uniform float u_rangeRadius;
uniform float u_increment;
uniform float u_neighborMax;
uniform float u_neighborMin;
uniform float u_halfNearest;
uniform int u_conway;

in vec4 fs_Col;
in vec4 fs_Nor;
in vec4 fs_Pos;
in vec2 fs_UVs;


out vec4 out_Col;

void main () {

    float gridSize = u_gridSize;
    float offsetSize = u_offsetSize;
    float rangeRadius = u_rangeRadius;
    float increment = u_increment;
    float neighborMax = u_neighborMax;
    float neighborMin = u_neighborMin;
    float halfNearest = u_halfNearest;
    bool conway = u_conway == 1;


    float scale = 368.0;
    vec2 newUVs = floor(fs_UVs * gridSize) / gridSize;
    vec3 count = vec3(0.0);
    for (float i = -rangeRadius; i <= rangeRadius; i++) {
        for (float j = -rangeRadius; j <= rangeRadius; j++) {
            vec2 offset = vec2(i , j) / offsetSize;
            if (abs(i) + abs(j) < 3.0) {
                count += texture(u_Texture, newUVs + offset).rgb / halfNearest;
            } else {
                count += texture(u_Texture, newUVs + offset).rgb;
            }
        }
    }

    vec3 color = texture(u_Texture, newUVs).rgb;
    if (count.r <= neighborMax && count.r >= neighborMin || conway && abs(count.r - 4.0) < 0.5 && color.r > 0.7) {
        color += vec3(increment);
    } else {
        color -= vec3(increment);
    }

    color = clamp(color, 0.0, 1.0);

    out_Col = vec4(color, 1.0);
} 