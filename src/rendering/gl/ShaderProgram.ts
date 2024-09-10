import {vec4, mat4} from 'gl-matrix';
import Drawable from './Drawable';
import {gl} from '../../globals';

var activeProgram: WebGLProgram = null;

export class Shader {
  shader: WebGLShader;

  constructor(type: number, source: string) {
    this.shader = gl.createShader(type);
    gl.shaderSource(this.shader, source);
    gl.compileShader(this.shader);

    if (!gl.getShaderParameter(this.shader, gl.COMPILE_STATUS)) {
      throw gl.getShaderInfoLog(this.shader);
    }
  }
};

class ShaderProgram {
  prog: WebGLProgram;

  attrPos: number;
  attrNor: number;
  attrCol: number;
  attrUVs: number;
  

  unifModel: WebGLUniformLocation;
  unifModelInvTr: WebGLUniformLocation;
  unifViewProj: WebGLUniformLocation;
  unifColor: WebGLUniformLocation;
  unifTime: WebGLUniformLocation;
  unifTexture: WebGLUniformLocation;
  unifGridSize : WebGLUniformLocation;
  unifOffsetSize : WebGLUniformLocation;
  unifRangeRadius : WebGLUniformLocation;
  unifIncrement : WebGLUniformLocation;
  unifNeighborMax : WebGLUniformLocation;
  unifNeighborMin : WebGLUniformLocation;
  unifHalfNearest : WebGLUniformLocation;
  unifConway : WebGLUniformLocation;

  constructor(shaders: Array<Shader>) {
    this.prog = gl.createProgram();

    for (let shader of shaders) {
      gl.attachShader(this.prog, shader.shader);
    }
    gl.linkProgram(this.prog);
    if (!gl.getProgramParameter(this.prog, gl.LINK_STATUS)) {
      throw gl.getProgramInfoLog(this.prog);
    }

    this.attrPos = gl.getAttribLocation(this.prog, "vs_Pos");
    this.attrNor = gl.getAttribLocation(this.prog, "vs_Nor");
    this.attrCol = gl.getAttribLocation(this.prog, "vs_Col");
    this.attrUVs = gl.getAttribLocation(this.prog, "vs_UVs");
    this.unifModel      = gl.getUniformLocation(this.prog, "u_Model");
    this.unifModelInvTr = gl.getUniformLocation(this.prog, "u_ModelInvTr");
    this.unifViewProj   = gl.getUniformLocation(this.prog, "u_ViewProj");
    this.unifColor      = gl.getUniformLocation(this.prog, "u_Color");
    this.unifTime       = gl.getUniformLocation(this.prog, "u_Time");
    this.unifTexture    = gl.getUniformLocation(this.prog, "u_Texture");

    this.unifGridSize = gl.getUniformLocation(this.prog, "u_gridSize");
    this.unifOffsetSize = gl.getUniformLocation(this.prog, "u_offsetSize");
    this.unifRangeRadius  = gl.getUniformLocation(this.prog, "u_rangeRadius");
    this.unifIncrement  = gl.getUniformLocation(this.prog, "u_increment");
    this.unifNeighborMax  = gl.getUniformLocation(this.prog, "u_neighborMax");
    this.unifNeighborMin  = gl.getUniformLocation(this.prog, "u_neighborMin");
    this.unifHalfNearest  = gl.getUniformLocation(this.prog, "u_halfNearest");
    this.unifConway = gl.getUniformLocation(this.prog, "u_conway");

  }

  use() {
    if (activeProgram !== this.prog) {
      gl.useProgram(this.prog);
      activeProgram = this.prog;
    }
  }

  setModelMatrix(model: mat4) {
    this.use();
    if (this.unifModel !== -1) {
      gl.uniformMatrix4fv(this.unifModel, false, model);
    }

    if (this.unifModelInvTr !== -1) {
      let modelinvtr: mat4 = mat4.create();
      mat4.transpose(modelinvtr, model);
      mat4.invert(modelinvtr, modelinvtr);
      gl.uniformMatrix4fv(this.unifModelInvTr, false, modelinvtr);
    }
  }

  setViewProjMatrix(vp: mat4) {
    this.use();
    if (this.unifViewProj !== -1) {
      gl.uniformMatrix4fv(this.unifViewProj, false, vp);
    }
  }

  setGeometryColor(color: vec4) {
    this.use();
    if (this.unifColor !== -1) {
      gl.uniform4fv(this.unifColor, color);
    }
  }

  setTime(t : number) {
    this.use();
    if (this.unifTime !== -1) {
      gl.uniform1f(this.unifTime, t);
    }
  }

  setTexture(texture: WebGLTexture) {
    this.use();
    if (this.unifTexture !== -1) {
      gl.activeTexture(gl.TEXTURE0);
      gl.bindTexture(gl.TEXTURE_2D, texture);
      gl.uniform1i(this.unifTexture, 0);
    }

  }

  setProps(props: AutomataProps) {
    this.use();
    if (this.unifGridSize !== -1) {
      gl.uniform1f(this.unifGridSize, props.gridSize);
      gl.uniform1f(this.unifOffsetSize, props.offsetSize);
      gl.uniform1f(this.unifRangeRadius, props.rangeRadius);
      gl.uniform1f(this.unifIncrement, props.increment);
      gl.uniform1f(this.unifNeighborMax, props.neighborMax);
      gl.uniform1f(this.unifNeighborMin, props.neighborMin);
      gl.uniform1f(this.unifHalfNearest, props.halfNearest);
      gl.uniform1i(this.unifConway, props.conway? 1 : 0);
    }
    
  }

  draw(d: Drawable) {
    this.use();

    if (this.attrPos != -1 && d.bindPos()) {
      gl.enableVertexAttribArray(this.attrPos);
      gl.vertexAttribPointer(this.attrPos, 4, gl.FLOAT, false, 0, 0);
    }

    if (this.attrNor != -1 && d.bindNor()) {
      gl.enableVertexAttribArray(this.attrNor);
      gl.vertexAttribPointer(this.attrNor, 4, gl.FLOAT, false, 0, 0);
    }

    if (this.attrUVs != -1 && d.bindUVs()) {
      gl.enableVertexAttribArray(this.attrUVs);
      gl.vertexAttribPointer(this.attrUVs, 2, gl.FLOAT, false, 0, 0);
    }

    d.bindIdx();
    gl.drawElements(d.drawMode(), d.elemCount(), gl.UNSIGNED_INT, 0);

    if (this.attrPos != -1) gl.disableVertexAttribArray(this.attrPos);
    if (this.attrNor != -1) gl.disableVertexAttribArray(this.attrNor);
  }
};

export default ShaderProgram;


export interface AutomataProps {
  gridSize: number;
  offsetSize: number;
  rangeRadius: number;
  increment: number;
  neighborMax: number;
  neighborMin: number;
  halfNearest: number;
  conway: boolean;
};