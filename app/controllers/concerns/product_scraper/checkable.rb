require 'active_support/concern'

module ProductScraper::Checkable
  extend ActiveSupport::Concern

  def verify_url
    respond_to do |format|
      format.json { render json: response_hash.to_json }
    end
  end

  private

  def find_product_info
    ProductScraper.uuid(params['search'])
  rescue StandardError => e
    { error: e.message, error_class: e.class }
  end

  def valid?
    @info ||= find_product_info
    @info && @info.has_key?(:uuid)
  end

  def existing_product_path
    return unless valid?
    product = Product.find_by(url_hash: @info[:uuid])
    return unless product
    product_path(product)
  end

  # FIXME: key `valid` is not really required here!
  def response_hash
    { valid: valid?, existing: existing_product_path }.merge(find_product_info)
  end
end
