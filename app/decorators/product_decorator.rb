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

  def marked_description
    return unless product.description
    renderer   = Redcarpet::Render::HTML.new no_links: false, no_styles: true, no_images: true
    extensions = { autolink: true, tables: false, no_intra_emphasis: true, disable_indented_code_blocks: true }
    markdown   = Redcarpet::Markdown.new renderer, extensions
    markdown.render product.description
  end

  def affiliate_link_action_button(options = {})
    return unless model.url.present?
    text = available ? "#{price} on #{merchant}" : "Maybe Unavailable"
    options[:class] = options.fetch :class, (available ? "system" : "danger")
    options[:class] = "btn btn-large light fs28 affiliate-button btn-#{options[:class]}"
    options = { target: "_blank" }.merge(options)
    h.link_to text, model.merchant.affiliate_link_for(model.url), options
  end
end
