Stage = require "makio/core/Stage"

#---------------------------------------------------------- Class Preloader

class Preloader

	@loaderTarget = 0

	@fakeLoad = (dt)=>
		@loaderTarget += 0.0005*dt/16

	@init = ()=>
		document.removeEventListener('DOMContentLoaded', Preloader.init)
		document.querySelector( ".shares .facebook" ).addEventListener("click",@fb)
		document.querySelector( ".shares .twitter" ).addEventListener("click",@twitter)
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

	title = encodeURIComponent( "Treeline" )
	desc = encodeURIComponent( "Treeline - Webgl Case study by @makio64" )
	url = "http://www.makioandfloz.com/article/treeline/"
	urlEncoded = encodeURIComponent( url )

	@fb = ( e ) =>
		FB.ui({
			method: 'share',
			href: 'http://www.makiopolis.com/article/treeline'
		}, ( res ) => {} )
		return

	@twitter = ()=>
		url = "https://twitter.com/intent/tweet?text=" + desc + " " + urlEncoded
		window.open( url, title, "width=640,height=400" )
		return

	document.addEventListener('DOMContentLoaded', Preloader.init)

module.exports = Preloader
