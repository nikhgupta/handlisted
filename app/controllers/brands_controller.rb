class BrandsController < ApplicationController
  before_action :set_merchant
  before_action :set_brand, only: [:show]

  def index
    @brands = @merchant.brands.all.page params[:page]
  end

  def show
    @products = @brand.products.page params[:page]
  end

  private

  def set_merchant
    @merchant = Merchant.find(params[:merchant])
  end

  def set_brand
    @brand = @merchant.brands.find(params[:brand])
  end
end
