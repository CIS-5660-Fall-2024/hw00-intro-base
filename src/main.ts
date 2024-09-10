import {vec3, vec4} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import Cube from './geometry/Cube';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import { AutomataProps } from './rendering/gl/ShaderProgram';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentially
  color: [255, 255, 255, 1.0]
};

const propsAutomata : AutomataProps = {
  gridSize: 512,
  offsetSize: 1024,
  increment: 0.00,
  rangeRadius: 1,
  neighborMax: 12,
  neighborMin: 6.5,
  halfNearest: 1,
  conway: false,
}

interface bAT {
  currTexture?: WebGLTexture;
  nextTexture?: WebGLTexture;
  currFrameBuffer?: WebGLFramebuffer;
  nextFrameBuffer?: WebGLFramebuffer;
}

let buffersAndTextures : bAT = { };

let icosphere: Icosphere;
let square: Square;
let cube: Cube;
let prevTesselations: number = 5;

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
  cube = new Cube(vec3.fromValues(0, 0, 0));
  cube.create()
}

function resetAutomata(gl : WebGL2RenderingContext, renderer: OpenGLRenderer, camera: Camera, lambert: ShaderProgram, buffersAndTextures: bAT) {
  return () => {
    if (!('nextTexture' in buffersAndTextures)) {
      buffersAndTextures.nextTexture = gl.createTexture();
    }
    gl.bindTexture(gl.TEXTURE_2D, buffersAndTextures.nextTexture);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, window.innerWidth, window.innerHeight, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
    //gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE,
    //  new Uint8Array([0, 255, 0, 255]));
    
    
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);

    if (!('nextFrameBuffer' in buffersAndTextures)) {
      buffersAndTextures.nextFrameBuffer = gl.createFramebuffer();
    }
    gl.bindFramebuffer(gl.FRAMEBUFFER, buffersAndTextures.nextFrameBuffer);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, buffersAndTextures.nextTexture, 0);

    gl.clearColor(0.3, 0.3, 0.3, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.clearColor(0.2, 0.2, 0.2, 1.0);

    if (!('currTexture' in buffersAndTextures)) {
      buffersAndTextures.currTexture = gl.createTexture();
    }
    gl.bindTexture(gl.TEXTURE_2D, buffersAndTextures.currTexture);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, window.innerWidth, window.innerHeight, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
    //gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE,
    //  new Uint8Array([0, 255, 0, 255]));
    
    
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);

    if (!('currFrameBuffer' in buffersAndTextures)) {
      buffersAndTextures.currFrameBuffer = gl.createFramebuffer();
    }
    gl.bindFramebuffer(gl.FRAMEBUFFER, buffersAndTextures.currFrameBuffer);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, buffersAndTextures.currTexture, 0);


    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    gl.bindFramebuffer(gl.FRAMEBUFFER, buffersAndTextures.currFrameBuffer);
      
    gl.clearColor(0.3, 0.3, 0.3, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.clearColor(0.2, 0.2, 0.2, 1.0);

    renderer.render(camera, lambert, [
      // icosphere,
      // square,
      cube,
    ]);
    

    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
  }

}

