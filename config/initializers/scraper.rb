require 'capybara'
require 'capybara/poltergeist'
class Scraper
  include Capybara::DSL
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(
      app,
      inspector: true,
      js_errors: false,
      phantomjs_logger: Logger.new('/dev/null'),
      phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes'],
    )
  end
  Capybara.default_driver = :poltergeist

  attr_accessor :name

  def initialize name = nil
    @name = name
  end

  def session
    @session ||= Capybara::Session.new(:poltergeist).tap do |sess|
      sess.execute_script "console.log = function(){}"
    end
  end

  def absolute_url(url)
    return if url.blank?
    uri = URI.parse session.current_url
    prefix = "#{uri.scheme}://#{uri.host}"
    url.starts_with?("/") ? "#{prefix}#{url}" : url
  end
end
