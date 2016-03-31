Stage3d 		= require("makio/core/Stage3d")
Stage 			= require("makio/core/Stage")
ObjectPool 		= require("makio/core/ObjectPool")
Components		= require('Components')

require("THREE.MeshLine.js")

class Branch extends THREE.Object3D

	# ------------------------------------------------------------------------- Constructor

	constructor:(color={r:255,g:255,b:255}, tBonus=0, phiBonus=0, radius=0)->
		super()
		@hidding = false
		@time = 0
		@speed = (200+150*Math.random())
		geometry = @createGeometry(tBonus,phiBonus,radius)

		@line = new THREE.MeshLine()
		@line.setGeometry( geometry )
		@linematerial = @createMaterial(color)

		@mesh = new THREE.Mesh( @line.geometry, @linematerial)
		@add(@mesh)

		@pGeometry = @createParticleGeometry(@line)
		pMaterial = @createParticleMaterial(@line,color)

		particles = new THREE.Points(@pGeometry,pMaterial)
		particles.frustumCulled = false
		@add(particles)
		return

	# ------------------------------------------------------------------------- Reset Value ( for pool out )

	init:(color={r:255,g:255,b:255}, tBonus=0, phiBonus=0, radius=0)=>
		# RESET VALUE
		@hidding = false
		@time = 0
		@uniforms.time.value = 0
		@uniforms.color.value.set(color.r,color.g,color.b)
		@uniforms.hide.value = 0
		@linematerial.uniforms.resolution.value = Stage3d.resolution
		@linematerial.uniforms.time.value = 0
		@linematerial.uniforms.color.value.r = color.r
		@linematerial.uniforms.color.value.g = color.g
		@linematerial.uniforms.color.value.b = color.b
		@linematerial.near = Stage3d.camera.near
		@linematerial.far = Stage3d.camera.far
		@linematerial.uniforms.hide.value = 0
		@speed = (200+150*Math.random())
		# Change Geometry Position
		positions = @changeGeometry(tBonus,phiBonus,radius)
		@updatePosition(positions)
		# Update loop
		Stage.onUpdate.add(@update)
		return
	# ------------------------------------------------------------------------- Update

	update:(dt)=>
		dt *= Components.getSliderID('deltaSpeed').target
		@time += dt
		@mesh.visible = !Components.getButtonID('particleOnly')._isOn
		@linematerial.uniforms.lineWidth.value = Components.getSliderID('lineWidth').target || 15

		if(@hidding)
			@uniforms.time.value -= dt*2
			@linematerial.uniforms.time.value += dt/@speed*2
		else
			@uniforms.time.value += dt*1.2
			@linematerial.uniforms.time.value -= dt/@speed*1.2
		return

	# ------------------------------------------------------------------------- Hide Anim

	hide:()=>
		@hidding = true
		duration = 1.5+Math.random()*.5
		delay = Math.random()*.4
		TweenMax.to(@uniforms.hide,duration,{delay:delay,value:1,ease:Quad.easeOut})
		TweenMax.to(@linematerial.uniforms.hide,duration,{delay:delay,value:1,ease:Quad.easeOut,onComplete:()=>
			Stage.onUpdate.remove(@update)
			Branch.POOL.checkIn(@)
		})
		return

	# ------------------------------------------------------------------------- Line Material

	createMaterial:(color)->
		material = new THREE.MeshLineMaterial({
			useMap: false,
			color: new THREE.Color( color.r,color.g,color.b ),
			opacity: .8,
			transparent:true,
			depthTest:false,
			depthWrite:false,
			blending: THREE.AdditiveBlending
			resolution: new THREE.Vector2( window.innerWidth, window.innerHeight ),
			sizeAttenuation: true,
			lineWidth: Components.getSliderID('lineWidth').target || 15,
			near: 0,
			far: 1000
		})
		return material

	# ------------------------------------------------------------------------- Line Geometry & update

	createGeometry:(tBonus,phiBonus,r)->
		@steps = 100+Math.floor(Math.random()*56)*4
		@positionsFloat = new Float32Array( @steps*3 );
		return @changeGeometry(tBonus,phiBonus,r)

	changeGeometry:(tBonus,phiBonus,r)->
		z = 0
		x = 0
		y = .5
		phi = 0
		@thetaStart = theta = Math.random()*Math.PI*2
		@phiBonus = 0.005*(1+Math.random())+phiBonus
		@thetaBonus = 0.03*(1+Math.random())+tBonus
		@radius = radius = ((5+Math.random()*10)*1.2)*r+r
		for j in [0...@steps*3] by 3
			k = j/3
			@positionsFloat[ j ] = x
			@positionsFloat[ j + 1 ] = y
			@positionsFloat[ j + 2 ] = z
			x += radius * Math.sin( phi ) * Math.cos( theta )
			y += radius * Math.cos( phi )
			z += radius * Math.sin( phi ) * Math.sin( theta )
			phi+=@phiBonus
			theta+=@thetaBonus
		return @positionsFloat

	updatePosition:(positions)->
		@line.setPositions( positions )
		@line.setWidth( (p)-> return p*Components.getSliderID('division').target )
		for i in [0...positions.length] by 3
			@uniforms.path.value[i/3] = new THREE.Vector3(positions[i],positions[i+1],positions[i+2])
		return



	# ------------------------------------------------------------------------- Particles Geometry

	createParticleGeometry:(line)->

		geometry = new THREE.BufferGeometry()
		size = 1500
		positions = new Float32Array( size*3 )
		times = new Float32Array( size )
		percents = new Float32Array( size )
		offsets = new Float32Array( size*3 )

		for index in [0...size*3] by 3
			percent = Math.random()
			lineIndex = Math.floor(percent*(@positionsFloat.length/3-2)+1)
			lineIndex *= 3
			offsets[ index     ] = 30 * (Math.random()-.5)
			offsets[ index + 1 ] = 30 * (Math.random()-.5)
			offsets[ index + 2 ] = 30 * (Math.random()-.5)
			positions[ index     ] = @positionsFloat[lineIndex]+offsets[ index ]
			positions[ index + 1 ] = @positionsFloat[lineIndex+1]+offsets[ index + 1 ]
			positions[ index + 2 ] = @positionsFloat[lineIndex+2]+offsets[ index + 2 ]
			times[index/3] = 1000*Math.random()
			percents[index/3] = percent

		geometry.addAttribute( 'aTime', new THREE.BufferAttribute( times, 1 ) )
		geometry.addAttribute( 'aPercent', new THREE.BufferAttribute( percents, 1 ) )
		geometry.addAttribute( 'aOffset', new THREE.BufferAttribute( offsets, 3 ) )
		geometry.addAttribute( 'position', new THREE.BufferAttribute( positions, 3 ) )
		return geometry

	# ------------------------------------------------------------------------- Particles Material

	createParticleMaterial:(line,color)->
		loader = new THREE.TextureLoader()
		path = []
		for i in [0...@positionsFloat.length] by 3
			path[i/3] = new THREE.Vector3(@positionsFloat[i],@positionsFloat[i+1],@positionsFloat[i+2])

		@uniforms = {
			texture:   	{ type: "t", value: loader.load( "img/particle.png" ) }
			opacity:   	{ type: "f", value: 1 }
			hide: 	   	{ type: "f", value: 0 }
			size: 	   	{ type: "f", value: 4*(window.devicePixelRatio/2) }
			scale: 	   	{ type: "f", value: 6720 }
			color: 	   	{ type: "v3", value: new THREE.Vector3(color.r,color.g,color.b) }
			time: 	   	{ type: "f", value: 0 }
			pathLength:	{ type: "f", value: path.length }
			path:		{ type: "v3v", value:path }
		}

		material = new THREE.ShaderMaterial( {
			uniforms:       @uniforms
			vertexShader:   "uniform vec3 path[#{@steps}];" + require('particleBranch.vs')
			fragmentShader: require('particleBranch.fs')
			depthTest:      false
			depthWrite:     false
			transparent:    true
			blending: 		THREE.AdditiveBlending
			fog: 			false
		})
		return material

	@POOL = new ObjectPool(()->
		return new Branch()
	, 40, 100)

module.exports = Branch
