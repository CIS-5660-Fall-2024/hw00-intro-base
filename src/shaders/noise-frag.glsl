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

uniform float u_Time;
uniform vec4 u_Color; // The color with which to render this instance of geometry.

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

// from https://www.shadertoy.com/view/4djSRW
vec3 hashOld33( vec3 p )
{
	p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
			  dot(p,vec3(269.5,183.3,246.1)),
			  dot(p,vec3(113.5,271.9,124.6)));

	return fract(sin(p)*43758.5453123);
}

struct worleyInfo
{
    vec3 cellPos0;
    float dist0;
    vec3 cellPos1;
    float dist1;
};

worleyInfo worleyNoise3D(vec3 p, float spaceScale)
{
    // p *= spaceScale;
    p *= spaceScale * vec3(8.0, 0.5, 1.0);
    vec3 cell = floor(p);
    vec3 ufract = fract(p);

    worleyInfo info;
    info.dist0 = 1.0;
    info.dist1 = 1.0;

    for (int x = -1; x <= 1; x++)
    {
        for (int y = -1; y <= 1; y++)
        {
            for (int z = -1; z <= 1; z++)
            {
                vec3 offset = vec3(float(x), float(y), float(z)); // direction to offset
                vec3 pos = hashOld33(cell + offset); // centerpoint of voronoi cell

                // oscillate the centerpoint left and right based off time and cell position
                pos.x += 0.5 * sin(u_Time * 10.0 + cell.x);

                // distance between fragment 
                vec3 diff = offset + pos - ufract;
                float dist = length(diff);

                if (dist < info.dist0)
                {
                    info.dist1 = info.dist0;
                    info.dist0 = dist;
                    info.cellPos1 = info.cellPos0;
                    info.cellPos0 = pos;
                }
                else if (dist < info.dist1)
                {
                    info.dist1 = dist;
                    info.cellPos1 = pos;
                }

                // minDist = min(minDist, dist);
            }
        }
    }

    return info;
}

const float dither[16] = float[]
(
1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
);

void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // // Compute final shaded color
        // out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);

        vec3 pos = fs_Pos.xyz;
        // pos += vec3(0.0, cos(pos.y) + u_Time, sin(pos.z) + u_Time);
        pos += vec3(0.0, cos(pos.y) + u_Time, 0.0);

        worleyInfo info = worleyNoise3D(pos, 10.0);
    
        // bad approximation
        float distanceToEdge = info.dist1 - info.dist0;

        // float distanceToEdge = dot(0.5*(info.cellPos0+info.cellPos1),normalize(info.cellPos1-info.cellPos0));
        distanceToEdge = 1.0 - smoothstep(0.0, 0.06, distanceToEdge);

        float nearestDist = info.dist0;
        // create sharp edges
        nearestDist = smoothstep(0.5, 0.6, nearestDist);

        // gradient map to blue
        vec3 darkBlue = vec3(0, 105, 170) / 255.0;
        vec3 lightBlue = vec3(0, 205, 249) / 255.0;

        vec3 color = mix(lightBlue, darkBlue, nearestDist);
        
        // if (dist < dither[int(gl_FragCoord.x) % 16 + int(gl_FragCoord.y) % 16 * 4])
            // discard;

        // out_Col = vec4(vec3(distanceToEdge), 1.0);

        // use distance to edge to draw outline

        vec3 emissive = vec3(distanceToEdge);
        vec3 waterColor = color + emissive;

        out_Col = vec4(waterColor, 1.0);
}
