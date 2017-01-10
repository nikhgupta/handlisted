module ProductHelper

  def featured_product
    Product.with_default_includes.order(updated_at: :desc).first
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

  def social_sharing_for(product, options = {})
    title = product.name
    title = "Found on HandListed.in: #{title}" if title.length < 90

    hash  = { url: product_short_url(product.id) }
    hash[:image] = product.images.first if product.images.try(:any?)
    hash.merge!(options)

    social_share_button_tag(title.strip, hash)
  end

  def rss_description_for(product)
    text  = "On #{product.merchant}<br/>"
    text  = "By #{product.brand} #{text}" if product.brand.present?
    if product.available? && product.price.to_f > 0
      text += "Available for discounted price of #{price}"
    elsif product.available? && product.marked_price.to_f > 0
      text += "Available for a price of #{marked_price}"
    elsif product.available?
      text += "Available"
    else
      text += "Currently unavailable"
    end
    text += " on priority service" if product.prioritized?

    text += "<br/>"
    product.images.each do |image|
      text += h.image_tag(image) + "<br/>".html_safe
    end if product.images.present?

    text
  end
end
