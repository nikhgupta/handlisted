RSpec::Matchers.define :have_product_card_for do |*args|
  match do |page|
    pid, merchant, price = args; nil # appending nil is faster
    selector = "[data-pid='#{pid}']"
    expect(page).to have_selector(selector)
    expect(page).to have_selector("#{selector} .product-image .container")
    expect(page).to have_selector("#{selector} .label.label-#{merchant}")
    expect(page).to have_selector("#{selector} .price", text: price)
    expect(page).to have_no_selector("#{selector} .error")
    expect(page).to have_no_selector("#{selector} .product-image .product-details")
    expect(page).to have_selector("#{selector} .product-image .product-details", visible: false)

    image = find("#{selector} .container")
    expect(image[:style]).to match(/^background-image:\s*url\(.*?\).?$/)
  end

  match_when_negated do |page|
    expect(page).to have_no_selector("[data-pid='#{args[0]}']")
  end

  def add_message_for(page, pid, selector, text = nil)
    if page.all("[data-pid='#{pid}'] #{selector}").empty?
      return "- did not find selector: #{selector} for product\n"
    elsif text.present?
      found = page.find("[data-pid='#{pid}'] #{selector}").text
      return "" if found.to_s == text.to_s
      return "- expected selector: #{selector} to have text: #{text}, but found: #{found}\n"
    end
  end

  failure_message do |page|
    selector = "[data-pid='#{args[0]}']"
    message  = "expected #{page.current_path} to have valid product card with: #{args}\n"
    message += "- did not find product image\n" if page.all("#{selector} .product-image .container").empty?
    message += "- found no background image for product\n" if !page.all("#{selector} .container").empty? && !(page.find("#{selector} .container")[:style] =~ /^background-image:\s*url\(.*?\).?$/)
    message += "- found error inside product card: #{page.find("#{selector} .errors").text}\n" unless page.all("#{selector} .errors").empty?
    message += add_message_for(page, args[0], ".label", args[1])
    message += add_message_for(page, args[0], ".price", args[2])
  end

  failure_message_when_negated do |page|
    "expected #{page.current_path} to not have product card with ID: #{args[0]}"
  end

  description do
    "checks if the page has a given product"
  end
end
