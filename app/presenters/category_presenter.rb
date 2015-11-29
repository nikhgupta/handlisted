class CategoryPresenter < ApplicationPresenter
  def breadcrumbs
    (model.ancestors << model).take(4).map do |cat|
      h.present(cat).link
    end.join("<br/> #{h.fa_icon 'angle-right'} ").html_safe
  end

  def link
    h.link_to model.name, h.category_path(model)
  end

  def cover_image(options = {})
    featured = model.products.last
    return h.image_path("product-missing.png") if featured.blank?
    h.present(featured).cover_image
  end

  def total_products(*args)
    scope = model.products
    scope.where(*args) if args.any?
    scope.count
  end
end
