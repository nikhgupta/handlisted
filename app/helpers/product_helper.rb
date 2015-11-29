module ProductHelper
  def latest_updated_product
    Product.order(updated_at: :desc).first
  end

  def total_products
    Product.count
  end

  def updated_products
    Product.where.not(note: nil).count
  end

  def updated_progress
    return 0 unless total_products > 0
    (updated_products / total_products.to_f * 100).round(0)
  end
end
