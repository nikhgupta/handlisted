# Class to implement command JS behaviour to CSS class `.productCard`.
# At the moment, it allows:
#
# - opening a modal with product info if viewport width is sufficient
# - otherwise, redirects to the product info page
#
class @ProductCard
  constructor: (options) ->
    @card    = $(options.element)
    @type    = options.type
    @image   = @card.find('.product-image')
    @related = @card.find('.related-product')

  init: ->
    @markAsInitialized()
    @attachModal() if @type is "default"
    @attachToRelatedProducts() if @type is "overview"

  markAsInitialized: ->
    @card.addClass('cardified')

  _openModalOrPage: (nodes, cb) ->
    nodes.on 'click', (e) ->
      url = cb($(@))
      if $(window).width() < 540
        window.location = url
      else
        e.preventDefault()
        $.getScript "#{url}.js"


  attachModal: ->
    @_openModalOrPage @image, (node) -> node.data('link')

  attachToRelatedProducts: ->
    @_openModalOrPage @related, (node) -> node.find(".product-image").data('link')

$.productCardify = (namespace) ->
  mapping = { default: "", mini: "-mini", overview: "-overview" }
  for key, val of mapping
    $(".#{namespace}#{val}:not(.cardified)").each ->
      new ProductCard(element: @, type: key).init()
