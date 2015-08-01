$ ->
  card = $('.product-card')

  card.each ->
    image = $(@).find('.product-image')
    url   = image.attr 'data-image'
    image.css 'background-image', "url('#{url}')"
    image.removeAttr "data-image"

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

  card.find('a[data-like]').on 'click', (e) ->
    e.preventDefault()

    req = $.ajax
      method: "post"
      url: $(this).attr('href')
      data: status: $(this).attr('data-like')

    req.fail (e) =>
      error = $(@).parents('.product-card').find('.error')
      setTimeout (-> error.hide()), 4000
      error.html(e.responseJSON.message)
      error.show()

    req.then (response) =>
      $(@).attr('data-like', response.liking)
      hasClass = if response.liking == "on" then 'fa-heart' else 'fa-heart-o'
      $(@).find('i.fa').removeClass('fa-heart fa-heart-o').addClass(hasClass)
