class Merchant < ActiveRecord::Base
  include Sluggable

  has_many :brands, dependent: :destroy, autosave: true
  has_many :products, dependent: :destroy, autosave: true

  validates :name, presence: true, uniqueness: true, length: { within: 2..20 }
  validates :brands_count, numericality: { only_integer: true }

  def to_s
    name.try :titleize
  end

  def identifier
    to_s.parameterize.to_sym
  end

  def image_for_key(key)
    case identifier
    when :amazon then "http://ecx.images-amazon.com/images/I/#{key}.jpg"
    else key
    end
  end

  def affiliate_link_for(url)
    case identifier
    when :amazon then "#{url}/?shabd-20"
    when :flipkart then "#{url}?affid=menikhgup"
    else url
    end
  end

  def has_price?
    price_cents > 0
  end

  def available?
    has_price? && available?
  end
end
