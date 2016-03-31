Stage 			= require('makio/core/Stage')
Stage3d 		= require('makio/core/Stage3d')
Tree 			= require('tree_p/Tree')
Ground 			= require('tree_p/Ground')
OrbitControls 	= require('makio/3d/OrbitControls')
Interactions	= require('makio/core/Interactions')
Components		= require('Components')

class Main

	@is3d = true

	constructor:(cb)->
		console.log('TreeLine Case Study')

		Stage3d.init({background:0})
		Stage3d.control = new OrbitControls(Stage3d.camera,3000)
		Stage3d.control.theta = 2.1
		Stage3d.control.maxRadius = 10000
		Stage3d.control.minRadius = 3000
		Stage3d.control.isPhiRestricted = true
		Stage3d.control.minPhi = 0.1
		Stage3d.camera.fov = 50
		Stage3d.camera.updateProjectionMatrix()

		Components.getSliderID('epsilonTheta').minMax(0,0.003,0.002).onChange.add(@newTree)
		Components.getSliderID('epsilonPhi').minMax(0,0.01,0.002).onChange.add(@newTree)
		Components.getSliderID('shapeRadius').minMax(0.3,2,.9).onChange.add(@newTree)
		Components.getSliderID('deltaSpeed').minMax(0,2,1)
		Components.getSliderID('lineWidth').minMax(3,60,15)
		Components.getSliderID('division').minMax(1,400,10).ease(1).onChange.add(@newTree)
		Components.getButtonID('makeNew').onClick.add(@newTree)
		Components.getButtonID('particleOnly').div.style.opacity = '0.3'
		Components.getButtonID('particleOnly').onClick.add((isOn)->
			Components.getButtonID('particleOnly').div.style.opacity = if isOn then "1" else "0.3"
		)

		@colorIdx = 4
		@colorTree = [{r:.6,g:.4,b:.1},{r:.1,g:.4,b:.6},{r:.5,g:.5,b:.2},{r:.6,g:.2,b:.15},{r:.25,g:.25,b:.6},{r:.6,g:.6,b:.45},{r:.8,g:.7,b:.8}]
		@colorGround = [{r:.6,g:.4,b:.1},{r:.1,g:.4,b:.6},{r:.5,g:.5,b:.2},{r:.6,g:.2,b:.15},{r:.25,g:.25,b:.6},{r:.6,g:.6,b:.45},{r:.8,g:.7,b:.8}]

		@floor = new Ground()
		@floor.animIn()
		@floor.position.y -= 900
		@newTree()
		cb(1)

		Stage.onUpdate.add(@update)
		return

	newTree:()=>
		if(@tree)
			@tree.hide()
		@tree = new Tree(@colorTree[@colorIdx])
		@tree.position.y -= 900
		@floor.activate(@colorGround[@colorIdx])
		@colorIdx++
		@colorIdx%=@colorTree.length
		return

	update:(dt)=>
		if(Stage3d.control.vx<0)
			Stage3d.control.theta += .01
		else
			Stage3d.control.theta -= .01
		return

module.exports = Main
