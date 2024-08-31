#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Pos;
out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out float fs_Time;

const vec4 lightPos = vec4(-5, 5, -3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

uniform float u_Time;
uniform bool u_Outline;
out float fs_Outline;

// from https://www.shadertoy.com/view/4djSRW
vec3 hashOld33( vec3 p )
{
	p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
			  dot(p,vec3(269.5,183.3,246.1)),
			  dot(p,vec3(113.5,271.9,124.6)));

	return fract(sin(p)*43758.5453123);
}

float surflet(vec3 p, vec3 gridPoint)
{
    vec3 t2 = abs(p - gridPoint);
    vec3 pow3 = t2 * t2 * t2;
    vec3 pow4 = pow3 * t2;
    vec3 pow5 = pow4 * t2;
    vec3 t = vec3(1.0) - 6.0 * pow5 + 15.0 * pow4 - 10.0 * pow3;
    vec3 gradient = hashOld33(gridPoint) * 2. - vec3(1.0, 1.0, 1.0);
    vec3 diff = p - gridPoint;
    float height = dot(diff, gradient);
    return height * t.x * t.y * t.z;
    return 0.0;
}

float perlinNoise3D(vec3 p) 
{
	float surfletSum = 0.0;
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
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation
    fs_Pos = vs_Pos;
    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.
    fs_Time = u_Time;
    fs_Outline = u_Outline ? 1.0 : 0.0;

    vec4 modelposition = u_Model * vs_Pos;   // Temporarily store the transformed vertex positions for use below

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    vec4 position = u_ViewProj * modelposition;
    if (u_Outline) 
    {
        float pn = perlinNoise3D(position.xyz + vec3(127.1, 311.7, 715.2) * u_Time * 0.004);
        vec3 noise = normalize(vs_Nor.xyz) * 0.4 * abs(pn);
        position.xyz += noise;
    }

    gl_Position = position;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}
