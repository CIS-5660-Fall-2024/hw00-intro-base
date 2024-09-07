import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class Cube extends Drawable {
    center: vec4
    triangle_indices: Uint32Array
    vertex_positions: Float32Array
    vertex_normals: Float32Array


    create(): void {
        throw new Error('Method not implemented.');
    }
    
    constructor(center: vec3) {
        super()
        this.center = vec4.fromValues(center[0], center[1], center[2], 1);

        // separate vertex-positions for each face, since the face normals are different
        let face_normals: vec4[] = [
            vec4.fromValues(-1, 0, 0, 0), vec4.fromValues(1, 0, 0, 0),
            vec4.fromValues(0, -1, 0, 0), vec4.fromValues(0, 1, 0, 0),
            vec4.fromValues(0, 0, -1, 0), vec4.fromValues(0, 0, 1, 0)
        ]



    }
}