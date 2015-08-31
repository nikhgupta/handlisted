class ApplicationController < ActionController::Base
  before_filter :alpha_access_only
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  # :nocov:
  def alpha_access_only
    return if Rails.env.test?
    authenticate_or_request_with_http_basic('Alpha Access Only') do |email, pass|
      user = User.find_by(email: email)
      user.present? && user.admin? && user.valid_password?(pass)
    end
  end
  # :nocov:
end
