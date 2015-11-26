ProductScraper.configure do |config|
  config.validate :host, for: :amazon do |uri|
    uri.host =~ /^(?:|www\.)amazon\.in$/
  end
end
