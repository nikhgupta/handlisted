class ApplicationPresenter
  def initialize(object, template)
    @object = object
    @template = template
  end

  def markdown(text)
    options = {
      auto_ids: false,
      syntax_highlighter: nil,
      entity_output: :as_input,
      header_offset: 0
    }
    Kramdown::Document.new(text, options).to_html.strip
  end

  def model
    @object
  end

  protected
  def to_currency(amount)
    amount.format(no_cents: true, display_free: "N/A")
  end

  def iconic_button_for(model, name, options = {})
    path = options.delete(:link) || "#"
    size = options.delete(:size)
    options[:class] = "#{options[:class]} iconic-btn #{model}-#{name}"
    h.iconic_link_to nil, path, {
      icon: "fa #{size ? "fa-#{size}x" : "fs-16"} fa-#{options.delete(:icon) || name}",
      remote: true, method: :post
    }.merge(options)
  end

  private

  def self.presents(name)
    define_method(name){ @object }
  end

  def h
    @template
  end

  def method_missing(*args, &block)
    return super unless @object.respond_to?(*args)
    @object.send(*args, &block)
  end

  def respond_to?(method, include_private = false)
    super || @object.respond_to?(method, include_private)
  end
end
