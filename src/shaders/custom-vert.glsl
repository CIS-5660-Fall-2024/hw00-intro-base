#version 300 es
uniform mat4 u_Model;       
uniform mat4 u_ModelInvTr;  
uniform mat4 u_ViewProj;    
uniform float u_Time;

in vec4 vs_Pos;             
in vec4 vs_Nor;             
in vec4 vs_Col;             

out vec4 fs_Nor;            
out vec4 fs_LightVec;       
out vec4 fs_Col;  
out float fs_Time;          

const vec4 lightPos = vec4(5, 5, 3, 1); 


void main()
{
    fs_Col = vs_Col;    
    fs_Time = u_Time;                     
    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);
    float a = sin(u_Time * 0.005) * 3.141592 * 0.4;
    if (vs_Pos.y > 0.0) {
        a = a * -1.0;
    }
    mat4 rot = mat4(vec4(cos(a), 0, -sin(a), 0), vec4(0, 1, 0, 0), vec4(sin(a), 0, cos(a), 0), vec4(0,0,0,1));

    vec4 modelposition = u_Model * vs_Pos;
    fs_LightVec = lightPos - modelposition;

    gl_Position = u_ViewProj * rot * modelposition;
}
