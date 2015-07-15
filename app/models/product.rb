class Product < ActiveRecord::Base
  belongs_to :user

  include Sluggable
  self.inheritance_column = :product_type

  validates :product_type, presence: true
  validates :pid, uniqueness: { scope: :product_type }

  scope :featured, ->{ Product.order(created_at: :desc) }

  acts_as_commentable
  acts_in_relation role: :target, source: :user, action: :like

  monetize :price_cents, with_model_currency: :currency
  monetize :marked_price_cents, with_model_currency: :currency

  def initialize(*args)
    raise NotImplementedError, "Cannot directly instantiate a Product" if self.class == Product
    super
  end

  def to_s
    name
  end

  def to_param
    "#{provider_slug}/#{slug}"
  end

  def slug_candidates
    [:name, :original_name, [:name, :brand_name]]
  end

  def provider
    product_type.gsub(/Product$/, '')
  end

  def provider_slug
    provider.titleize.parameterize
  end

  def cover_image
    images.first
  end

  def images
    super.map do |image|
      image.start_with?('http') ? image : yield(image)
    end
  end

  def affiliate_link; url; end
  def priority_service_name; end
end

class AmazonProduct < Product
  def images
    super{|image| "http://ecx.images-amazon.com/images/I/#{image}.jpg"}
  end

  def affiliate_link
    "http://www.amazon.com/dp/#{pid}/?tag=shabd-20"
  end

  def priority_service_name
    "Fulfilled by Amazon"
  end
end
