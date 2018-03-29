import Texture from './Texture';
import {gl} from '../../globals';
import ShaderProgram, {Shader} from './ShaderProgram';
import Drawable from './Drawable';
import Square from '../../geometry/Square';
import {vec3, vec4, mat4} from 'gl-matrix';

class PostProcess extends ShaderProgram {
	static screenQuad: Square = undefined; // Quadrangle onto which we draw the frame texture of the last render pass
	unifFrame: WebGLUniformLocation; // The handle of a sampler2D in our shader which samples the texture drawn to the quad
	unifHighPass: WebGLUniformLocation; // The handle of a sampler2D in our shader which samples the texture drawn to the quad
	unifDepth: WebGLUniformLocation; // The handle of a sampler2D in our shader which samples the texture drawn to the quad

	unifBloom: WebGLUniformLocation;
	unifDof: WebGLUniformLocation;
	unifTone: WebGLUniformLocation;
	unifSketch: WebGLUniformLocation;

	name: string;

	constructor(fragProg: Shader, tag: string = "default") {
		super([new Shader(gl.VERTEX_SHADER, require('../../shaders/screenspace-vert.glsl')),
			fragProg]);

		this.unifFrame = gl.getUniformLocation(this.prog, "u_frame");
		this.unifHighPass = gl.getUniformLocation(this.prog, "u_highpass");
		this.unifDepth = gl.getUniformLocation(this.prog, "u_depth");

		this.unifBloom = gl.getUniformLocation(this.prog, "u_Bloom");
		this.unifDof = gl.getUniformLocation(this.prog, "u_Dof");
		this.unifTone = gl.getUniformLocation(this.prog, "u_Tone");
		this.unifSketch = gl.getUniformLocation(this.prog, "u_Sketch");

		this.use();
		this.name = tag;

		// bind texture unit 0 to this location
		gl.uniform1i(this.unifFrame, 0); // gl.TEXTURE0
		if(this.unifHighPass != -1) {
			gl.uniform1i(this.unifHighPass, 1); // gl.TEXTURE1
		}
		if(this.unifDepth != -1) {
			gl.uniform1i(this.unifDepth, 2); // gl.TEXTURE2
		}
		if (PostProcess.screenQuad === undefined) {
			PostProcess.screenQuad = new Square(vec3.fromValues(0, 0, 0));
			PostProcess.screenQuad.create();
		}
	}

	setPostFilters(bloom: boolean, dof: boolean, tone: boolean, sketch: boolean) {
		this.use();
		if (this.unifBloom !== -1) {
		  gl.uniform1i(this.unifBloom, bloom ? 0 : 1);
		}
		if (this.unifDof !== -1) {
		  gl.uniform1i(this.unifDof, dof ? 0 : 1);
		}
		if (this.unifTone !== -1) {
		  gl.uniform1i(this.unifTone, tone ? 0 : 1);
		}
		if (this.unifSketch !== -1) {
		  gl.uniform1i(this.unifSketch, sketch ? 0 : 1);
		}
	}

  	draw() {
  		super.draw(PostProcess.screenQuad);
  	}

  	getName() : string { return this.name; }

}

export default PostProcess;
