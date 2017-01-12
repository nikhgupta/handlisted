module CategoriesHelper
  def breadcrumbs_for(category)
    (category.ancestors << category).take(4).map do |cat|
      link_to(cat.name, category_path(cat))
    end.join("<br/> #{fa_icon 'angle-right'} ").html_safe
  end

  def cover_image_for(category, options = {})
    featured_product = category.products.last
    return featured_product.images.first if featured_product && featured_product.images.try(:any?)
    return image_path("product-missing.png")
  end

  def featured_categories(count = 5)
    Category.with_default_includes.where("products_count > ?", 0).shuffle.take(count)
  end
end
