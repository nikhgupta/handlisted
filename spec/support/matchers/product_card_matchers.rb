module CustomMatchersForCapybara
  class HaveProductCardFor
    def initialize(expected)
      @message  = []
      @expected = expected
      @selector = "#productCard-#{Digest::MD5.hexdigest(@expected.url_hash)}"
    end

    def matches?(page)
      @page = page
      raise_error_if_rack_test_driver!

      %w[product_card image_container merchant_info no_errors pricing_info
      product_image action_buttons].each do |feat|
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
      verify_selector ".panel-image-centered .image-container",
        message: "card does not include an image container"
    end

    def has_merchant_info?
      verify_selector "a.afflink", visible: false,
        text: @expected.merchant.to_s.titleize,
        message: "card has no (or wrong) label for the merchant"
    end

    def has_pricing_info?
      price = @expected.price.format(no_cents: true, display_free: "N/A")
      verify_selector "a.afflink", text: price, visible: false,
        message: "card has incorrect price information"
    end

    def has_no_errors?
      verify_selector ".error", absence: true, visible: true,
        message: "card contains an error"
    end

    def has_action_buttons?
      verify_selector ".product-like", visible: true,
        message: "card has no button to like itself"
      verify_selector ".product-visit", visible: true,
        message: "card has no button to visit the product URL"
      # NOTE: refresh button is dependent on loggedin user
      # verify_selector ".product-refresh", visible: false,
      #   message: "card has no button to refresh itself"
    end

    def has_product_image?
      image = @page.find("#{@selector} .image-container")
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
