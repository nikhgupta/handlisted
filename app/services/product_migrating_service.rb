class ProductMigratingService
  attr_accessor :user, :data

  def initialize(options = {})
    self.user = options[:user]
    self.data = options[:data]
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
    product.category = categories.last if categories.present? && categories.any?

    return { id: product.to_param } if product.save
    return { errors: product.errors.full_messages }
  end
end
