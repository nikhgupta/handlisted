class ApplicationController < ActionController::Base
  # before_filter :alpha_access_only
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  # :nocov:
  def alpha_access_only
    authenticate_or_request_with_http_basic('Alpha Access Only') do |email, pass|
      user = User.find_by(email: email)
      return true  if user.present? && user.admin? && user.valid_password?(pass)
      return false if ENV['ALPHA_USER'].blank? || ENV['ALPHA_PASS'].blank?
      email == ENV['ALPHA_USER'] && pass == ENV['ALPHA_PASS']
    end unless Rails.env.test?
  end
  # :nocov:
end
