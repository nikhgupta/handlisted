<products-listing>
  <div class="row products list">
    <div class="col-sm-6 col-md-4" each={item in products}>
      <product-card product={item}/>
    </div>
  </div>

  <div class="paginator"><raw content="{ paginator }"/></div>

  <script type="text/coffee">
    @products   = opts.products
    @paginator  = opts.paginator
    @pagination = $(".pagination", @root)
    @ajaxLoader = '<img src="/images/ajax-loader.gif" alt="Ajax loader" />'
    @pagingUrl  = @pagination.find("a[rel='next']").attr("href")

    @reachedEnd = =>
      $(window).scrollTop() > $(document).height() - $(window).height() - opts.offset

  </script>
</products-listing>
