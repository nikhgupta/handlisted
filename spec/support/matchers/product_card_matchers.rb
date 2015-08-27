module RSpecCustomMatchersForCuratedShop
  class HaveProductCardFor
    def initialize(expected)
      @message  = []
      @expected = expected
      @selector = "[data-pid='#{@expected.pid}']"
    end

    def matches?(page)
      @page = page
      raise_error_if_rack_test_driver!

      %w[product_card image_container merchant_label no_errors price
      product_image hidden_product_details].each do |feat|
        return false unless send("has_#{feat}?")
      end

      @message.empty?
    end

    def raise_error_if_rack_test_driver!
      return unless Capybara.current_driver == :rack_test
      raise "You should use `have_product_card_for` matcher with a JS driver."
    end

    def failure_message
      message  = "expected #{@page.current_path} to have valid product card.\n"
      message += "Encountered following errors:\n"
      message += " - #{@message.join(".\n - ")}."
    end

    def failure_message_when_negated
      "expected #{@page.current_path} to not contain given product card."
    end

    private

    def has_product_card?
      verify_selector nil, message: "page has no such card"
    end

    def has_image_container?
      verify_selector ".product-image .container",
        message: "card does not include an image container"
    end

    def has_merchant_label?
      verify_selector ".label.label-#{@expected.merchant.identifier}",
        message: "card has no (or wrong) label for the merchant",
        text: @expected.merchant.to_s.titleize
    end

    def has_price?
      price = @expected.price.format(
        no_cents: true,
        display_free: "N/A",
        south_asian_number_formatting: true
      )
      verify_selector ".price", text: price,
        message: "card has incorrect price information"
    end

    def has_no_errors?
      verify_selector ".error", absence: true, visible: true,
        message: "card contains an error"
    end

    def has_hidden_product_details?
      selector = ".product-image .product-details"
      verify_selector selector, absence: true, visible: true,
        message: "card has visible product details by default"
      verify_selector selector, visible: false,
        message: "card has no hidden product details"
    end

    def has_product_image?
      image = @page.find("#{@selector} .container")
      regex = /^background-image:\s*url\(.+?\).?$/
      match = image[:style].match(regex) ||
        @message << "found no image: #{match.try(:[], 1)}"
    end

    def verify_selector(selector, options = {})
      message  = options.delete(:message)
      invert   = options.delete(:absence) || false
      elements = @page.all("#{@selector} #{selector}".strip, options)
      passed   = invert ? elements.empty? : elements.any?

      if !invert && !passed
        text     = options.delete(:text)
        elements = @page.all("#{@selector} #{selector}".strip, options)
        if elements.any?
          message += ", was looking for: #{text}" if text
          message += ", but found elements with text: #{elements.map(&:text).join(', ')}"
        end
      end

      @message << message if message && !passed
      passed
    end
  end

  def have_product_card_for(expected)
    HaveProductCardFor.new(expected)
  end
end
