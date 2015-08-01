class ProductScraperJob
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options queue: :high_priority

  def expiration
    @expiration ||= 60  # 1 minute
  end

  def perform(user_id, url)
    url  = "http://#{url}" unless url.starts_with?("http")
    data = ProductScraper.fetch_basic_info url
    user = User.find user_id
    service = ProductMigratingService.new(user: user, data: data)
    response = service.run
    store id: response[:id]
    store errors: "<li>#{response[:errors].join("</li><li>")}</li>" if response[:errors]
  rescue ProductScraper::Error => e
    store errors: "<li>#{e.message}</li>"
    raise
  end
end
