# TODO: pid should be unique across providers
class Product < ActiveRecord::Base
  include Sluggable
  slug_scoped_to :provider

  belongs_to :user
  belongs_to :provider

  validates :provider_id, presence: true
  validates_associated :provider, presence: true

  acts_as_commentable
  acts_in_relation role: :target, source: :user, action: :like

  monetize :price_cents, with_model_currency: :currency
  monetize :marked_price_cents, with_model_currency: :currency

  def cover_image
    images.first
  end

  def images
    super.map{|image| provider.image_for_key(image)}
  end

  def to_s
    name
  end

  def to_param
    "#{provider.slug}/#{slug}"
  end

  def slug_candidates
    [:name, :original_name, [:name, :brand_name], [:name, :brand_name, :provider]]
  end
end
