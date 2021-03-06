class ProductSerializer < ActiveModel::Serializer
  attributes :id, :pid, :identifier, :name, :slug
  attributes :url, :merchant_url
  attributes :price, :marked_price, :display_price
  attributes :available, :prioritized
  attributes :average_rating, :ratings_count
  attributes :created_at, :updated_at
  attributes :cover_image, :images

  belongs_to :merchant
  belongs_to :brand
  belongs_to :category
  belongs_to :founder

  has_many :likers
  has_many :related_products
  has_many :comments

  attributes :note, :description, :marked_description
  attributes :states

  def comments
    object.comments.order(updated_at: :desc).limit(5)
  end

  def price
    object.price.format
  end

  def marked_price
    object.marked_price.format
  end

  def url
    scope.product_path object
  end

  def merchant_url
    scope.visit_product_path object
  end

  def identifier
    object.url_hash
  end

  def states
    data = {}
    data[:fresh] = object.freshly_imported?
    return data unless scope.current_user.present?
    data[:liked] = object.liker_ids.include?(scope.current_user.id)
    data
  end

  def display_price
    return object.price.format if object.price.to_f > 0
    return object.marked_price.format if object.marked_price.to_f > 0
    "<span class='unavailable'>Maybe Unavailable</span>"
  end

  def cover_image
    return object.images.first if object.images.try(:any?)
    scope.image_path("product-missing.png")
  end

  def marked_description
    options = {
      auto_ids: false,
      syntax_highlighter: nil,
      entity_output: :as_input,
      header_offset: 0
    }
    Kramdown::Document.new(object.description.to_s, options).to_html.strip
  end
end
