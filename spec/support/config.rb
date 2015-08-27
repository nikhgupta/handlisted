Dir[Rails.root.join('spec/support/helpers/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/support/matchers/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/support/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # include factory_girl methods
  config.include FactoryGirl::Syntax::Methods

  # include email spec helpers
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers

  # include helpers for testing presenters
  config.include ActionView::TestCase::Behavior, file_path: %r{spec/presenters}

  # include time travelling
  config.include ActiveSupport::Testing::TimeHelpers

  # custom helpers
  config.include LoginHelpers
  config.include ProductHelpers
  config.include CapybaraSelectors
  config.include DriverAgnosticHelpers
  config.include RSpecCustomMatchersForCuratedShop

  # Allows running rspec using `--only-failures` option
  config.example_status_persistence_file_path = Rails.root.join("tmp", "rspec", "examples.txt")

  # lint factories, and drop all database tables as required
  config.before(:suite) do
    begin
      DatabaseCleaner.start if ENV['COVERAGE'] || ENV['WITH_LINT']
      FactoryGirl.lint      if ENV['COVERAGE'] || ENV['WITH_LINT']
    ensure
      DatabaseCleaner.clean_with(:truncation)
    end
  end

  # use faster :transaction strategy on rack tests
  config.before(:each) do
    Sidekiq::Worker.clear_all
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.strategy = :transaction
  end

  # poltergeist doesn't play well with :transaction strategy due to different
  # threads, so lets use slower but reliable :truncation strategy on js tests.
  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  # clean the database after each scenario/spec
  config.around(:each) do |example|
    DatabaseCleaner.cleaning { example.run }
  end

  # mock OmniAuth response before each test
  config.before(:each, omniauth: true) do
    OmniAuth.config.test_mode = true
    MOCK_OMNIAUTH_CONFIG.each do |provider, auth|
      OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new(auth)
    end
  end

  # clean the database after each test, and open html/screenshot, if debugging
  config.after do |example|
    travel_back
    DatabaseCleaner.clean
    if example.metadata[:type] == :feature and example.exception.present?
      save_and_open_page if ENV['DEBUG'].present?
      save_and_open_screenshot if example.metadata[:js] && ENV['DEBUG'].present?
    end
  end
end
