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
uniform float u_Time;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

vec3 random3(vec3 p) {
    return fract(sin(vec3(
        dot(p, vec3(127.1, 311.7, 191.999)),
        dot(p, vec3(269.5, 183.3, 569.21)),
        dot(p, vec3(420.6, 631.2, 780.2))
    )) * 43758.5453);
}

vec3 pow3D(vec3 vec, float exp) {
    return vec3(
        pow(vec.x, exp),
        pow(vec.y, exp),
        pow(vec.z, exp)
    );
}

float surflet(vec3 p, vec3 gridPoint) {
    // Compute the distance between p and the grid point along each axis, and warp it with a
    // quintic function so we can smooth our cells
    vec3 t2 = abs(p - gridPoint);
    vec3 t = vec3(1.f) - 6.f * pow3D(t2, 5.f) + 15.f * pow3D(t2, 4.f) - 10.f * pow3D(t2, 3.f);
    // Get the random vector for the grid point (assume we wrote a function random2
    // that returns a vec2 in the range [0, 1])
    vec3 gradient = random3(gridPoint) * 2. - vec3(1., 1., 1.);
    // Get the vector from the grid point to P
    vec3 diff = p - gridPoint;
    // Get the value of our height field by dotting grid->P with our gradient
    float height = dot(diff, gradient);
    // Scale our height field (i.e. reduce it) by our polynomial falloff function
    return height * t.x * t.y * t.z;
}

float perlinNoise3D(vec3 p) {
	float surfletSum = 0.f;
	// Iterate over the four integer corners surrounding uv
	for(int dx = 0; dx <= 1; ++dx) {
		for(int dy = 0; dy <= 1; ++dy) {
			for(int dz = 0; dz <= 1; ++dz) {
				surfletSum += surflet(p, floor(p) + vec3(dx, dy, dz));
			}
		}
	}
	return surfletSum;
}

void main()
{
    // Calculate the 3D Perlin noise value based on the fragment's position (fs_Pos)
    float noiseValue = perlinNoise3D(fs_Pos.xyz + u_Time * 0.08);

    // Interpolate between two colors using the noise value to modulate
    vec4 baseColor = u_Color;   // The base color passed in as uniform
    vec4 secondaryColor = vec4((1.0 - u_Color.x), (1.0 - u_Color.y), (1.0 - u_Color.z), 1.0); // Second color is complement to base color

    // Interpolate between base color and secondary color based on the noise value
    vec4 interpolatedColor = mix(u_Color, secondaryColor, min(noiseValue * 1.8, 1.0));

    // Apply basic Lambertian shading using the normal and light vector
    float diffuseTerm = dot(normalize(fs_Nor.xyz), normalize(fs_LightVec.xyz));
    float ambientTerm = 0.2;  // Ambient lighting component

    // Compute the final lighting intensity
    float lightIntensity = diffuseTerm + ambientTerm;

    // Final color output after applying noise and lighting
    out_Col = vec4(interpolatedColor.rgb * lightIntensity, interpolatedColor.a);
}
