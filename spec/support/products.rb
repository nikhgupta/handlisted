require 'vcr'
require 'webmock/rspec'
require 'product_scraper/testing'

PRODUCTS_LIST = {
  amazon_echo: {
    pid: 'B00X4WHP5E',
    url: 'http://www.amazon.com/dp/B00X4WHP5E'
  }
}

WebMock.disable_net_connect!
VCR.configure do |config|
  config.cassette_library_dir = "spec/cache/vcr"
  config.hook_into :webmock # or :fakeweb
  config.allow_http_connections_when_no_cassette = true
end

ProductScraper.use_cassettes!("scraper")
