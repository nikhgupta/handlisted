class CategoriesController < ApplicationController
  before_action :set_categories, only: [:index]
  include Products::Collection

  private

  def set_categories
    @categories = Category.roots
  end
end
