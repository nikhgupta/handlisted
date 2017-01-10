<category-card>
  <div class='category card panel panel-default'>
    <div class='panel-heading text-left'>
      <div class="panel-title hint-text breadcrumbs"><raw content={ category.breadcrumbs }></raw></div>
    </div>
    <div class='panel-body'>
      <div class='panel-image panel-image-centered'>
        <div class='image-container m-t-30' style="background-image: url('{ category.cover_image }')"></div>
      </div>
      <div>
        <h2 class="font-montserrat inline no-margin">
          {category.products_count }
          <small class='text-hint' if={ category.products_count < 2}>product</small>
          <small class='text-hint' if={ category.products_count > 1}>products</small>
        </h2>
        <a href="/shop/{category.slug}" class="btn btn-sm font-montserrat all-caps m-b-10 m-l-10">Browse</a>
      </div>
    </div>
  </div>

  <script type="text/coffee">
    @category = opts.category
  </script>
</category-card>
