#
# Stage3d for three.js with every basics you need
#
# @author David Ronai / Makiopolis.com / @Makio64
#
OrbitControls = require('makio/3d/OrbitControls')
Stage = require('makio/core/Stage')
signals = require('signals')

class Stage3d

	@camera 	= null
	@scene 		= null
	@renderer 	= null
	@isInit		= false

	# postProcess with wagner
	@postProcessInitiated 	= false
	@usePostProcessing 		= false
	@passes 				= []

	@isActivated 			= false

	@init = (options)=>

		if(@isInit)
			@setColorFromOption(options)
			@activate()
			return

		@resolution = new THREE.Vector2()
		@onBeforeRenderer = new signals()

		w = window.innerWidth
		h = window.innerHeight
		if(w>700)
			w*=.4
		@resolution.x = w*window.devicePixelRatio
		@resolution.y = h*window.devicePixelRatio

		@camera = new THREE.PerspectiveCamera( 50, w / h, 1, 1000000 )

		@scene = new THREE.Scene()

		transparent = options.transparent||false
		antialias = options.antialias||false

		@renderer = new THREE.WebGLRenderer({alpha:transparent,antialias:antialias})
		@renderer.setPixelRatio( window.devicePixelRatio )
		@renderer.domElement.className = 'three'

		@setColorFromOption(options)
		@renderer.setSize( w, h )

		@isInit = true

		@activate()
		return

	@setColorFromOption = (options)=>
		if(options.transparent != undefined)
			@renderer.alpha = options.transparent
		if(options.background?)
			if(options.transparent) then alpha = 0
			else alpha = 1
			@renderer.setClearColor( parseInt(options.background), alpha )
		return

	@activate = ()=>
		if(@isActivated)
			return
		@isActivated = true
		Stage.onUpdate.add(@render)
		Stage.onResize.add(@resize)
		document.body.appendChild(@renderer.domElement)
		return

	@desactivate = ()=>
		if(!@isActivated)
			return
		@isActivated = false
		Stage.onUpdate.remove(@render)
		Stage.onResize.remove(@resize)
		document.body.removeChild(@renderer.domElement)
		return

	@initPostProcessing = ()=>

		if(@postProcessInitiated)
			return

		console.log('WAGNER PostProcess')
		@postProcessInitiated = true
		@usePostProcessing = true
		@composer = new WAGNER.Composer( @renderer, {useRGBA: false} )
		@composer.setSize( window.innerWidth, window.innerHeight )
		return

	@add = (obj)=>
		@scene.add(obj)
		return


	@remove = (obj)=>
		@scene.remove(obj)
		return


	@removeAll = ()=>
		while @scene.children.length>0
			@scene.remove(@scene.children[0])
		return

	@addPass = (pass)=>
		@passes.push(pass)
		return

	@removePass = (pass)=>
		for i in [0...@passes.length] by 1
			if(@passes[i]==pass)
				@passes.splice(i,1)
				break
		return

	@render = (dt)=>
		if(@control)
			@control.update(dt)

		@onBeforeRenderer.dispatch()

		if(@usePostProcessing)
			@renderer.autoClearColor = true
			@composer.reset()
			@composer.render( @scene, @camera )
			for pass in @passes
				@composer.pass( pass )
			@composer.toScreen()
		else
			@renderer.render(@scene, @camera)
		return


	@resize = ()=>
		w = window.innerWidth
		h = window.innerHeight
		if(w>700)
			w*=.4
		@resolution.x = w*window.devicePixelRatio
		@resolution.y = h*window.devicePixelRatio
		if @composer
			@composer.setSize( w, h )
		if @renderer
			@camera.aspect = w / h
			@camera.updateProjectionMatrix()
			@renderer.setSize( w, h )
			@renderer.setPixelRatio( window.devicePixelRatio )
			@render(0)
		return

	@initGUI = (gui)=>
		g = gui.addFolder('Camera')
		g.add(@camera,'fov',1,100).onChange(@resize)
		g.add(@camera.position,'x').listen()
		g.add(@camera.position,'y').listen()
		g.add(@camera.position,'z').listen()
		return

module.exports = Stage3d
