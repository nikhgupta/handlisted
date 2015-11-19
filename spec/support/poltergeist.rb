require 'capybara/poltergeist'

Capybara.configure do |config|
  config.current_driver = :poltergeist if ENV['WITH_JS'] || ENV['DEBUG'] == 'js'
  config.javascript_driver = :poltergeist
  config.default_max_wait_time = 2
  config.app_host = "http://localhost:3000"
  config.asset_host = "http://localhost:3000"
  config.server_host = "localhost"
  config.server_port = "3000"
end

Capybara.register_driver :poltergeist do |app|
  options = { js_errors: true, window_size: [1300, 1000], timeout: 10,
    phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes'] }
  options = options.merge(debug: true, inspector: true) if ENV['DEBUG'] == 'js'
  Capybara::Poltergeist::Driver.new(app, options)
end
