class ProductDecorator < ApplicationDecorator

  def name
    model.name || model.original_name
  end

  def short_name length = 60
    return name if name.length < length
    name[0..(length - 5)] + " ..."
  end

  def cover_image_tag options = {}
    options = { alt: name }.merge(options)
    h.image_tag model.cover_image, options
  end

  def price
    h.humanized_money_with_symbol model.price
  end

  def marked_price
    h.humanized_money_with_symbol model.marked_price
  end

  def path
    h.product_path(product)
  end

  # def affiliate_link_action_button(options = {})
  #   return unless model.affiliate_link.present?
  #   text = "#{price} on #{merchant}"
  #   options[:class] = options.fetch(:class, "btn btn-large btn-primary fs28")
  #   h.link_to text, model.affiliate_link, options
  # end
end
