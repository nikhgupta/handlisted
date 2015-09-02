class BrandsController < ApplicationController
  before_action :set_merchant
  before_action :set_brand,  only: [:show]
  before_action :set_brands, only: [:index]
  include ProductsContainable

  private

  def set_merchant
    @merchant = Merchant.find(params[:merchant])
  end

  def set_brand
    @brand  = @merchant.brands.find(params[:brand])
    @header = "#{@brand.name.titleize}<span>, a unique brand on #{@brand.merchant.name.titleize}</span>"
  end

  def set_brands
    @brands = @merchant.brands.all
    @header = "Available brands on #{@merchant.name.titleize}".titleize
  end
end
