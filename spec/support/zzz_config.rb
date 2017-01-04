RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include AddProductHelpers, type: :feature
  config.include DriverAgnosticHelpers, type: :feature
  config.include CustomMatchersForCapybara, type: :feature
  config.include Devise::IntegrationHelpers, type: :feature
  config.include ActionView::TestCase::Behavior, type: :presenter
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::ControllerHelpers, type: :controller

  config.include ActiveSupport::Testing::TimeHelpers, :timers
  config.after(:each, :timers){ travel_back }

  config.include EmailHelpers, :mailers
  config.before(:each, :mailers){ ActionMailer::Base.deliveries.clear }

  config.before(:each, [:background, :mailers, type: :job]) do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
  end

  config.before(:each, omniauth: true) do
    OmniAuth.config.test_mode = true

    MOCK_OMNIAUTH_CONFIG.each do |provider, auth|
      OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new(auth)
    end
  end

  config.before(:suite){ FactoryGirl.lint } if config.files_to_run.count > 10

  config.after(:each, type: :feature) do |example|
    if example.exception.present? && ENV['DEBUG'].present?
      save_and_open_page
      save_and_open_screenshot
    end
  end
end
