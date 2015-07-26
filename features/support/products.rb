require 'cucumber/rspec/doubles'
FAKE_PRODUCTS = {
  "amazon echo" => {
    uid: 'B00X4WHP5E',
    name: 'Amazon Echo',
    price: '$179.99'.to_money
  }
}

module ProductSourceHelpers
  def product_source_for(product_name)
    case product_name
    when /amazon echo/
      'http://www.amazon.com/dp/B00X4WHP5E/'
    else
      raise "Can't find mapping from \"#{product_name}\" to a source.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(ProductSourceHelpers)

Before do
  FAKE_PRODUCTS.each do |key, data|
    url = product_source_for(key)
    allow(ProductScraper).to receive(:fetch_basic_info).with(url).and_return(data)
  end
end
