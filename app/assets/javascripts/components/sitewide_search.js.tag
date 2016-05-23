<sitewide-search>
  <yield></yield>

  <div class="overlay" style="display: none" data-pages="search">
    <div class="overlay-content {has-results: total && total > 0} m-t-20">
      <div class="container-fluid">
        <a href="/"><img class="overlay-brand" alt="logo" height="33" src="/images/handlisted-text-logo.png"></a>
        <a href="#" class="close-icon-light overlay-close text-black fs-16">
          <i class="pg-close"></i>
        </a>
      </div>

      <div class="container-fluid">
        <input type="text" name="search" id="overlay-search" placeholder="Search..."
        class="no-border overlay-search bg-transparent" autocomplete="off" spellcheck="false">
        <br>
        <div class="inline-block">
          <div class="checkbox right">
            <input id="checkboxn" type="checkbox" value="1" checked="checked">
            <label for="checkboxn"><i class="fa fa-search"></i> Search within page</label>
          </div>
        </div>
        <div class="inline-block m-l-10">
          <p class="fs-13">Press enter to search</p>
        </div>
        <div if="{ ajax_wip }" class="inline-block m-l-10">
          <img src='/images/ajax-loader.gif' width="32"/>
        </div>
        <div if="{ total && query && total == 0 }" class="inline-block m-l-10">
          <p class="fs-13"><strong>No products were found for your query!</strong></p>
        </div>

        <div if="{ total && query && total > 8 }" class="inline-block m-l-10">
          <button class="btn btn-primary btn-cons m-b-10" type="button">
            <a href="/products/search?search={query}">
              <i class="fa fa-search text-white"></i>
              <span class="bold text-white">View All</span>
            </a>
          </button>
        </div>
      </div>

      <div class="container-fluid">
        <p if={waiting}><strong>Waiting for you to search something!</strong></p>
        <div if="{!ajax_wip}" class="panel panel-transparent search-results">
          <div class="panel-heading"><div class="panel-title">Found Products</div></div>
          <div class="panel-body">
            <div if="{total && total > 0}" class="row products list mini">
              <div class="col-md-3 col-sm-6" each="{result in results}">
                <product-card product={result} mini="true"></product-card>
              </div>
            </div>
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
      .card {
        border: 1px solid #e0e0e0;
      }
    }

    [aria-hidden="true"]  { display: none; }
    [aria-hidden="false"] { display: block; }
  </style>

  <script type='text/coffee'>
    self = @
    self.results = []
    self.total = null
    self.ajax_wip = false

    @getResults = (query, callback = ->) ->
      $.post '/products/search.json', search: query, (products) =>
        self.total   = products.length
        self.results = products.slice(0,8)
        self.ajax_wip = false
        self.update()

    @onKeyEnter = (query) ->
      clearTimeout @timer
      self.ajax_wip = true
      self.results = []
      self.query = query
      self.total = null
      self.update()
      @timer = setTimeout (=> @getResults(query)), 400

    @onSearchSubmit = (query) -> @onKeyEnter query

    @on 'mount', =>
      search = $("[data-pages='search']",  @root)
      search = search.search
        searchField: "#overlay-search"
        closeButton: ".overlay-close"
        suggestions: "#overlay-suggestions"
        searchResults: ".search-results"
        onKeyEnter: self.onKeyEnter
        onSearchSubmit: self.onSearchSubmit
        getResults: self.getResults

      search = search.data("pg.search")
      toggleOverlayOld = search.toggleOverlay
      search.toggleOverlay = (action, key) ->
        $(@).trigger("overlay.#{action}.before")
        toggleOverlayOld.apply(@, [action, key])
        if action is 'show'
          @$element.scrollTop = 0
          $("body").addClass 'noscroll has-overlay'
          @$element.attr("aria-hidden", false)
        else
          $("body").removeClass 'noscroll has-overlay'
          @$element.attr("aria-hidden", true)
        $(@).trigger("overlay.#{action}.after")

      # search.toggleOverlay('show')
  </script>
</sitewide-search>
