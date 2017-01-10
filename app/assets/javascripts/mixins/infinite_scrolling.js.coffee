@InfiniteScrolling =
  init: ->
    @on 'mount', ->
      $(window).scroll =>
        el = $("#{@infiscroll.load_more_elem}.clicked", @root)
        return unless @reachedEnd() and el.length > 0
        @loadMoreProductsFrom el.attr("href")

      $(@infiscroll.load_more_elem, @root).on 'click', (e) =>
        e.preventDefault()
        $(@infiscroll.load_more_elem, @root).addClass('clicked')
        @loadMoreProductsFrom $(e.target).attr('href')

      (@loadMoreProductsFrom @infiscroll.url if @infiscroll.url?) unless @infiscroll.resource.length > 0

  reachedEnd: ->
    $(window).scrollTop() > $(document).height() - $(window).height() - @infiscroll.offset

  loadMoreProductsFrom: (url, callback = ->) ->
    return unless url?
    @ajaxip = true; @update()
    url_params = $.extend {}, @infiscroll.url_params, { group: @infiscroll.resource_group, per_page: @infiscroll.resource_paging}
    $.get url, url_params, (response, status, xhr) =>
      $.merge @infiscroll.resource, response
      callback(response)
      @infiscroll.pagination = $.parseJSON xhr.getResponseHeader(@infiscroll.pagination.header)
      @ajaxip = false; @update()

  createInfiniteScroll: (opts, update) ->
    @ajaxip = false
    @infiscroll = opts
    @update unless update
