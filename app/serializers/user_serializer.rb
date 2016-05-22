class UserSerializer < ActiveModel::Serializer
  # has_many :liking
  # has_many :found_products

  attributes :id, :name, :slug, :username, :email, :admin
  attributes :gender, :image

  # N+1 queries for produts index
  # attributes :counters
  # attributes :badges

  def counters
    {
      found: object.found_products_count,
      liked_by: object.likes_gained_count,
      likes_count: object.likes_count
    }
  end
end
