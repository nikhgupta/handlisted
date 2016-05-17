class BrandSerializer < ActiveModel::Serializer
  belongs_to :merchant
  has_many :products

  attributes :id, :name, :slug
  attributes :average_rating, :ratings_count
  attributes :products_count
end
