#= require components/product_card
#= require components/product_adder
#= require components/product_paginator

ready = ->
  $.productCardify('productCard')

  # allow pagination of product cards
  new ProductPaginator(offset: 200).init()

  # Sidekiq Queue results on Search/Add Product Page
  window.product_adder = new ProductAdder(
    form:  '.navbar-search',
    input: '#product_search'
    default_input_text: "Search.."
    endpoints:
      status: "/products/create/status.json"
      check: "/products/create/check.json"
      add: "/products.json"
  )
  window.product_adder.init()

$(document).ready(ready)
$(document).on('pages:load', ready)
