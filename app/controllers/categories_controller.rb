class CategoriesController < ApplicationController
  before_action :set_category, only: [:show]

  def index
    @categories = Category.roots.page(params[:page])
  end

  def show
    @products = @category.self_and_descendants_products.page(params[:page])
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end
end
