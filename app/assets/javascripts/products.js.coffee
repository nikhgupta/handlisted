
$ ->
  cardifyProducts = ->
    $('.product-card:not(.cardified)').productCardify()

  cardifyProducts()

  if $(".pagination").length
    url = $(".pagination a[rel='next']").attr("href")
    $('.pagination').replaceWith("<div class='bg-header pagination'><a class='load-more' href='#{url}'>Load More</a></div>")
    $('.pagination a.load-more').on 'click', (e) ->
      e.preventDefault()
      url = $(@).attr('href')
      $(@).replaceWith("<img src='/assets/ajax-loader.gif' width='30'/>")
      $.getScript url, =>
        cardifyProducts()
        $(@).remove()

    $(window).scroll ->
      url = $(".pagination a[rel='next']").attr('href')
      if url && $(window).scrollTop() > $(document).height() - $(window).height() - 100
        $('.pagination').html("<img src='/assets/ajax-loader.gif' width='30'/>")
        $.getScript(url, -> cardifyProducts())
    $(window).scroll(-> cardifyProducts())
