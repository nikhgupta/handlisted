json.array! @products do |product|
  json.extract! product, :id, :name, :pid, :updated_at
  json.extract! product, :available, :prioritized
  json.extract! product, :note, :features, :description, :images
  json.extract! product, :average_rating, :ratings_count
  json.set! :price, product.price.format
  json.set! :marked_price, product.marked_price.format
  json.extract! product, :brand, :merchant, :founder, :category
end
