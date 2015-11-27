class ProductMigratingService
  attr_accessor :user, :data

  def initialize(options = {})
    self.user = options[:user]
    self.data = sanitize_data options[:data]
    raise ArgumentError, "User or data is missing!" if user.blank? || data.blank?
  end

  def run
    merchant = @data.delete(:merchant)
    merchant = Merchant.find_or_create_by(merchant)
    product  = merchant.products.where(pid: @data[:pid])
    return { id: product.first.to_param } if product.exists?

    brand = @data.delete(:brand)
    brand = merchant.brands.find_or_create_by(name: brand[:name]) if brand.present?

    categories = @data.delete(:categories).select{ |cat| cat.present? }
    categories = Category.create_hierarchy categories

    product = merchant.products.build data
    product.founder = user
    product.brand   = brand if brand.present?
    product.category = categories.last if categories.any?

    return { id: product.to_param } if product.save
    return { errors: product.errors.full_messages }
  end

  def sanitize_data(response)
    return {} if response.blank? || response.has_key?('error')
    data = {
      name: nil, note: nil,
      pid: response['pid'],
      available: response['available'],
      original_name: response['name'],
      prioritized: !!response['priority_service'],
      merchant: { name: response['scraper'].to_s.demodulize.underscore },
      url: response['canonical_url'],
      images: response['images']
    }
    data[:brand] = { name: response['brand_name'] } if response['brand_name']
    data[:price] = response['price'] if response['price']
    data[:marked_price] = response['marked_price'] if response['marked_price']
    data[:url_hash] = response['uuid']
    data[:categories] = response['categories']
    if response['description'] && response['description']['markdown']
      data[:description] = response['description']['markdown']
    end
    data
  end
end
