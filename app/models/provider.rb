class Provider < ActiveRecord::Base
  include Sluggable
  has_many :products

  self.inheritance_column = :name

  def to_s
    name
  end

  # `key` is the value of an element in `images` array of `Product`.
  # By default, we assume that we are storing full URL.
  def self.image_for_key(key); key; end
end

class Amazon < Provider
  def image_for_key(key)
    "http://ecx.images-amazon.com/images/I/#{key}.jpg"
  end
end

class Flipkart < Provider; end
