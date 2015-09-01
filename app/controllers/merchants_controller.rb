class MerchantsController < ApplicationController
  before_action :set_merchant, only: [:show]

  def index
    @merchants = Merchant.all.page params[:page]
  end

  def show
    @products = @merchant.products.page params[:page]
  end

  private

  def set_merchant
    @merchant = Merchant.find(params[:id])
  end
end
