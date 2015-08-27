class ProductPresenter < ApplicationPresenter
  def name
    model.name || model.original_name
  end

  def cover_image
    model.images && model.images.any? ? model.images.first : h.image_path("product-missing.png")
  end

  def cover_image_tag(options = {})
    h.image_tag cover_image, { alt: name }.merge(options)
  end

  def price
    model.price.format(
      no_cents: true,
      display_free: "N/A",
      south_asian_number_formatting: true
    )
  end

  def marked_price
    h.humanized_money_with_symbol model.marked_price
  end

  def marked_description
    model.description.present? ? markdown(model.description) : ""
  end

  def affiliate_link_action_button(options = {})
    return if model.url.blank?
    available = model.available? && model.price.to_i > 0
    options[:class] = options.fetch(:class) { (available ? "system" : "light") }
    options[:class] = "btn btn-large light fs28 affiliate-button btn-#{options[:class]}"
    options = { target: "_blank" }.merge(options)
    text = (affiliate_link_text + " " + h.fa_icon('external-link')).html_safe
    h.link_to text, h.visit_product_path(model), options
  end

  def like_button(options = {})
    status = liked_by_current_user? ? :on : :off
    icon = h.fa_icon(status == :on ? 'heart' : 'heart-o', class: "fa-2x")
    h.link_to icon, h.like_product_path(model), remote: true, method: :post, data: { like: status }
  end

  def liked_by_current_user?
    h.current_user.try :liking?, model
  end

  def price_badge
    badge_type = model.prioritized? ? 'bg-success' : 'bg-warning'
    badge_type = 'bg-light dark' if model.price.to_i < 1
    h.content_tag(:span, class: "price #{badge_type}") { price }
  end

  def merchant_name
    model.merchant.name.titleize
  end

private

  def affiliate_link_text
    model.available? ? "#{price} on #{merchant}" : "Maybe Unavailable"
  end
end
