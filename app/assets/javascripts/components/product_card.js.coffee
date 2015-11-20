# Class to implement command JS behaviour to CSS class `.productCard`.
# At the moment, it allows:
#
# - opening a modal with product info if viewport width is sufficient
# - otherwise, redirects to the product info page
#
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
      if $(window).width() < 540
        window.location = @image.data("link")
      else
        # Preventing default action will make links unusable inside .panel-body
        # e.preventDefault()
        $.getScript "#{@image.data('link')}.js"

$.fn.productCardify = ->
  @each -> new ProductCard(element: @).init()
