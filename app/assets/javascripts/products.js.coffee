#= require components/products/cards
#= require components/products/paginator

$.productCardify = (namespace) ->
  mapping = { default: "", mini: "-mini", overview: "-overview" }
  for key, val of mapping
    $(".#{namespace}#{val}:not(.cardified)").each ->
      new ProductCard($(@), key).init()

ready = ->
  $.productCardify("productCard")

  # allow pagination of product cards
  new ProductPaginator(offset: 200).init()

$ -> ready()
