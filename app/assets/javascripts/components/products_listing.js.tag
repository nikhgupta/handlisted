<products-listing>
  <div if="{ products && products.length > 0 }" class="row products list {mini: opts.mini} {group: opts.group }">
    <div class="{opts.class || 'col-sm-6 col-md-3'} products-container" each={item in products}>
      <product-card product={item}/>
      </div>
    </div>

    <div class="paginator" if="{ !(infiscroll.pagination.last_page && infiscroll.pagination.first_page) && !(infiscroll.pagination.last_page && opts.no_end_notice) }" >
      <div class="pagination bg-header has-loader">
        <a if={ !ajaxip && !infiscroll.pagination.last_page } class='load-more' href="{infiscroll.url}?page={infiscroll.pagination.next_page}" rel="next">Load More</a>
        <img if={ ajaxip} src='/images/ajax-loader.gif' width="40" height="40"/>
        <strong if={ infiscroll.pagination.last_page }>Whoa! You've reached the end of the world!</strong>
      </div>
    </div>
  </div>
  <p if="{!products || products.length == 0}" class="alert alert-info">No matching products were found!</p>

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
    @mixin(window.InfiniteScrolling)

    @createInfiniteScroll
      offset: opts.offset || 200,
      resource_group: opts.group,
      resource_paging: opts.per_page,
      resource: opts.products || [],
      url: opts.url || "/products.json",
      url_params: opts.url_params || {},
      url_path_prefix: opts.url_path_prefix || "products",
      load_more_elem: opts.load_more_elem || "a.load-more",
      pagination: { last_page: false, next_page: 2, first_page: true }
    @products = @infiscroll.resource

  </script>
</products-listing>
