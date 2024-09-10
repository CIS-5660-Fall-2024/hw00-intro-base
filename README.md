## Cellular Automata Shader  

I made a cellular automata shader that bases its seed off of 3D voronoi/Worley noise.  
You can see it here: https://terskayl.github.io/hw00-intro-base/  

Here is the starting state (I pixelize it for cellular automata later)  
![Screenshot 2024-09-09 083344](https://github.com/user-attachments/assets/847a6cdc-f0d3-4999-b0ea-a2b0820e0fd7)  

I have made a number of presets for interested automata settings under the Automata Presets Folder. Here is a few of them:  

![Screenshot 2024-09-09 083637](https://github.com/user-attachments/assets/1698298f-5a48-4d0d-b4b4-f1e6bfeab0fa)  
![Screenshot 2024-09-09 083655](https://github.com/user-attachments/assets/31a29a4a-43b8-4cd0-9ed1-a5d16c98095b)  
![Screenshot 2024-09-09 083715](https://github.com/user-attachments/assets/9b3c3357-9963-47dd-9057-c764a1f90153)  

You can also change the color  
![Screenshot 2024-09-09 083808](https://github.com/user-attachments/assets/764a34bd-6829-4d23-8ddb-d057f7ac56a0)  

You can also fine tune the parameters.
![Screenshot 2024-09-09 095101](https://github.com/user-attachments/assets/3d51939d-6133-413a-957b-e2a85778ea7f)
Gridsize accounts for how dense the grid of cells is  
Offset size changes how far away the shader chooses to sample neighboring pixels. It should usually just be the same as gridsize.  
Range radius is either 1 or 2 - it changes whether each cell looks at just the nearest ring of neighbors, or the two nearest rings of neighbors  
increment changes how much each cell can change each frame. It looks best at very low non-zero values (like 0.05), or 1, which would force each cell to be either black or white   
Neighbor max and neighbor min change the condition that a cell grows or shrinks. If the sum of the value of all its neighbors is between neighbor min and max, it will become more white by the increment amount.  
Half nearest and conway are specialized conditions that do not need to be touched.  
