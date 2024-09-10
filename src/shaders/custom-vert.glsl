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
    vec4 distortedPosition = vs_Pos; 
    distortedPosition.y += sin(vs_Pos.x * 10.0 + u_Time*0.01)*0.3;
    distortedPosition.x += sin(vs_Pos.y * 10.0 + u_Time*0.02)*0.3;
    distortedPosition = mix(vs_Pos, distortedPosition, sin(u_Time*0.001));

    fs_Col = vs_Col;                      

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);         

    vec4 modelposition = u_Model * distortedPosition; 

    fs_Pos = modelposition;

    fs_LightVec = lightPos - modelposition; 

    gl_Position = u_ViewProj * modelposition;
}
