json.array!(@products) do |product|
  json.extract! product, :id, :brand, :user, :name, :note, :price, :available, :priority_service
  json.url product_url(product, format: :json)
end
