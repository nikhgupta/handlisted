class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :username, :email, :admin
  attributes :gender, :image

  # N+1 queries for products index
  attributes :counters, :badges, :liking, :found_products

  def counters
    {
      found: object.found_products_count,
      liked_by: object.likes_gained_count,
      likes_count: object.likes_count
    } if detailed?
  end

  def badges
    object.badges if detailed?
  end

  # TODO: Paginate this?
  def liking
    object.liking if detailed?
  end

  # TODO: Paginate this?
  def found_products
    object.found_products if detailed?
  end

  def detailed?
    scope.params["detail"].present?
  end
end
