class CategoriesController < ApplicationController
  def index
    @categories = Category.roots.page(params[:page])
  end
end
