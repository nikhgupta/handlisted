class CategorySerializer < ActiveModel::Serializer
  has_one  :parent
  has_many :children
  has_many :products
  has_many :leaves
  has_many :siblings
  has_many :ancestors

  attributes :id, :name, :slug
  attributes :depth
  attributes :products_count

  # N+1 queries for products index:
  # attributes :ancestors_list, :leaves_list

  def ancestors_list
    object.ancestors.map(&:name)
  end

  def leaves_list
    object.leaves.map(&:name)
  end
end
