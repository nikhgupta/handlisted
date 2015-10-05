require 'active_support/concern'

module ProductScraper::Checkable
  extend ActiveSupport::Concern

  def verify_url
    respond_to do |format|
      format.json { render json: response_hash.to_json }
    end
  end

  private

  def find_product_hash
    ProductScraper.url_hash_for(params[:search])
  rescue ProductScraper::Error
    nil
  end

  def valid?
    @hash ||= find_product_hash
    @hash.present?
  end

  def existing_product_path
    return unless valid?
    product = Product.find_by(url_hash: @hash)
    return unless product
    product_path(product)
  end

  # FIXME: key `valid` is not really required here!
  def response_hash
    { valid: valid?, existing: existing_product_path }
  end
end
