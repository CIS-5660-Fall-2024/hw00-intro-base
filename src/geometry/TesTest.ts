import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class TesCube extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  center: vec4;
  size: number;

  constructor(center: vec3, size: number) {
    super();
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
    this.size = size * 0.5;
  }

  create() {
    // triangle indeices
    this.indices = new Uint32Array([
      // Outer cube faces (similar to the cube you have)
      0, 1, 2, 0, 2, 3,    // front
      4, 5, 6, 4, 6, 7,    // top
      8, 9, 10, 8, 10, 11, // right
      12, 13, 14, 12, 14, 15, // left
      16, 17, 18, 16, 18, 19, // bottom
      20, 21, 22, 20, 22, 23, // back
  
      // Inner cube faces (inverted to form the hole)
      24, 25, 26, 24, 26, 27,    // front inner face
      28, 29, 30, 28, 30, 31,    // top inner face
      32, 33, 34, 32, 34, 35,    // right inner face
      36, 37, 38, 36, 38, 39,    // left inner face
      40, 41, 42, 40, 42, 43,    // bottom inner face
      44, 45, 46, 44, 46, 47     // back inner face
    ]);
  

    // face normals                               
    this.normals = new Float32Array([
      // Outer normals (same as your original cube)
      0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, // front
      0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, // top
      1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, // right
      -1, 0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0, // left
      0, -1, 0, 0, -1, 0, 0, -1, 0, 0, -1, 0, // bottom
      0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0, -1, // back
  
      // Inner normals (opposite direction to point inward)
      0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0, -1, // front inner face
      0, -1, 0, 0, -1, 0, 0, -1, 0, 0, -1, 0, // top inner face
      -1, 0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0, // right inner face
      1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0,    // left inner face
      0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0,    // bottom inner face
      0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1     // back inner face
    ]);
  
    
    // vertex positions, yeah yeah i know it looks ugly but...    
    let outerSize = 1.0;  
    let innerSize = 0.4;                            
    this.positions = new Float32Array([
      // Outer cube vertices
      -outerSize, -outerSize, outerSize, 1,   // front
      outerSize, -outerSize, outerSize, 1,
      outerSize, outerSize, outerSize, 1,
      -outerSize, outerSize, outerSize, 1,
  
      -outerSize, outerSize, outerSize, 1,   // top
      outerSize, outerSize, outerSize, 1,
      outerSize, outerSize, -outerSize, 1,
      -outerSize, outerSize, -outerSize, 1,
  
      outerSize, -outerSize, outerSize, 1,   // right
      outerSize, -outerSize, -outerSize, 1,
      outerSize, outerSize, -outerSize, 1,
      outerSize, outerSize, outerSize, 1,
  
      -outerSize, -outerSize, outerSize, 1,  // left
      -outerSize, -outerSize, -outerSize, 1,
      -outerSize, outerSize, -outerSize, 1,
      -outerSize, outerSize, outerSize, 1,
  
      -outerSize, -outerSize, outerSize, 1,  // bottom
      outerSize, -outerSize, outerSize, 1,
      outerSize, -outerSize, -outerSize, 1,
      -outerSize, -outerSize, -outerSize, 1,
  
      -outerSize, -outerSize, -outerSize, 1, // back
      outerSize, -outerSize, -outerSize, 1,
      outerSize, outerSize, -outerSize, 1,
      -outerSize, outerSize, -outerSize, 1,
  
      // Inner cube (subtracted from the outer cube)
      -innerSize, -innerSize, innerSize, 1,  // front inner face
      innerSize, -innerSize, innerSize, 1,
      innerSize, innerSize, innerSize, 1,
      -innerSize, innerSize, innerSize, 1,
  
      -innerSize, innerSize, innerSize, 1,   // top inner face
      innerSize, innerSize, innerSize, 1,
      innerSize, innerSize, -innerSize, 1,
      -innerSize, innerSize, -innerSize, 1,
  
      innerSize, -innerSize, innerSize, 1,   // right inner face
      innerSize, -innerSize, -innerSize, 1,
      innerSize, innerSize, -innerSize, 1,
      innerSize, innerSize, innerSize, 1,
  
      -innerSize, -innerSize, innerSize, 1,  // left inner face
      -innerSize, -innerSize, -innerSize, 1,
      -innerSize, innerSize, -innerSize, 1,
      -innerSize, innerSize, innerSize, 1,
  
      -innerSize, -innerSize, innerSize, 1,  // bottom inner face
      innerSize, -innerSize, innerSize, 1,
      innerSize, -innerSize, -innerSize, 1,
      -innerSize, -innerSize, -innerSize, 1,
  
      -innerSize, -innerSize, -innerSize, 1, // back inner face
      innerSize, -innerSize, -innerSize, 1,
      innerSize, innerSize, -innerSize, 1,
      -innerSize, innerSize, -innerSize, 1
    ]);
  
  
                                      

    this.generateIdx();
    this.generatePos();
    this.generateNor();                                    

    this.count = this.indices.length;
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
    gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
    gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW);

    console.log(`Created TesCube :)`);
  }
};

export default TesCube;
