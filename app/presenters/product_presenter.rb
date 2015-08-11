class ProductPresenter < ApplicationPresenter
  def name
    model.name || model.original_name
  end

  def cover_image_tag(options = {})
    h.image_tag model.cover_image, { alt: name }.merge(options)
  end

  def price
    h.humanized_money_with_symbol model.price
  end

  def marked_price
    h.humanized_money_with_symbol model.marked_price
  end

  def marked_description
    model.description.present? ? markdown(model.description) : ""
  end

  def affiliate_link_action_button(options = {})
    return if model.url.blank?
    options[:class] = options.fetch(:class) { (model.available? ? "system" : "danger") }
    options[:class] = "btn btn-large light fs28 affiliate-button btn-#{options[:class]}"
    options = { target: "_blank" }.merge(options)
    h.link_to affiliate_link_text, h.visit_product_path(model), options
  end

  def like_button(options = {})
    status = liked_by_current_user? ? :on : :off
    icon = h.fa_icon(status == :on ? 'heart' : 'heart-o', class: "fa-2x")
    h.link_to icon, h.like_product_path(model), remote: true, method: :post, data: { like: status }
  end

  def liked_by_current_user?
    h.current_user.try :liking?, model
  end

private

  def affiliate_link_text
    model.available? ? "#{price} on #{merchant}" : "Maybe Unavailable"
  end
end
