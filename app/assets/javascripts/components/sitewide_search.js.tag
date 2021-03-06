<sitewide-search>
  <yield></yield>

  <div class="overlay sm-p-l-20 xs-p-l-0" style="display: none" data-pages="search">
    <div class="overlay-content {has-results: ((total && total > 0) || !!found_product)} m-t-20">
      <div class="container-fluid">
        <a href="/"><img class="overlay-brand" alt="logo" height="33" src="/images/handlisted-text-logo.png"></a>
        <a href="#" class="close-icon-light overlay-close text-black fs-16">
          <i class="pg-close"></i>
        </a>
      </div>

      <div class="container-fluid m-t-40">
        <input type="text" name="search" id="overlay-search" placeholder="Search..."
        class="no-border overlay-search bg-transparent" autocomplete="off" spellcheck="false">
        <!-- <br> -->
        <!-- <div class="inline-block"> -->
        <!--   <div class="checkbox right"> -->
        <!--     <input id="checkboxn" type="checkbox" value="1" checked="checked"> -->
        <!--     <label for="checkboxn"><i class="fa fa-search"></i> Search within page</label> -->
        <!--   </div> -->
        <!-- </div> -->

        <div show="{ ajax_wip }" class="ajax-loader inline-block">
          <img src='/images/ajax-loader.gif' width="32"/>
        </div>

        <div show="{!ajax_wip}" class="inline-block"><p class="fs-13">
            <strong if="{ import_status }">{ import_status }</strong>
            <strong if="{ query && total == 0 }">No products were found for your query!</strong>
            <strong if="{!query && !import_status}">Instant search upto 8 products or press Enter for in-depth search!</strong>
        </p></div>

        <div show="{ total && query && total > 8 }" class="inline-block">
          <a href="/products/search?search={query}" class="btn btn-primary btn-cons m-b-10">
            <i class="fa fa-search text-white"></i>
            <span class="bold text-white">View All</span>
          </a>
        </div>
        <div show="{url_to_import && !sidekiq_poll}" class="inline-block">
          <button class="btn btn-primary btn-cons m-b-10 product-importer" type="button">
            <a href="#" data-target="{url_to_import}">
              <i class="fa fa-plus text-white"></i>
              <span class="bold text-white">Import Product</span>
            </a>
          </button>
        </div>

        <progress-bar if="{ sidekiq_poll }" name="sidekiqbar"></progress-bar>
      </div>

      <div class="container-fluid m-t-30">
        <div if="{!ajax_wip && !found_product && total && total > 0}" class="search-results">
          <h3>Found Products</h3>
          <div class="products list mini">
            <div class="col-md-3 col-sm-6" style="padding-left: 0" each="{result in results}">
              <product-card product={result} mini="true"></product-card>
            </div>
          </div>
        </div>

        <!-- SEE: https://github.com/riot/riot/issues/1020 -->
        <div each="{!!found_product ? [1] : []}" class="row text-center found-product">
          <h3 class="fs-13 font-montserrat">Imported: {parent.found_product.name}</h3>
          <div class="panel panel-transparent search-results col-md-4 col-md-offset-4">
            <product-card product="{parent.found_product}"></product-card>
          </div>
        </div>
      </div>
    </div>
  </div>

  <style type='text/scss'>
    .noscroll { overflow: hidden; }

    .overlay {
      position: fixed;
      overflow-y: scroll;
      background-color: rgba(248,248,248,0.96);
      top: 0; right: 0; bottom: 0; left: 0;
      padding-left: 64px;
      .overlay-search {
        font-weight: 300;
        height: 120px;
        margin-bottom: 30px;
        border-bottom: 1px solid #ddd !important;
      }
      .card {
        border: 1px solid #e0e0e0;
      }

      .search-results {
        h3 { text-transform: uppercase; font-weight: 500; }
      }
      .progress,.overlay-search {
        width: calc(100% - 20px);
      }
    }

    [aria-hidden="true"]  { display: none; }
    [aria-hidden="false"] { display: block; }
  </style>

  <script type='text/coffee'>
    self = @; sidekiq_url = "/products/create/status.json"

    @updateSearch = (options) =>
      @[key] = value for key, value of options
      @update()

    @reset = (options = {}) =>
      defaults =
        results: [], total: null, ajax_wip: false, import_status: null,
        timer: null, poller: null, query: null, url_to_import: null,
        sidekiq_poll: false, found_product: null
      @tags?.sidekiqbar?.reset?()
      @updateSearch $.extend(defaults, options)

    @reset()

    @on 'mount', =>
      $(".product-importer a", @root).on 'click', (e) ->
        self.addProduct $(@).attr("data-target")

      search = $("[data-pages='search']", @root).search
        searchField: "#overlay-search"
        closeButton: ".overlay-close"
        suggestions: "#overlay-suggestions"
        searchResults: ".search-results"
        onKeyEnter: self.onKeyEnter
        getResults: self.getResults
        onSearchSubmit: self.onSearchSubmit
      .on 'hide', (e) => @reset()

    @onSearchSubmit = (query) =>
      query = query.replace /^\s+|\s+$/g, ""
      @getResults query, =>
        if @url_to_import?
          @addProduct query
        else
          window.location = "/products/search?search=#{query}"

    @onKeyEnter = (query) =>
      query = query.replace /^\s+|\s+$/g, ""
      return if self.query == query
      clearTimeout @timer
      @reset query: query, ajax_wip: query != ""
      @timer = setTimeout((=> @getResults(query)), 400) unless query is ""

    @getResults = (query, callback = (q) ->) =>
      $.post "/products/create/check.json", search: query, (response) =>
        if response.valid and response.existing?
          window.location = response.existing
        else if response.valid
          @updateSearch url_to_import: query, ajax_wip: false
          callback(query)
        else
          $.post '/products/search.json', search: query, (products) =>
            if @query == query
              @updateSearch ajax_wip: false, total: products.length, results: products.slice(0,8)
              callback(query)

    @addProduct = (url) =>
      @updateSearch url_to_import: null, sidekiq_poll: true, ajax_wip: true, pollResults: []
      $.post '/products.json', url: url, (response) =>
        @poller = setInterval (=> @pollSidekiq response.id), 1000 if response.id? and !@poller?

    @pollSidekiq = (job_id, callback = ->) =>
      return if job_id in @pollResults
      $.post sidekiq_url, { job_id: job_id }, (res) =>
        callback res
        progress = @tags.sidekiqbar
        progress.reset() if !@poller?
        progress.setStatus res.status.toLowerCase()
        if progress.has_delayed()
          clearInterval(@poller) and @pollResults.push(job_id)
          @updateSearch ajax_wip: false, import_status: "Import took a long time! Please, try again in a moment.."
        if res.status is "Queued"
          progress.setMinimumAndIncrement(10, 2)
        else if res.status is "Working"
          progress.setMinimumAndIncrement(40, 3)
        else if res.status is "Complete"
          $.get "/products/#{res.id}.json", (product) =>
            message = "Import was Successful! Congrats!"
            clearInterval(@poller) and @pollResults.push(job_id)
            @updateSearch ajax_wip: false, found_product: product, import_status: message
        else if res.status is "Failed"
          clearInterval(@poller) and @pollResults.push(job_id)
          @updateSearch ajax_wip: false, import_status: "Import Failed. Error: #{res.errors}"
        else if res.status is ""
          clearInterval(@poller) and @pollResults.push(job_id)
          @updateSearch ajax_wip: false, import_status: "Import failed due to unknown reasons!"
  </script>
</sitewide-search>
