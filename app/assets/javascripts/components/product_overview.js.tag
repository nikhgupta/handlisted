<product-overview>
  <div id="{ product.id }" class="product overview bg-transparent">
    <div class="row jumbotron" data-pages="parallax">
      <div class="container-fluid container-fixed-lg sm-p-l-20 sm-p-r-20">
        <div class="inner">
          <ul class="breadcrumb">
            <li><a href='/merchants/{ product.merchant.slug }'>{ product.merchant.name }</a></li>
            <li if={ product.brand }> <a href='/brands/{ product.merchant.slug }/{product.brand.slug}'>{ product.brand.name}</a> </li>
          </ul>

          <div class="container-md-height m-b-20">
            <div class="row row-md-height">

              <div class="col-md-6 col-md-height col-middle">
                <product-card product={product}></product-card>
              </div>

              <div class="col-md-height col-md-6 col-top">
                <div class="panel panel-transparent">
                  <div class="panel-heading p-t-0 m-b-10">
                    <div class="panel-title">{ product.name }</div>
                  </div>
                  <div class="panel-body">
                    <div class='row'>
                      <div class='col-xs-12 col-sm-6 col-md-12'>
                        <a target="_blank" class="btn affiliate-button btn-{ aff_btn}" href="{ product.merchant_url }">
                          <span class="bold"><raw content="{ product.display_price }"/> on { product.merchant.name }</span>
                          <i class="fa fa-external-link"></i>
                        </a>
                        <h3 class='m-b-20 founder'>Found by <a href="/{product.founder.slug}">@{ product.founder.username }</a></h3>
                        <raw content="{ opts.social_sharing }" />
                      </div>
                      <div class='col-xs-12 col-sm-6 col-md-12'>
                        <users-listing url="/products/{product.slug}/likers.json" primary={product.founder}></users-listing>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div if={ product.note } class='panel panel-default product-note bg-master'>
      <div class='panel-heading text-center'>
        <div class='panel-title text-warning'>Editor's Note</div>
      </div>
      <div class='panel-body'>
        <raw content="{ product.note }" />
      </div>
    </div>

    <div if={ product.description && !product.note } class='panel panel-default product-description m-t-20'>
      <div class='panel-heading'>
        <div class='panel-title'>Product Description</div>
      </div>
      <div class='panel-body'>
        <raw content="{ product.marked_description }" />
      </div>
    </div>

    <div class="row">
      <div class="col-md-12">
        <div class='panel panel-transparent related-products'>
          <div class='panel-heading'>
            <div class='panel-title'>Related Products</div>
          </div>
          <div class='panel-body'>
            <products-listing mini=true group="related" url="/products/{product.slug}/related.json" paging=4 no_end_notice=true />
          </div>
        </div>
      </div>
    </div>
    <div class="row">
      <div class="col-md-12">
        <div class='panel product-comments'>
          <div class='panel-heading'>
            <div class='panel-title'>Comments/Reviews</div>
          </div>
          <div class='panel-body'>
            <product-comments comments={ product.comments}></product-comments>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script type='text/coffee'>
    @product = opts.product
    @current_user = opts.current_user
    price  = @product.price.replace(/[^0-9\.]/g, '')
    marked = @product.marked_price.replace(/[^0-9\.]/g, '')
    @aff_btn = if opts.product.available and price > 0 then "success" else "light"

    @on 'mount', =>
      # console.log opts.product.comments
      # console.log "mounted product overview"
  </script>
</product-overview>
