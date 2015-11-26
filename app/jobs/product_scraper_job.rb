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
    data     = ProductScraper.fetch url

    if data.blank?
      store_errors "Merchant has not been implemented, yet!"
    elsif data['response_code'] >= 500
      store_errors "Merchant website gave up. Seems like there server is kaboom!"
    elsif data["response_code"] >= 400
      store_errors "There is no product over here."
    else
      response = ProductMigratingService.new(user: user, data: data).run
      store id: response[:id]
      store_errors response[:errors] if response[:errors]
    end
  rescue ProductScraper::Error => e
    store_errors e.message
    raise
  end

  private

  def store_errors(errors)
    store errors: [errors].flatten.uniq.first
  end
end
