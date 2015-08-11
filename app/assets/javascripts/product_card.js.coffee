class @ProductCard
  constructor: (options) ->
    @card = $(options.element)

  init: ->
    @markAsInitialized()
    @addBackgroundImage()
    @attachModal()

  markAsInitialized: ->
    @card.addClass('cardified')

  addBackgroundImage: ->
    image = @card.find('.product-image:not(.has-image)')
    image.css 'background-image', "url('#{image.attr("data-image")}')"
    image.addClass('has-image').removeAttr("data-image")

  attachModal: ->
    @card.find('.panel-body').on 'click', (e) =>
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