function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'Load Scene');
  gui.addColor(controls, 'color');

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')),
  ]);

  const passthrough = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/neutral-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/passthrough-frag.glsl')),
  ])

  const passthrough2 = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/cellAutomata-frag.glsl')),
  ])


  let t : number = 0; 

  (resetAutomata(gl, renderer, camera, lambert, buffersAndTextures))();

  const resetAutomataButton = {'Reset Automata' : resetAutomata(gl, renderer, camera, lambert, buffersAndTextures)};
  gui.add(resetAutomataButton, 'Reset Automata');


  const guiContainer = gui.domElement.parentElement as HTMLElement;

  const scale = 1.5;

  guiContainer.style.transform = `scale(${scale})`;

  guiContainer.style.transformOrigin = 'top right';
  guiContainer.style.position = 'absolute';
  guiContainer.style.right = '0px';
  guiContainer.style.top = '0px';


  let temp : WebGLFramebuffer;
  let temp2 : WebGLTexture;

  function preset1() {
    return () => {
      propsAutomata.gridSize = 500;
      propsAutomata.offsetSize = 1024;
      propsAutomata.rangeRadius = 2;
      propsAutomata.increment = 0.1;
      propsAutomata.neighborMax = 12;
      propsAutomata.neighborMin = 7;
      propsAutomata.halfNearest = 1;
      propsAutomata.conway = false;
    }
  }

  function preset2() {
    return () => {
      propsAutomata.gridSize = 512;
      propsAutomata.offsetSize = 1024;
      propsAutomata.rangeRadius = 2;
      propsAutomata.increment = 0.1;
      propsAutomata.neighborMax = 12;
      propsAutomata.neighborMin = 7;
      propsAutomata.halfNearest = 1;
      propsAutomata.conway = false;
    }
  }

  function preset3() {
    return () => {
      propsAutomata.gridSize = 310;
      propsAutomata.offsetSize = 310;
      propsAutomata.rangeRadius = 1;
      propsAutomata.increment = 1;
      propsAutomata.neighborMax = 3.5;
      propsAutomata.neighborMin = 2.5;
      propsAutomata.halfNearest = 1;
      propsAutomata.conway = true;
    }
  }

  function preset4() {
    return () => {
      propsAutomata.gridSize = 368;
      propsAutomata.offsetSize = 368;
      propsAutomata.rangeRadius = 1;
      propsAutomata.increment = 1;
      propsAutomata.neighborMax = 3.5;
      propsAutomata.neighborMin = 2.5;
      propsAutomata.halfNearest = 1;
      propsAutomata.conway = true;
    }
  }

  function preset5() {
    return () => {
      propsAutomata.gridSize = 354;
      propsAutomata.offsetSize = 354;
      propsAutomata.rangeRadius = 2;
      propsAutomata.increment = 1;
      propsAutomata.neighborMax = 12;
      propsAutomata.neighborMin = 6.5;
      propsAutomata.halfNearest = 2;
      propsAutomata.conway = false;
    }
  }

  function preset6() {
    return () => {
      propsAutomata.gridSize = 300;
      propsAutomata.offsetSize = 300;
      propsAutomata.rangeRadius = 2;
      propsAutomata.increment = 0.1;
      propsAutomata.neighborMax = 12;
      propsAutomata.neighborMin = 6.5;
      propsAutomata.halfNearest = 2;
      propsAutomata.conway = false;
    }
  }

  function preset7() {
    return () => {
      propsAutomata.gridSize = 512;
      propsAutomata.offsetSize = 1024;
      propsAutomata.rangeRadius = 2;
      propsAutomata.increment = 1;
      propsAutomata.neighborMax = 12;
      propsAutomata.neighborMin = 6.5;
      propsAutomata.halfNearest = 2;
      propsAutomata.conway = false;
    }
  }

  const presets = {
    'Preset 2 - Smoky Grid' : preset1(),
    'Preset 1 - Scanlines' : preset2(),
    'Preset 3 - Game of Life 1' : preset3(),
    'Preset 4 - Game of Life 2' : preset4(),
    'Preset 5 - Foam' : preset5(),
    'Preset 6 - Maze' : preset6(),
    'Preset 7 - Billowing Smokestack' : preset7(),
  }

  const automataFolder = gui.addFolder("Automata Presets");
  
  automataFolder.add(presets, "Preset 1 - Scanlines");
  automataFolder.add(presets, "Preset 2 - Smoky Grid");
  automataFolder.add(presets, "Preset 3 - Game of Life 1");
  automataFolder.add(presets, "Preset 4 - Game of Life 2");
  automataFolder.add(presets, "Preset 5 - Foam");
  automataFolder.add(presets, "Preset 6 - Maze");
  automataFolder.add(presets, "Preset 7 - Billowing Smokestack");
  automataFolder.open();

  const finetuning = gui.addFolder("Automata Fine Tuning");
  finetuning.add(propsAutomata, "gridSize", 256, 1024).onChange((value) => {propsAutomata.offsetSize = value});
  finetuning.add(propsAutomata, "offsetSize", 256, 1024);
  finetuning.add(propsAutomata, "rangeRadius", 1, 2, 1);
  finetuning.add(propsAutomata, "increment", 0.00, 1.0);
  finetuning.add(propsAutomata, "neighborMax", 1, 25, 0.1);
  finetuning.add(propsAutomata, "neighborMin", 1, 25, 0.1);
  finetuning.add(propsAutomata, "halfNearest", 1, 2, 1);
  finetuning.add(propsAutomata, "conway");
  
  
  
  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    if(controls.tesselations != prevTesselations)
    {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations);
      icosphere.create();
    }

    t++;
    if (t % 5 == 0) {
    gl.bindFramebuffer(gl.FRAMEBUFFER, buffersAndTextures.nextFrameBuffer);
    
    // gl.clearColor(0.0, 0.0, 1.0, 1.0);
    // gl.clear(gl.COLOR_BUFFER_BIT);
    // gl.clearColor(0.2, 0.2, 0.2, 1.0);

    renderer.renderAutomata(camera, passthrough2, [
      // icosphere,
      // square,
      cube,
    ], buffersAndTextures.currTexture, propsAutomata);
    
    // use currTexture

    temp = buffersAndTextures.nextFrameBuffer;
    buffersAndTextures.nextFrameBuffer = buffersAndTextures.currFrameBuffer;
    buffersAndTextures.currFrameBuffer = temp;

    temp2 = buffersAndTextures.nextTexture;
    buffersAndTextures.nextTexture = buffersAndTextures.currTexture;
    buffersAndTextures.currTexture = temp2;
    }

    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    
    renderer.renderPassthrough(camera, passthrough, [
      // icosphere,
      //square,
      cube,
    ], buffersAndTextures.currTexture, t, vec4.fromValues(controls.color[0]/255, controls.color[1]/255, controls.color[2]/255, 1.0));
    
    
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // TODO: update cubeTexture dimensions on resize

  // Start the render loop
  tick();
}

main();
