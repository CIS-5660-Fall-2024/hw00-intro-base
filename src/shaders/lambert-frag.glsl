#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;
in vec2 fs_UVs;


out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

//float noise(vec3 pos) {
//    return fract(dot(vec3(sin(pos.x * 375835.30542), sin(pos.y * 2466964.3245), sin(pos.z * 954925.34)), vec3(2405.34556, 4306302.466, -604672.345)));
//} 
float noise( vec3 p ) {
    return normalize(fract(sin(vec3(
                                         dot(p, vec3(127.1, 311.7, 74.7)),
                                         dot(p, vec3(269.5, 183.3, 246.1)),
                                         dot(p, vec3(419.2, 371.9, 156.3))
                                         )) * 43758.5453f) * 2.f - vec3(1.f, 1.f, 1.f)).x;
}

float voronoi(vec3 pos, float density) {
    vec3 coords = floor(pos * density);
    float minDist = 100.0;
    for (float i = -2.f; i <= 2.f; i++) {
        for (float j = -2.f; j <= 2.f; j++) {
            for (float k = -2.f; k <= 2.f; k++) {
                vec3 octantCoords = coords + vec3(i, j, k);
                vec3 offset = vec3(noise(octantCoords), noise(octantCoords + vec3(234.43)), noise(octantCoords + vec3(54.204)));
                
                //vec3 point = octantOffset + offset - fract(fs_Pos * scale);
                vec3 octantCenter = octantCoords + offset; 
                minDist = min(minDist, length(pos * density - octantCenter));
            }
        }
    }
    return minDist;
}

void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);
        if (diffuseTerm < 0.f) {
            diffuseTerm = 0.f;
        } 

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color
        float factor = length(fs_Pos - floor(fs_Pos * 100.0)/ 100.0);
        factor = 1.0 - factor * 5.0;
        out_Col = vec4(vec3(voronoi(fs_Pos.rgb, 5.f)), 1.f); // vec4(u_Color.rgb*diffuseTerm, u_Color.a);
}

