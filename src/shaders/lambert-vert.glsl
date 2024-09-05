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
out vec4 fs_Pos; 

const vec4 lightPos = vec4(5, 5, 3, 1);
                                        

void main()
{
    fs_Col = vs_Col;                        

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          

    vec4 modPos = vs_Pos;
    modPos.y += sin(u_Time + vs_Pos.x) * 0.5;
    vec4 modelposition = u_Model * modPos; 

    fs_LightVec = lightPos - modelposition;
    fs_Pos = u_Model * vs_Pos; 
    gl_Position = u_ViewProj * modelposition;
}
