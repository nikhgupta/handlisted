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
        $.magnificPopup.open
          removalDelay: 500
          items:
            src: @card.find('.product-info')
          callbacks: beforeOpen: (e) ->
            @st.mainClass = "mfp-zoomIn"
          midClick: true

$.fn.productCardify = ->
  @each ->
    card = new ProductCard element: @
    card.init()
