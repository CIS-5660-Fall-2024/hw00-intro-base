#version 300 es
precision highp float;

uniform vec4 u_Color;   // Base color from the application
uniform float u_Time;   // Time variable for animation

in vec4 fs_Nor;         // Interpolated normal from vertex shader
in vec4 fs_LightVec;    // Light direction vector

out vec4 out_Col;       // Final output color

// Function to generate random 3D vectors based on the input position
vec3 random3(vec3 p) {
    return fract(sin(vec3(
        dot(p, vec3(127.1, 311.7, 191.999)),
        dot(p, vec3(269.5, 183.3, 569.21)),
        dot(p, vec3(420.6, 631.2, 780.2))
    )) * 43758.5453);
}

// Function to compute the quintic smoothstep function for each component of a vec3
vec3 pow3D(vec3 vec, float exp) {
    return vec3(
        pow(vec.x, exp),
        pow(vec.y, exp),
        pow(vec.z, exp)
    );
}

// Surflet function for smooth interpolation between grid points
float surflet(vec3 p, vec3 gridPoint) {
    vec3 t2 = abs(p - gridPoint);
    vec3 t = vec3(1.0) - 6.0 * pow3D(t2, 5.0) + 15.0 * pow3D(t2, 4.0) - 10.0 * pow3D(t2, 3.0);
    
    vec3 gradient = random3(gridPoint) * 2.0 - vec3(1.0, 1.0, 1.0);
    vec3 diff = p - gridPoint;
    
    float height = dot(diff, gradient);
    return height * t.x * t.y * t.z;
}

// 3D Perlin Noise function
float perlinNoise3D(vec3 p) {
    float surfletSum = 0.0;
    for (int dx = 0; dx <= 1; ++dx) {
        for (int dy = 0; dy <= 1; ++dy) {
            for (int dz = 0; dz <= 1; ++dz) {
                surfletSum += surflet(p, floor(p) + vec3(dx, dy, dz));
            }
        }
    }
    return surfletSum;
}

// FBM function using multiple octaves of Perlin noise
float fbm(vec3 p) {
    float total = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    const int OCTAVES = 5;
    
    for (int i = 0; i < OCTAVES; i++) {
        total += perlinNoise3D(p * frequency) * amplitude;
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    
    return total;
}

void main() {
    // Get the current 3D position input for Perlin noise, add time for animation
    vec3 noiseInput = fs_Nor.xyz * 3.0 + u_Time * 0.2;

    // Apply FBM (Fractal Brownian Motion) using Perlin noise
    float noiseValue = fbm(noiseInput);

    // Modify the base color (u_Color) using the noise value
    vec3 finalColor = u_Color.rgb * (0.5 + 0.5 * noiseValue);  // Scale noise to [0, 1]

    // Lambert shading calculation
    float diffuseTerm = max(dot(normalize(fs_Nor.xyz), normalize(fs_LightVec.xyz)), 0.0);
    float ambientTerm = 0.2;  // Ambient lighting

    // Combine light intensity with color
    vec3 shadedColor = finalColor * (diffuseTerm + ambientTerm);

    // Output the final color
    out_Col = vec4(shadedColor, u_Color.a);
}
