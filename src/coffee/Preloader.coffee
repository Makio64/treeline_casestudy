Stage = require "makio/core/Stage"

#---------------------------------------------------------- Class Preloader

class Preloader

	@loaderTarget = 0

	@fakeLoad = (dt)=>
		@loaderTarget += 0.0005*dt/16

	@init = ()=>
		document.removeEventListener('DOMContentLoaded', Preloader.init)

		require.ensure(['Main'], (require)=>
			scene = require('Main')
			new scene(@onLoadPercent)
			@loaderTarget+=.25
		)
		return

	@onLoadPercent:(value)=>
		if(value>@loaderTarget)
			@loaderTarget=value
		if(value == 1)
			Stage.onUpdate.remove(@fakeLoad)
			@onLoaded()
		return

	@onLoaded:()=>
		return

	document.addEventListener('DOMContentLoaded', Preloader.init)

module.exports = Preloader
