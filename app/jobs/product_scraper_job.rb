class ProductScraperJob
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options queue: :default

  def expiration
    @expiration ||= 60  # 1 minute
  end

  def perform(user_id, url)
    url      = "http://#{url}" unless url.starts_with?("http")
    user     = User.find user_id
    data     = ProductScraper.fetch_basic_info url
    response = ProductMigratingService.new(user: user, data: data).run

    store id: response[:id]
    store_errors response[:errors] if response[:errors]
  rescue Mechanize::ResponseCodeError => e
    raise unless e.response_code =~ /^(4|5)\d\d$/
    store_errors "There is no product over here."
  rescue ProductScraper::Error => e
    store_errors e.message
    raise
  end

  private

  def store_errors(errors)
    store errors: [errors].flatten.uniq.first
  end
end
