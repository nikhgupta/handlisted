require 'vcr'
require 'webmock/rspec'
require 'product_scraper/testing'

PRODUCTS_LIST = {
  kindle: {
    pid: 'B00QJDOEAO',
    url: 'http://www.amazon.in/gp/product/B00QJDOEAO'
  }, invalid: {
    pid: 'B00QJDOEAOX',
    url: 'http://www.amazonin.in/gp/product/B00QJDOEAOX'
  }, moto_x: {
    url: 'http://www.flipkart.com/moto-e-2nd-gen-4g/p/itme85hfdv6zztcj?pid=MOBE4G6GTH2QDACF',
    pid: 'MOBE4G6GTH2QDACF'
  }
}

WebMock.disable_net_connect!
VCR.configure do |config|
  config.cassette_library_dir = "spec/cache/vcr"
  config.hook_into :webmock # or :fakeweb
  config.allow_http_connections_when_no_cassette = false
  config.ignore_localhost = true
end

ProductScraper.use_cassettes!("scraper")
