# Mailer proxy to send devise emails in the background
class Devise::Mailer
  self.asset_host = nil
  include Roadie::Rails::Mailer

  private

  def devise_mail(record, action, opts = {})
    initialize_from_record(record)
    roadie_mail headers_for(action, opts)
  end

  def roadie_options
    super unless Rails.env.test?
  end
end

class DeviseBackgroundMailer

  def self.confirmation_instructions(record, token, opts = {})
    new(:confirmation_instructions, record, token, opts)
  end

  def self.reset_password_instructions(record, token, opts = {})
    new(:reset_password_instructions, record, token, opts)
  end

  def self.unlock_instructions(record, token, opts = {})
    new(:unlock_instructions, record, token, opts)
  end

  def initialize(method, record, token, opts = {})
    @method, @record, @token, @opts = method, record, token, opts
  end

  def deliver
    Devise::Mailer.delay.send(@method, @record, @token, @opts)
  end
end
