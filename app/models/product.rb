class Product < ActiveRecord::Base
  include Sluggable

  belongs_to :founder, class_name: "User", validate: true, counter_cache: :found_products_count
  belongs_to :brand, validate: true, counter_cache: true
  belongs_to :category, validate: true, counter_cache: true
  belongs_to :merchant, validate: true, required: true

  before_validation :populate_merchant_info_from_brand
  validates :pid, presence: true, uniqueness: { scope: :merchant_id }
  validates :original_name, presence: true
  validates :url, presence: true
  validates :price_currency, presence: true
  validates :marked_price_currency, presence: true
  validates :price_cents, numericality: { only_integer: true }
  validates :marked_price_cents, numericality: { only_integer: true }
  validates :ratings_count, numericality: { only_integer: true }
  validates :average_rating, inclusion: { in: 0..100 }
  validate  :brand_belongs_to_merchant?

  scope :featured, ->{ Product.order(created_at: :desc) }

  acts_as_commentable
  acts_in_relation role: :target, source: :user, action: :like

  monetize :price_cents, with_model_currency: :price_currency
  monetize :marked_price_cents, with_model_currency: :marked_price_currency

  delegate :name, to: :brand, prefix: true, allow_nil: true
  delegate :name, to: :merchant, prefix: true, allow_nil: true

  # TODO: use ranked_by to rank better products higher
  include PgSearch
  pg_search_scope :search, against: {
    name: "A",
    original_name: "A",
    note: "B",
    features: "C",
    description: "D",
  }, associated_against: {
    merchant: :name,
    brand: :name,
  }, using: {
    tsearch: {
      prefix: true,
      dictionary: 'english',
      normalization: 63
    }
  }, order_within_rank: 'average_rating DESC'

  def to_s
    return name if name.present?
    original_name
  end

  def to_param
    slug
  end

  def slug_candidates
    [:to_s, [:to_s, :brand_name], [:to_s, :brand_name, :merchant_name]]
  end

  def cover_image
    images.try :first
  end

  def images
    super.try :map do |image|
      image.start_with?('http') ? image : "http://#{image}"
    end
  end

  def affiliate_link
    scheme = Rails.application.secrets.affiliate_urls[merchant.identifier.to_s]
    scheme.gsub("{url}", url)
  end

  private

  def brand_belongs_to_merchant?
    return unless brand.present?
    errors.add(:brand, "does not belong to this merchant") unless brand.merchant == merchant
  end

  def populate_merchant_info_from_brand
    return if merchant.present? || brand.blank?
    self.merchant = brand.merchant
  end
end
