class @ProductCard
  constructor: (options) ->
    @card = $(options.element)
    @image = @card.find('.product-image')

  init: ->
    @markAsInitialized()
    @attachModal()

  markAsInitialized: ->
    @card.addClass('cardified')

  attachModal: ->
    @image.on 'click', (e) =>
      console.log @image
      if $(window).width() < 540
        window.location = @image.data("link")
      else
        # Preventing default action will make links unusable inside .panel-body
        # e.preventDefault()
        $.getScript "#{@image.data('link')}.js"

$.fn.productCardify = ->
  @each ->
    card = new ProductCard element: @
    card.init()
