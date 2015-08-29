class Category < ActiveRecord::Base
  acts_as_nested_set
  has_many :products

  validates :name, presence: true

  def self.create_hierarchy(*categories)
    categories = [categories].flatten
    return if categories.empty?
    last = nil
    categories.map do |category|
      current = Category.find_or_create_by(name: category, parent: last)
      last    = current
    end
  end
end
