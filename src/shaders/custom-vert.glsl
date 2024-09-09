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
out vec4 fs_Pos;        

const vec4 lightPos = vec4(5, 5, 3, 1); 


void main()
{
    fs_Col = vs_Col;    
    fs_Time = u_Time;                  

    float a = sin(u_Time * 0.005) * 3.141592 * 0.3;
    if (vs_Pos.y > 0.0) {
        a = a * -1.0;
    }
    mat4 rot = mat4(vec4(cos(a), 0, -sin(a), 0), vec4(0, 1, 0, 0), vec4(sin(a), 0, cos(a), 0), vec4(0,0,0,1));

    float tx = 1.0;
    
    vec4 pos = vs_Pos;
    // Possibly use ease function 
    pos.z = cos(u_Time * 0.01 + (vs_Pos.z * 3.141592 * 0.5)) * 0.6;
    pos.y = vs_Pos.y * (sin(u_Time * 0.01 + (vs_Pos.z * 3.141592 * 0.5)) * 0.3) + (vs_Pos.y * 0.6);
    pos.x = vs_Pos.x * (sin(u_Time * 0.01 + (vs_Pos.z * 3.141592 * 0.5)) * 0.3) + (vs_Pos.x * 0.6);

    float tz = vs_Pos.z * (cos(u_Time * 0.01));
    float ty = 1.0;
    float s = 1.0;
    mat4 magic = mat4(vec4(s, 0, 0, 0), vec4(0, s, 0, 0), vec4(0, 0, s, 0), vec4(tx, ty, tz, 1));

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);

    
    vec4 modelposition = u_Model * pos;
    fs_LightVec = lightPos - modelposition;
    fs_Pos = modelposition;
    gl_Position = u_ViewProj * modelposition;
}
