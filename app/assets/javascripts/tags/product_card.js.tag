<product-card>
  <div id="{ product.id }" class="product card panel panel-default" data-pid="{ product.pid }">
    <div class='panel-heading'>
      <div class="panel-title">
        <a href="{ product.merchant_url }" target="_blank" class="afflink">
          <raw content="{ product.display_price }"/> on <span>{ product.merchant.name }</span>
        </a>
      </div>

      <div class="panel-controls">
        <ul>
          <li>
            <a data-toggle="refresh" title="Re-import product information from { product.merchant.name }!"
              class="iconic-btn product-refresh" rel="nofollow" href="#" onclick={ refreshed }>
              <i class="fa fs-16 fa-refresh"></i>
            </a>
          </li>
          <li>
            <a target="_blank" title="Visit this product on { product.merchant.name }"
              class="iconic-btn product-visit" href="{ product.merchant_url }">
              <i class="fa fs-16 fa-external-link"></i>
            </a>
          </li>
          <li>
            <a class="{ active: product.states.liked } iconic-btn product-like" title="Like this product!" rel="nofollow" href='#' onclick={ liked }>
              <i class="fa fs-16 { fa-heart: product.states.liked} {fa-heart-o: !product.states.liked}"></i>
            </a>
          </li>
        </ul>
      </div>
    </div>

    <div class="panel-body">
      <div class='panel-image panel-image-centered' onclick={ view_details }>
        <div class='image-container' style="background-image: url('{ product.cover_image }')"></div>
      </div>

      <div class="overlayer bottom-left full-width">
        <div class="overlayer-wrapper item-info">
          <div class="p-l-20 p-r-20 p-t-20 p-b-5">
            <div class="item-footer">
              <p class="item-name pull-left fs-11 font-montserrat all-caps">
                <a href="{ product.url }">{ product.name }</a>
              </p>
              <p class="pull-right">
              </p>
              <div class="clearfix"></div>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>

  <style type="text/scss">
    @mixin opacity($opacity) {
      opacity: $opacity;
      $opacity-ie: ($opacity * 100);       // IE8 filter
      filter: alpha(opacity=$opacity-ie);
    }

    @mixin display-on-hover($child, $opacity: 1, $duration: 0.4s) {
      #{$child} { @include opacity(0); }
      .open-details & #{$child} { @include opacity(1); }
      &:hover #{$child} {
        @include opacity($opacity);
        transition: all $duration ease-in-out;
      }
    }

    @mixin centered-image-container($height: 300px, $ratio: 80%) {
      height: $height;
      position: relative;
      .image-container {
        top: 0; left: 0;
        right: 0;
        bottom: 0;
        margin: auto;
        width: $ratio;
        height: $ratio;
        position: absolute;
        background-size: contain;
        background-repeat: no-repeat;
        background-position: center;
      }
    }

    .product{
      margin-bottom: 10px;
      .panel-heading { max-height: 48px; }
      .founder { @media(max-width: 400px) { font-size: 22px; } }
      &.card{
        @include display-on-hover(".panel-title");
        @include display-on-hover(".item-footer");
        @include display-on-hover(".product-refresh.iconic-btn");

        width: 100%;
        text-align: left !important;

        .panel-heading {
          max-height: 48px;
          .afflink {
            @include opacity(1);
            .unavailable {
              @include opacity(0.5);
              font-weight: normal;
            }
          }
        }

        .panel-body {
          .panel-image-centered {
            @include centered-image-container(300px, 70%);
          }
          .item-footer p.item-name {
            width: 80%;
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
          }
        }

        a.iconic-btn { color: #aaa; }
        .product-like.active .fa { color: #f04; }

        &.mini {
          .panel-title span { display: none; }
          .panel-image {
            height: 128px !important;
          }
        }
      }
    }
  </style>

  <script type='text/coffee'>
    @product     = opts.product
    @url         = @product.url
    @sidekiq_url = "/products/create/status.json"

    @pollSidekiq = (job_id, callback = ->) =>
      $.post @sidekiq_url, { job_id: job_id }, (res) =>
        pbar = @card.find(".progress-bar-indeterminate")
        pbar.removeClass("progress-bar-default progress-bar-master")
        pbar.removeClass("progress-bar-warning progress-bar-danger")
        pbar.removeClass("progress-bar-success progress-bar-master")
        pbar.addClass("progress-bar-default") if res.status is ""
        pbar.addClass("progress-bar-master")  if res.status is "Queued"
        pbar.addClass("progress-bar-warning") if res.status is "Working"
        pbar.addClass("progress-bar-success") if res.status is "Complete"
        pbar.addClass("progress-bar-danger")  if res.status is "Failed"
        callback res

        if res.status not in ["Queued", "Working"]
          clearInterval @timer
          setTimeout ( =>
            error = "Could not update the product at the moment!"
            @card.portlet refresh: false
            @card.portlet error: error if res.status in ["", "Failed"]
          ), 1200
          $.get("#{@url}.json").done (product) =>
            @product = product
            @update()
        else if !@timer?
          @timer = setInterval (=> @pollSidekiq job_id, callback), 1000

    @refreshed = (e) =>
      $.post "#{@url}/reimport.json"
      .done (response) => @card.portlet
        refresh: true
        progress: 'bar'
        progressColor: 'default'
        onRefresh: => @pollSidekiq response.job_id

    @liked = (e) =>
      $.post "#{@url}/like.json", { like: @product.states.liked }
      .done (response) =>
        @product.states.liked = response.states.liked
        @update()
      .fail (xhr) => @card.portlet
        error: "Failed due to #{xhr.statusText}. Please, refresh the page and try again!"

    @view_details = (e) =>
      if $(window).width() < 540
        window.location = @url
      else
        $.get("#{@url}.json").done (response) =>
          console.log response

    @on 'mount', =>
      @card = $(".product.card", @root).addClass 'cardified'
  </script>
</product-card>
