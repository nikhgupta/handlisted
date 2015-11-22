class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Mailer

  protected

  def mail_factory(options = {})
    mailer = options.delete(:use_roadie) === false ? :mail : :roadie_mail
    send mailer, options
  end

  def roadie_options
    super unless Rails.env.test?
  end
end
