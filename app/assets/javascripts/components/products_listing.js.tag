<products-listing>
  <div class="row products list {mini: opts.mini} {group: opts.group }">
    <div class="{opts.class || "col-sm-6 col-md-3"} products-container" each={item in products}>
      <product-card product={item}/>
      </div>
    </div>

    <div class="paginator" if="{ !(pagination.last_page && pagination.first_page) && !(pagination.last_page && opts.no_end_notice) }" >
      <div class="pagination bg-header has-loader">
        <a if={ !ajax_in_progress && !pagination.last_page } class='load-more' href="{url}?page={pagination.next_page}" rel="next">Load More</a>
        <img if={ ajax_in_progress} src='/images/ajax-loader.gif' width="40" height="40"/>
        <strong if={ pagination.last_page }>Whoa! You've reached the end of the world!</strong>
      </div>
    </div>
  </div>

  <style type='text/scss'>
    .paginator {
      margin: -10px -25px 0;
      .pagination {
        padding: 20px;
      }
      .bg-header {
        width: 100%;
        background: rgba(0,0,0,0.07);
        padding: 10px;
        text-align: center;
        margin: 0;
        border-radius: 0;
        a {
          color: #444;
          font-weight: bold;
        }
      }
    }
  </style>

  <script type="text/coffee">
    @path_prefix = opts.path_prefix || "products"
    @products    = opts.products || []
    @pagination  = {last_page: opts.last_page, next_page: 2, first_page: true}
    @reachedEnd  = => $(window).scrollTop() > $(document).height() - $(window).height() - opts.offset
    @ajax_in_progress = false
    @url = opts.url || "/products.json?"
    @params = opts.params || {}

    @loadMoreProductsFrom = (url, callback = ->) =>
      return unless url?
      @ajax_in_progress = true; @update()
      options = $.extend {}, @params, { group: opts.group, per_page: opts.paging}
      $.get url, options, (response, status, xhr) =>
        $.merge @products, response
        callback(response)
        @pagination = $.parseJSON xhr.getResponseHeader("X-Pagination")
        @ajax_in_progress = false; @update()

    @on 'mount', =>
      $(window).scroll =>
        el = $("a.load-more.clicked", @root)
        return unless @reachedEnd() and el.length > 0
        @loadMoreProductsFrom el.attr("href")

      $("a.load-more", @root).on 'click', (e) =>
        e.preventDefault()
        $("a.load-more", @root).addClass('clicked')
        @loadMoreProductsFrom $(e.target).attr('href')

      (@loadMoreProductsFrom opts.url if opts.url?) unless @products.length > 0

  </script>
</products-listing>
