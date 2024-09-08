#version 300 es
#define PI 3.1415926

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
uniform float u_Time;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Pos;
out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

void main()
{
    fs_Pos = vs_Pos;
    fs_Col = vs_Col;                     // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.
    //float k = sin(u_Time * 0.02) * 0.5 + 0.5;
    
    float thetaX = sin(u_Time * 0.001 * vs_Pos.x) * 0.04f * PI;
    float thetaY = sin(u_Time * 0.0009 * vs_Pos.y + 0.23) * 0.04f * PI;
    float thetaZ = sin(u_Time * 0.0005 * vs_Pos.y + 1.16) * 0.04f * PI;

    
    mat4 xR = mat4(
        vec4(1,0,0,0),
        vec4(0,cos(thetaX),-sin(thetaX),0),
        vec4(0,sin(thetaX),cos(thetaX),0),
        vec4(0,0,0,1));
    mat4 yR = mat4(
        vec4(cos(thetaY),0,sin(thetaY),0),
        vec4(0,1,0,0),
        vec4(-sin(thetaY),0,cos(thetaY),0),
        vec4(0,0,0,1));
    mat4 zR = mat4(
        vec4(cos(thetaZ),-sin(thetaZ),0,0),
        vec4(sin(thetaZ),cos(thetaZ),0,0),
        vec4(0,0,1,0),
        vec4(0,0,0,1));
    float xScale = sin(u_Time * 0.021) * 0.08 + 1.0;
    float yScale = sin(u_Time * 0.014) * 0.08 + 1.0;
    float zScale = sin(u_Time * 0.025 + 0.2) * 0.08 + 1.0;
    vec4 modelposition = u_Model * vs_Pos * vec4(xScale,yScale,1,1);   // Temporarily store the transformed vertex positions for use below

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * xR * yR * zR * modelposition;// gl_Position is a built-in variable of OpenGL which is
}