import { vec3, vec4 } from "gl-matrix";
import Drawable from "../rendering/gl/Drawable";
import {gl} from '../globals';


class Cube extends Drawable {
    indices: Uint32Array;
    positions: Float32Array;
    normals: Float32Array;
    center: vec4;

    constructor(center: vec3) {
        super();
        this.center = vec4.fromValues(center[0], center[1], center[2], 1);
    }

    create() {


        this.generateIdx();
        this.generatePos();
        this.generateNor();

        this.indices = this.createCubeIndices();
        this.normals = this.createCubeVertexNormals();
        this.positions = this.createCubeVertexPositions(vec3.fromValues(this.center[0], this.center[1], this.center[2]));

        this.count = this.indices.length;
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW);

        gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
        gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW);

        gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
        gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW);

        console.log('Created cube');
    }

    createCubeVertexPositions(center: vec3): Float32Array {
        let positions = [];
        let offset = 0.5;
        let x = center[0];
        let y = center[1];
        let z = center[2];

        // Front face
        positions.push(x - offset, y - offset, z + offset, 1.0);
        positions.push(x + offset, y - offset, z + offset, 1.0);
        positions.push(x + offset, y + offset, z + offset, 1.0);
        positions.push(x - offset, y + offset, z + offset, 1.0);

        // Back face
        positions.push(x - offset, y - offset, z - offset, 1.0);
        positions.push(x + offset, y - offset, z - offset, 1.0);
        positions.push(x + offset, y + offset, z - offset, 1.0);
        positions.push(x - offset, y + offset, z - offset, 1.0);

        // Top face
        positions.push(x - offset, y + offset, z - offset, 1.0);
        positions.push(x + offset, y + offset, z - offset, 1.0);
        positions.push(x + offset, y + offset, z + offset, 1.0);
        positions.push(x - offset, y + offset, z + offset, 1.0);

        // Bottom face
        positions.push(x - offset, y - offset, z - offset, 1.0);
        positions.push(x + offset, y - offset, z - offset, 1.0);
        positions.push(x + offset, y - offset, z + offset, 1.0);
        positions.push(x - offset, y - offset, z + offset, 1.0);

        // Right face
        positions.push(x + offset, y - offset, z - offset, 1.0);
        positions.push(x + offset, y - offset, z + offset, 1.0);
        positions.push(x + offset, y + offset, z + offset, 1.0);
        positions.push(x + offset, y + offset, z - offset, 1.0);

        // Left face
        positions.push(x - offset, y - offset, z - offset, 1.0);
        positions.push(x - offset, y - offset, z + offset, 1.0);
        positions.push(x - offset, y + offset, z + offset, 1.0);
        positions.push(x - offset, y + offset, z - offset, 1.0);

        return new Float32Array(positions);
    }

    createCubeVertexNormals(): Float32Array {
        let normals = [];

        // Front face
        for (let i = 0; i < 4; i++) {
            normals.push(0, 0, 1, 0);
        }

        // Back face
        for (let i = 0; i < 4; i++) {
            normals.push(0, 0, -1, 0);
        }

        // Top face
        for (let i = 0; i < 4; i++) {
            normals.push(0, 1, 0, 0);
        }

        // Bottom face
        for (let i = 0; i < 4; i++) {
            normals.push(0, -1, 0, 0);
        }

        // Right face
        for (let i = 0; i < 4; i++) {
            normals.push(1, 0, 0, 0);
        }

        // Left face
        for (let i = 0; i < 4; i++) {
            normals.push(-1, 0, 0, 0);
        }

        return new Float32Array(normals);
    }

    createCubeIndices(): Uint32Array {
        let indices = [];

        for (let i = 0; i < 6; ++i) {
            indices.push(4 * i);
            indices.push(4 * i + 1);
            indices.push(4 * i + 2);
            indices.push(4 * i);
            indices.push(4 * i + 2);
            indices.push(4 * i + 3);
        }

        return new Uint32Array(indices);
    }
};

export default Cube;