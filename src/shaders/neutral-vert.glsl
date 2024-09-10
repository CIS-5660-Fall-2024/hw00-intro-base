#version 300 es

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform float u_Time;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

in vec2 vs_UVs;

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Pos;
out vec2 fs_UVs;

void main() {

    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.


    int count = 0;
    if (vs_Pos.x > 0.0) {
        count++;
    }
    if (vs_Pos.y > 0.0) {
        count++;
    }
    if (vs_Pos.z > 0.0) {
        count++;
    }

    vec4 newPos = vs_Pos;
    if (count % 2 == 0) {
        newPos += 0.05*vec4(sin(u_Time / 20.), cos(u_Time / 20.), sin(u_Time / 20.), 0);
    } else {
        newPos += 0.05*vec4(cos(u_Time / 20.), sin(u_Time / 20.), cos(u_Time / 20.), 0);
    }

    vec4 modelposition = u_Model * newPos;   // Temporarily store the transformed vertex positions for use below

    fs_Pos = modelposition;
    fs_UVs = vs_UVs; //vec2(0.5) + 0.5*vs_Pos.xy;

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices

}