source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails', '~> 4.2.2'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
# gem 'unicorn'
# gem 'therubyracer', platforms: :ruby
# gem 'bcrypt', '~> 3.1.7'

# Presenters
gem 'kaminari'
gem 'kramdown'
gem 'friendly_id'
gem 'bootstrap-generators'

# Business Logic
gem 'pg_search'
gem 'sidekiq-status'
gem 'product_scraper', github: 'nikhgupta/product_scraper', branch: :master

# ActiveRecord Helpers
gem 'acts_in_relation'
gem 'awesome_nested_set'

# Authentication and Authorization
gem 'devise'
gem 'pundit'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'omniauth-google-oauth2'
gem 'activeadmin', '~> 1.0.0.pre1' # github: 'activeadmin'

# Tools
gem 'foreman'
gem 'unicorn'
gem 'sidekiq'
gem 'sinatra', require: false

# Services
gem 'rollbar', '~> 2.5.0'
gem 'gibbon'

# Deployment
group :development do
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-rbenv', '~> 2.0'
end

# Avoid - These gems are nice but have a lot more to offer. For the required
# minimal features, we can roll out our own code.
gem 'merit'
gem 'high_voltage'

# Superfluous/Extraneous - These gems are really just adding wait to our app
# - either they are not really required or we can reproduce their usage in the
# app with minimal code.
gem 'monetize'
gem 'money-rails'
gem 'google_currency'

# Test Suite and other tools and helpers follow:

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'vcr'
  gem 'webmock'
  gem 'launchy'
  gem 'poltergeist'
  gem 'shoulda-matchers'
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'rspec_junit_formatter', '0.2.2' # for Circle-CI metadata inference
  gem 'fuubar'
end

group :test, :development do
  gem 'bullet'
  gem 'byebug'
  gem 'spring'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

# others
gem 'roadie-rails'
gem "skylight"
gem 'haml'

gem 'social-share-button'
gem 'active_model_serializers'
gem 'riot_js-rails'
