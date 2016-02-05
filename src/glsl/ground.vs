uniform float size;
uniform float time;
uniform float scale;
uniform float radius;
uniform float height;
uniform float dist;

attribute float aTime;
attribute float aSpeed;
attribute vec3 aAngle;

void main() {
	vec3 pos = position;
	float t = (time+aTime)/100.;
	float theta = aAngle.y + aTime;
	float phi = aAngle.x + sin(aSpeed*t)*.5;
	pos.x = aAngle.z * sin( phi ) * cos( theta ) * radius;
	pos.z = aAngle.z * sin( phi ) * sin( theta ) * radius;
	//the smoothstep made the force stronger at the center and more weak after
	pos.y = smoothstep(0., dist, distance(pos,vec3(0.))) * height;
	vec4 mvPosition = modelViewMatrix * vec4( pos, 1.0 );
	//size <= 0 bug on iOS., the abs is here to prevent it
	gl_PointSize = abs(size*sin(t));
	gl_Position = projectionMatrix * mvPosition;
}
