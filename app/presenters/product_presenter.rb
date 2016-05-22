class ProductPresenter < ApplicationPresenter

  def hash
    Digest::MD5.hexdigest model.url_hash
  end

  def id(type = :default)
    "productCard#{"-" + type.to_s if type && type != :default}-#{hash}"
  end

  def name
    model.name || model.original_name
  end

  def link
    h.link_to name, h.product_path(model)
  end

  def merchant_name
    model.merchant.name.titleize
  end

  def merchant_link
    h.link_to merchant_name, h.merchant_path(model.merchant)
  end

  def brand_name
    model.brand.name.titleize if model.brand.present?
  end

  def brand_link
    h.link_to brand_name, h.brand_path(model.brand) if model.brand.present?
  end

  def cover_image
    return model.images.first if model.images && model.images.any?
    h.image_path("product-missing.png")
  end

  def cover_image_tag(options = {})
    h.image_tag cover_image, { alt: name }.merge(options)
  end

  def price
    to_currency model.price
  end

  def marked_price
    model.marked_price.format(no_cents: true, display_free: "N/A")
  end

  def social_sharing(options = {})
    title = model.name
    title = "Found on HandListed.in: #{title}" if title.length < 90

    hash  = { url: h.product_short_url(model.id) }
    hash[:image] = cover_image if model.images && model.images.any?
    hash.merge!(options)

    h.social_share_button_tag(title.strip, hash)
  end

  def markdowned_description
    model.description.present? ? markdown(model.description) : ""
  end

  def rss_description
    text  = "On #{model.merchant}<br/>"
    text  = "By #{model.brand} #{text}" if model.brand.present?
    if model.available? && model.price.to_f > 0
      text += "Available for discounted price of #{price}"
    elsif model.available? && model.marked_price.to_f > 0
      text += "Available for a price of #{marked_price}"
    elsif model.available?
      text += "Available"
    else
      text += "Currently unavailable"
    end
    text += " on priority service" if model.prioritized?

    text += "<br/>"
    model.images.each do |image|
      text += h.image_tag(image) + "<br/>".html_safe
    end if model.images.present?

    text
  end

  protected

  def liked_by_current_user?
    h.current_user.try :liking?, model
  end

  def to_currency(amount)
    amount.format(no_cents: true, display_free: "N/A")
  end

  def iconic_button_for(name, options = {})
    super(:product, name, options)
  end

  def affiliate_link_text
    model.available? && model.price > 0 ? "#{price} on #{merchant}" : "Maybe Unavailable"
  end
end
