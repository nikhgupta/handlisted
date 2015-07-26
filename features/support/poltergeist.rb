require 'capybara/poltergeist'

Capybara.configure do |config|
  config.javascript_driver = :poltergeist
  config.default_wait_time = 2
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    js_errors: false, window_size: [1300, 1000],
    # debug: true, inspector: true,
    phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes'],
  )
end
