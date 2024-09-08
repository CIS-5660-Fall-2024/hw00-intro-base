#version 300 es
#define N_OCTAVES 8

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
uniform float u_Time; 

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

float CosineInterpolate(float a, float b, float x)
{
    float ft = x * 3.1415927;
    float f = (1.f - cos(ft)) * 0.5f;
    return  a * (1.f - f) + b * f;
}

float Noise3(int x, int y, int z) {
    return fract(sin(dot(vec3(x, y, z), vec3(127.1, 269.5, 631.2))) * 43758.5453);
}

float SmoothedNoise3d(int x, int y, int z) {
    float corners = (Noise3(x - 1, y - 1, z - 1) + Noise3(x + 1, y - 1, z - 1) + Noise3(x - 1, y + 1, z - 1) + Noise3(x + 1, y + 1, z - 1) +
                     Noise3(x - 1, y - 1, z + 1) + Noise3(x + 1, y - 1, z + 1) + Noise3(x - 1, y + 1, z + 1) + Noise3(x + 1, y + 1, z + 1)) / 64.f;
    float sides = (Noise3(x - 1, y, z - 1) + Noise3(x + 1, y, z - 1) + Noise3(x, y - 1, z - 1) + Noise3(x, y + 1, z - 1) +
                   Noise3(x - 1, y, z + 1) + Noise3(x + 1, y, z + 1) + Noise3(x, y - 1, z + 1) + Noise3(x, y + 1, z + 1) +
                   Noise3(x - 1, y - 1, z) + Noise3(x + 1, y - 1, z) + Noise3(x - 1, y + 1, z) + Noise3(x + 1, y + 1, z)) / 32.f;
    float center = (Noise3(x, y, z - 1) + Noise3(x, y, z + 1) + Noise3(x - 1, y, z) + Noise3(x + 1, y, z) + Noise3(x, y - 1, z) + Noise3(x, y + 1, z)) / 16.f;
    float middle = Noise3(x, y, z) / 8.f;
    return corners + sides + center + middle;
}

float InterpolatedNoise3d(float x, float y, float z)
{
    int integerX = int(x);
    float fractionalX = fract(x);

    int integerY = int(y);
    float fractionalY = fract(y);

    int integerZ = int(z);
    float fractionalZ = fract(z);

    float v1 = SmoothedNoise3d(integerX, integerY, integerZ);
    float v2 = SmoothedNoise3d(integerX + 1, integerY, integerZ);
    float v3 = SmoothedNoise3d(integerX, integerY + 1, integerZ);
    float v4 = SmoothedNoise3d(integerX + 1, integerY + 1, integerZ);
    float v5 = SmoothedNoise3d(integerX, integerY, integerZ + 1);
    float v6 = SmoothedNoise3d(integerX + 1, integerY, integerZ + 1);
    float v7 = SmoothedNoise3d(integerX, integerY + 1, integerZ + 1);
    float v8 = SmoothedNoise3d(integerX + 1, integerY + 1, integerZ + 1);

    float i1 = CosineInterpolate(v1, v2, fractionalX);
    float i2 = CosineInterpolate(v3, v4, fractionalX);
    float i3 = CosineInterpolate(v5, v6, fractionalX);
    float i4 = CosineInterpolate(v7, v8, fractionalX);
    float i5 = CosineInterpolate(i1, i2, fractionalY);
    float i6 = CosineInterpolate(i3, i4, fractionalY);

    return CosineInterpolate(i5, i6, fractionalZ);
}

float PerlinNoise3d(float x, float y, float z)
{
    float total = 0.f;
    float persistance = 0.6f;
    for (int i = 1; i <= N_OCTAVES; i++) {
        float frequency = pow(1.2f, float(i));
        float amplitutde = pow(persistance, float(i));

        total += InterpolatedNoise3d(x * frequency, y * frequency, z * frequency) * amplitutde;
    }
    return total;
}

void main()
{
    // Material base color (before shading)
    //vec4 diffuseColor = u_Color;

    // Calculate the diffuse term for Lambert shading
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    // Avoid negative lighting values
    diffuseTerm = clamp(diffuseTerm, 0.f, 1.f);
    float ambientTerm = 0.4f;

    float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                        //to simulate ambient lighting. This ensures that faces that are not
                                                        //lit by our point light are not completely black.

    // Compute final shaded color
    //out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);

    vec3 a = u_Color.xyz;
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    const vec3 d = vec3(0.00, 0.33, 0.67);
    vec3 pos = fs_Pos.xyz * 14.f + 1.75f * (sin(0.004f * float(u_Time)));
    float noiseValue = PerlinNoise3d(pos.x, pos.y, pos.z);
    noiseValue = clamp(noiseValue, 0.f, 1.f);
    vec3 diffuseColor = a + b * cos(2.f * 3.1415926 * (c * noiseValue + d));
    out_Col = vec4(diffuseColor * lightIntensity, 1.f);
}