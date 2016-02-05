Stage3d 		= require('makio/core/Stage3d')
Stage 	= require('makio/core/Stage')
Components 		= require('Components')

class Ground extends THREE.Points

	constructor:(vertices)->
		material = @createMaterial()
		geometry = @createGeometry()
		super(geometry,material)
		Stage.onUpdate.add(@update)
		Stage3d.add(@)
		@frustumCulled = false

		Components.getSliderID('groundRadius').add(@uniforms.radius,'value',0.01,1.5)
		Components.getSliderID('groundHeight').add(@uniforms.height,'value',0.01,300)
		Components.getSliderID('groundDistance').add(@uniforms.dist,'value',0.01,500)
		return

	animIn:()=>
		TweenMax.to(@uniforms.opacity,4,{value:1})
		return

	update:(dt)=>
		@uniforms.time.value += dt/10;
		return

	activate:(color)=>
		# TweenMax.to(@uniforms.radius,4,{ease:Cubic.easeInOut,value:1.4})
		TweenMax.to(@uniforms.color.value,2.5,{ease:Cubic.easeOut,x:color.r,y:color.g,z:color.b})
		return

	desactivate:()=>
		TweenMax.to(@uniforms.color.value,4.5,{ease:Cubic.easeIn,x:1,y:.9,z:.6})
		TweenMax.to(@uniforms.radius,2,{ease:Cubic.easeInOut,value:.6})
		return

	createMaterial:()->
		loader = new THREE.TextureLoader()
		@uniforms = {
			texture:   { type: "t", value: loader.load( "img/particle.png" ) }
			opacity:   { type: "f", value: 0 }
			color:     { type: "v3", value: new THREE.Vector3(1.0,0.9,0.6) }
			size: 	   { type: "f", value: 3*(window.devicePixelRatio/2) }
			radius:    { type: "f", value: .6 }
			height:    { type: "f", value: 100 }
			dist:    { type: "f", value: 100 }
			scale: 	   { type: "f", value: Stage3d.camera.far }
			time: 	   { type: "f", value: 0 }
		}

		material = new THREE.ShaderMaterial( {
			uniforms:       @uniforms
			vertexShader:   require('ground.vs')
			fragmentShader: require('ground.fs')
			depthTest:      false
			depthWrite:     false
			transparent:    true
			blending: 		THREE.AdditiveBlending
			fog: 			false
		})

		return material


	createGeometry:()->
		geometry = new THREE.BufferGeometry()
		size = 10000
		positions = new Float32Array( size*3 )
		angles = new Float32Array( size*3 )
		times = new Float32Array( size )
		speeds = new Float32Array( size )
		radius = 400
		pi2 = Math.PI * 2

		for index in [0...size*3] by 3
			r = radius
			if(Math.random()>.8)
				r+=Math.random()*200
			positions[ index + 0 ] = 0
			positions[ index + 1 ] = 0
			positions[ index + 2 ] = 0
			angles[ index + 0 ] = Math.random() * pi2
			angles[ index + 1 ] = Math.random() * pi2
			angles[ index + 2 ] = r
			times[index/3] = 1000*Math.random()
			speeds[index/3] = Math.random()*.3+.7;

		geometry.addAttribute( 'aTime', new THREE.BufferAttribute( times, 1 ) )
		geometry.addAttribute( 'position', new THREE.BufferAttribute( positions, 3 ) )
		geometry.addAttribute( 'aAngle', new THREE.BufferAttribute( angles, 3 ) )
		geometry.addAttribute( 'aSpeed', new THREE.BufferAttribute( speeds, 1 ) )
		return geometry

module.exports = Ground
