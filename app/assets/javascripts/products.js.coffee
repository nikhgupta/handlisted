$ ->
  card = $('.product-card')

  card.each ->
    image = $(@).find('.product-image')
    url   = image.attr 'data-image'
    image.css 'background-image', "url('#{url}')"
    image.removeAttr "data-image"

  card.find('.panel-body').on 'click', (e) ->
    e.preventDefault()
    # window.location = $(@).find('.product-image').attr('data-link')
    $.magnificPopup.open
      removalDelay: 500
      items:
        src: $(@).parents('.product-card').find('.product-info')
      callbacks: beforeOpen: (e) ->
        @st.mainClass = "mfp-zoomIn"
      midClick: true
