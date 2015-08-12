class @ProductCard
  constructor: (options) ->
    @card = $(options.element)

  init: ->
    @markAsInitialized()
    @attachModal()

  markAsInitialized: ->
    @card.addClass('cardified')

  attachModal: ->
    @card.find('.product-image').on 'click', (e) =>
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
