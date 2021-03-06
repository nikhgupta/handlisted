require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HandListed
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Remove `.field_with_errors` class from validated forms (for now)
    config.action_view.field_error_proc = Proc.new { |tag, instance| tag }

    # ActionMailer settings:
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      user_name: ENV['SMTP_USERNAME'],
      password:  ENV['SMTP_PASSWORD'],
      domain:    ENV['SMTP_DOMAIN'],
      address:   ENV['SMTP_ADDRESS'],
      port:      ENV['SMTP_PORT'],
      authentication: :plain,
      enable_starttls_auto: true
    } if ENV['SMTP_USERNAME'].present?

    config.assets.paths << Rails.root.join("vendor", "pages").to_s
  end
end
