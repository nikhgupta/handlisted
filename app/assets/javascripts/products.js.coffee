#= require tags/raw
#= require tags/product_card
#= require tags/products_listing

# $.productCardify = (namespace) ->
#   mapping = { default: "", mini: ".mini", overview: ".overview" }
#   for key, val of mapping
#     $("#{namespace}#{val}:not(.cardified)").each ->
#       new ProductCard($(@), key).init()

# ready = ->
#   $.productCardify(".product.card")

#   # allow pagination of product cards
#   new ProductPaginator(offset: 200).init()

# $ -> ready()
