class Category < ActiveRecord::Base
  include Sluggable

  acts_as_nested_set
  has_many :products

  validates :name, presence: true

  def self.create_hierarchy(*categories)
    categories = [categories].flatten
    return [] if categories.empty?
    last = nil
    categories.map do |category|
      current = Category.find_or_create_by(name: category, parent: last)
      last    = current
    end
  end

  def to_param
    slug
  end

  def cover_product
    products_for(:self_and_descendants).first
  end

  def products_for(relation)
    ids = send(relation).pluck(:id)
    Product.where(category_id: ids)
  end
end
