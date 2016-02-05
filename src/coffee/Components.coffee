Signal = require('signals')
Stage = require('makio/core/Stage')
class Components

	@init:()->
		divs = document.querySelectorAll('.slider')
		@sliders = []
		@buttons = []
		for d in divs
			@sliders.push(new Slider(d))
		divs = document.querySelectorAll('.toogleButton')
		for d in divs
			@buttons.push(new Button(d))
		return

	@getSliderID:(id)->
		for s in @sliders
			if s.id == id
				return s
		return

	@getButtonID:(id)->
		for s in @buttons
			if s.id == id
				return s
		return
class Slider

	constructor:(@div)->
		@easing = 0.15
		@id = @div.id
		@onChange = new Signal()
		@base = document.createElement('div')
		@base.className = 'base'
		@div.addEventListener('click',@onClick)
		@div.addEventListener('touchStart',@onClick)
		@percent = document.createElement('div')
		@percent.className = 'percent'
		@baseText = @div.innerHTML
		@div.innerHTML = ''
		@text =  document.createElement('div')
		@text.className = 'text'
		@text.innerHTML = @baseText
		@div.appendChild(@base)
		@div.appendChild(@percent)
		@div.appendChild(@text)
		@target = 0
		return

	onClick:(e)=>
		e.stopPropagation()
		e.preventDefault()
		e.stopImmediatePropagation()
		percent = e.layerX/@div.clientWidth
		if(percent<0) then return
		percent = parseFloat(percent).toFixed(2)
		@percent.style.transform = "scaleX(#{percent})"
		@target = percent*(@max-@min)+@min
		@onChange.dispatch(percent)
		@text.innerHTML = @baseText+': '+parseFloat(@target).toFixed(4)
		return

	minMax:(@min,@max,@target)=>
		percent = (@target-@min)/(@max-@min)
		percent = Math.max(0,Math.min(1,percent))
		percent = parseFloat(percent).toFixed(2)
		@percent.style.transform = "scaleX(#{percent})"
		@text.innerHTML = @baseText+': '+parseFloat(@target).toFixed(4)
		return @

	ease:(@easing)=>
		return @

	add:(@obj,@value,@min,@max)->
		@target = @obj[@value]
		percent = (@target-@min)/(@max-@min)
		percent = Math.max(0,Math.min(1,percent))
		percent = parseFloat(percent).toFixed(2)
		@percent.style.transform = "scaleX(#{percent})"
		@text.innerHTML = @baseText+': '+parseFloat(@target).toFixed(4)
		Stage.onUpdate.add(@update)
		return

	update:(dt)=>
		@obj[@value] += (@target - @obj[@value])*@easing
		return

class Button

	constructor:(@div)->
		@id = @div.id
		@div.addEventListener('click',@onClick)
		@div.addEventListener('touchStart',@onClick)
		@onClick = new Signal()
		@_isOn = false
		return

	isOn:(@_isOn)=>
		return @

	delay:(time)->
		return @

	onClick:(e)=>
		@_isOn = !@_isOn
		@onClick.dispatch(@_isOn)
		return

Components.init()

module.exports = Components
