class MerchantsController < ApplicationController
  include Products::Collection

  def show
    @header = "<span>Products from</span> #{@merchant.name.titleize}"
    super # calls up show action in Products::Collection
  end
end
