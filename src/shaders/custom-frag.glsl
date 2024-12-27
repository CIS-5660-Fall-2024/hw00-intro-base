#version 300 es

precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

// (Modified from my own work in CIS 5600 last semester)
const vec3 worleyGridDimensions = vec3(10, 10, 10);
const float epsilon = 0.025;

vec3 noise3D( vec3 p ) {
    return fract(sin(vec3(dot(p, vec3(127.1, 311.7, 74.7)),
                          dot(p, vec3(269.5, 183.3, 246.1)),
                          dot(p, vec3(113.5, 271.9, 124.6))
                    ))
                 * 43758.5453);
}

// Modified to return 1 if the sample point is equidistant (within epsilon) between >= 2 cells, 0 otherwise.
float WorleyNoiseBordersOnly(vec3 pos) {
    float isBorder = 0.0;
    vec3 fragGridPoint = pos * worleyGridDimensions;
    vec3 floorGridPoint = floor(fragGridPoint);
    vec3 fractGridPoint = fract(fragGridPoint);
    float minDist = 1.0; // Minimum distance initialized to max. (Can only be at most 1 cell away)
    for(int y = -1; y <= 1; ++y) {
        for(int x = -1; x <= 1; ++x) {
            for(int z = -1; z <= 1; ++z) {
                vec3 neighbor = vec3(float(x), float(y), float(z));
                vec3 worleyPoint = noise3D(floorGridPoint + neighbor);
                vec3 diff = (neighbor + worleyPoint) - fractGridPoint;
                float dist = length(diff);
                if (dist < minDist + epsilon && dist > minDist - epsilon) {
                    isBorder = 1.0;
                }
                else if (dist < minDist) {
                    isBorder = 0.0;
                    minDist = dist;
                }
            }
        }
    }

    return isBorder;
}

void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        float ambientTerm = 0.2;
        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.
        float isWorleyBorder = WorleyNoiseBordersOnly(fs_Pos.xyz);
        // Compute final shaded color
        out_Col =  vec4(diffuseColor.rgb * lightIntensity, isWorleyBorder * diffuseColor.a);
}
