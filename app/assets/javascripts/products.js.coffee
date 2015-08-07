$ ->
  card = $('.product-card')

  card.each ->
    image = $(@).find('.product-image')
    url   = image.attr 'data-image'
    image.css 'background-image', "url('#{url}')"
    image.removeAttr "data-image"
    image.addClass('has-image')

  card.find('.panel-body').on 'click', (e) ->
    # Preventing default action will make links unusable inside .panel-body
    # e.preventDefault()
    $.magnificPopup.open
      removalDelay: 500
      items:
        src: $(@).parents('.product-card').find('.product-info')
      callbacks: beforeOpen: (e) ->
        @st.mainClass = "mfp-zoomIn"
      midClick: true
