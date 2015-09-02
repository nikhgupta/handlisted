class MerchantsController < ApplicationController
  include ProductsContainable

  def show
    @header = "<span>Products from</span> #{@merchant.name.titleize}"
    super # calls up show action in ProductsContainable
  end
end
