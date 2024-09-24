import { vec4 } from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import { gl } from '../globals';
class Cube extends Drawable {
    constructor(center) {
        super(); // Call the constructor of the super class. This is required.
        this.center = vec4.fromValues(center[0], center[1], center[2], 1);
    }
    create() {
        this.indices = new Uint32Array([
            0, 1, 2,
            0, 2, 3,
            //right side
            4, 5, 6,
            4, 6, 7,
            //back side
            8, 9, 10,
            8, 10, 11,
            //left side
            12, 13, 14,
            12, 14, 15,
            //top side
            16, 17, 18,
            16, 18, 19,
            //back side
            20, 21, 22,
            20, 22, 23,
        ]);
        this.normals = new Float32Array([
            0, 0, 1, 0,
            0, 0, 1, 0,
            0, 0, 1, 0,
            0, 0, 1, 0,
            1, 0, 0, 0,
            1, 0, 0, 0,
            1, 0, 0, 0,
            1, 0, 0, 0,
            0, 0, 1, 0,
            0, 0, 1, 0,
            0, 0, 1, 0,
            0, 0, 1, 0,
            1, 0, 0, 0,
            1, 0, 0, 0,
            1, 0, 0, 0,
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 1, 0, 0,
            0, 1, 0, 0,
            0, 1, 0, 0,
            0, 1, 0, 0,
            0, 1, 0, 0,
            0, 1, 0, 0,
            0, 1, 0, 0
        ]);
        this.positions = new Float32Array([
            // Front face 
            -1, -1, 1, 1, // Vertex 0
            -1, 1, 1, 1, // Vertex 1
            1, 1, 1, 1, // Vertex 2
            1, -1, 1, 1, // Vertex 3
            // Right face 
            1, -1, 1, 1, // Vertex 4
            1, 1, 1, 1, // Vertex 5
            1, 1, -1, 1, // Vertex 6
            1, -1, -1, 1, // Vertex 7
            // Back face 
            1, -1, -1, 1, // Vertex 8
            1, 1, -1, 1, // Vertex 9
            -1, 1, -1, 1, // Vertex 10
            -1, -1, -1, 1, // Vertex 11
            // Left face 
            -1, -1, -1, 1, // Vertex 12
            -1, 1, -1, 1, // Vertex 13
            -1, 1, 1, 1, // Vertex 14
            -1, -1, 1, 1, // Vertex 15
            // Top face 
            -1, 1, 1, 1, // Vertex 16
            -1, 1, -1, 1, // Vertex 17
            1, 1, -1, 1, // Vertex 18
            1, 1, 1, 1, // Vertex 19
            // Bottom face 
            -1, -1, 1, 1, // Vertex 20
            1, -1, 1, 1, // Vertex 21
            1, -1, -1, 1, // Vertex 22
            -1, -1, -1, 1 // Vertex 23
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
        console.log(`Created cube`);
    }
}
;
export default Cube;
//# sourceMappingURL=Cube.js.map