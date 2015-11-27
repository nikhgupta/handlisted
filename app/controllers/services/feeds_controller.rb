class Services::FeedsController < ApplicationController
  def recent
    @products = Product.all.order(created_at: :desc).limit(30)
    respond_to do |format|
      format.rss { render layout: false }
    end
  end
end
