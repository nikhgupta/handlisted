RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    if ENV['COVERAGE'] || ENV['FULL'] || ENV['LINT']
      begin
        DatabaseCleaner.start
        FactoryGirl.lint
      ensure
        DatabaseCleaner.clean_with(:truncation)
      end
    end
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

