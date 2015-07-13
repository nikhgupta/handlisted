class ProductScrapingService
  attr_accessor :options

  def initialize(options = {})
    self.options = options
  end

  def run
    response = ProductScraper.fetch_basic_info(@options[:url])
    binding.pry
  end
end
