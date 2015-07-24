class Brand < ActiveRecord::Base
  include Sluggable

  has_many :products, dependent: :nullify, autosave: true
  belongs_to :merchant, counter_cache: true, validate: true, required: true

  validates :average_rating, inclusion: 0..100
  validates :ratings_count, numericality: { only_integer: true }
  validates :products_count, numericality: { only_integer: true }
  validates :merchant_id, presence: true
  validates :name,
    presence: true,
    length: { within: 2..60 },
    uniqueness: { scope: :merchant_id }

  delegate :name, to: :merchant, prefix: true, allow_nil: true

  def to_s
    name
  end

  def to_param
    "#{merchant.slug}/#{slug}"
  end

  def slug_candidates
    [:name, [:merchant_name, :name]]
  end
end
