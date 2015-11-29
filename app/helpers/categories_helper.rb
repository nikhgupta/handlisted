module CategoriesHelper
  def featured_categories(count = 5)
    Category.where("products_count > ?", 0).shuffle.take(count)
    # Category.order(products_count: :desc).limit(3)
  end
end
