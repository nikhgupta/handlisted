class MerchantSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug
  attributes :brands_count
  # attributes :products_count # requires N+1 queries
  has_many :brands
  has_many :products

  def products_count
    object.product_ids.count
  end
end
