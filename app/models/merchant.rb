class Merchant < ActiveRecord::Base
  include Sluggable

  has_many :brands, dependent: :destroy, autosave: true
  has_many :products, dependent: :destroy, autosave: true

  validates :name, presence: true, uniqueness: true, length: { within: 2..20 }
  validates :brands_count, numericality: { only_integer: true }

  def to_s
    name.try :titleize
  end

  def to_param
    slug
  end

  def identifier
    to_s.parameterize.to_sym
  end

  def cover_product
    products.first
  end
end
