Branch = require('./Branch')

Stage3d 		= require("makio/core/Stage3d")
Stage 	= require("makio/core/Stage")
Components		= require("Components")

class Tree extends THREE.Object3D

	constructor:(@color)->

		@epsilonTheta = Components.getSliderID('epsilonTheta').target#0.003*(Math.random()-.3)
		@epsilonPhi = Components.getSliderID('epsilonPhi').target#0.012*(Math.random()-.3)
		@radius = Components.getSliderID('shapeRadius').target #Math.random()/2
		@time = 0
		@branchs = []
		@hidding = false
		@max = Math.floor(20+60*Math.random())
		if(isMobile.any)
			@max/=2
		super()

		@makeBranch()
		Stage3d.add(@)
		Stage.onUpdate.add(@update)
		return

	update:(dt)=>
		if(@hidding || dt>32 || @children.length>@max)
			return
		@time += dt
		if(@time>70)
			@time-=70
			@makeBranch()
		return

	makeBranch:()=>
		branch = Branch.POOL.checkOut()
		branch.init(@color,@epsilonTheta,@epsilonPhi,@radius)
		@add(branch)
		@branchs.push(branch)
		return

	hide:()->
		if(@hidding)
			return
		@hidding = true
		for b in @branchs
			b.hide()
		TweenMax.delayedCall(2.5,@dispose)
		return

	dispose:()=>
		Stage.onUpdate.remove(@update)
		@branchs = null
		Stage3d.remove(@)
		return

module.exports = Tree
