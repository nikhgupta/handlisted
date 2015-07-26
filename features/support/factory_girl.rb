require 'factory_girl'
# Dir[Rails.root.join("spec", "factories", "**", "*.rb").to_s].each{|f| require f}

begin
  DatabaseCleaner.start
  FactoryGirl.lint
ensure
  DatabaseCleaner.clean_with(:truncation)
end

World(FactoryGirl::Syntax::Methods)

