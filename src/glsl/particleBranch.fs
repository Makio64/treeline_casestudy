uniform sampler2D texture;
uniform float opacity;
uniform float time;
uniform vec3 color;
uniform float hide;
varying float vT;
varying vec3 vPos;

void main() {
	float alpha = opacity;
	alpha *= 1.-smoothstep(0.98, 1., vT);
	alpha *= smoothstep(vPos.y,vPos.y+1.,time);
	alpha *= smoothstep(hide,hide+0.15,1.-vT);
	gl_FragColor = vec4(color, alpha )*texture2D( texture, gl_PointCoord );
}
