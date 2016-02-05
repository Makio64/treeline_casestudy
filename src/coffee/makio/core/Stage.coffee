signal 	= require("signals")

#---------------------------------------------------------- Class Stage

class Stage

	@dt 			= 0
	@lastTime 		= 0
	@pause 			= false

	@onResize 	= new signal()
	@onUpdate 	= new signal()
	@onBlur 	= new signal()
	@onFocus 	= new signal()

	@init:()->
		@pause = false

		window.onresize = ()=>
			width 	= window.innerWidth
			height 	= window.innerHeight
			@onResize.dispatch()
			return

		@lastTime = Date.now()

		requestAnimationFrame( @update )

		return

	@update:()=>
		t = Date.now()
		dt = t - @lastTime
		@lastTime = t

		if @pause then return

		# update logic here
		@onUpdate.dispatch(dt)

		# render frame
		requestAnimationFrame( @update )
		return

	@init()

module.exports = Stage
