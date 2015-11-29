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

  def refresh_button(options = {})
    return if !h.current_user || (freshly_imported? && !h.current_user.admin?)
    iconic_button_for :refresh, {
      icon: :refresh,
      data: { toggle: "refresh" },
      link: h.reimport_product_path(model),
      title: "Re-import product information from #{merchant_name}!"
    }.merge(options)
  end

  def report_button(options = {})
    return if h.current_user.blank?
    iconic_button_for :report, {
      icon: "exclamation-circle",
      title: "Report for incorrect product information!"
    }.merge(options)
  end

  def like_button(options = {})
    liked = liked_by_current_user?
    iconic_button_for :like, {
      icon: liked ? "heart" : "heart-o",
      link: h.like_product_path(model, kind: options[:kind]),
      title: "Like this product!",
      class: liked ? "active" : ""
    }.merge(options)
  end

  def visit_button(options = {})
    iconic_button_for :visit, {
      link:  h.visit_product_path(model),
      icon:  "external-link", target: "_blank",
      title: "Visit this product on #{merchant_name}",
      method: nil, remote: false
    }.merge(options)
  end

  def price_or_marked_price_on_merchant_link(options = {})
    merc = "<span>on #{merchant_name}</span>"
    html = h.content_tag(:span, class: 'unavailable'){ "Maybe Unavailable #{merc}" }
    html = "#{marked_price} #{merc}" if model.marked_price.to_f > 0
    html = "#{price} #{merc}" if model.price.to_f > 0
    h.link_to html.html_safe, h.visit_product_path(model), { target: "_blank", class: "afflink" }.merge(options)
  end

  def affiliate_button(options = {})
    return if model.url.blank?
    available = model.available? && model.price.to_i > 0
    options[:class] = options.fetch(:class) { (available ? "success" : "light") }
    options[:class] = "btn affiliate-button btn-#{options[:class]}"
    options = { target: "_blank" }.merge(options)
    text = "<span class='bold'>#{affiliate_link_text}</span> #{h.fa_icon('external-link')}".html_safe
    h.link_to text, h.visit_product_path(model), options
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
