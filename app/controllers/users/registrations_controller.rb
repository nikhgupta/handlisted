class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, only: [:create]

  protected

  def configure_permitted_parameters
    permit_for :sign_in, :username, :email, :password, :remember_me, :login
    permit_for :sign_up, :username, :email, :password, :remember_me, :name, :password_confirmation
    permit_for :account_update, :name, :email, :password, :password_confirmation, :current_password
  end

  def after_sign_up_path_for(resource)
    root_path
  end

  def after_inactive_sign_up_path_for(resource)
    products_path
  end

  def after_update_path_for(resource)
    user_path(resource)
  end

  private

  def permit_for(action, *fields)
    devise_parameter_sanitizer.for(action) do |user|
      user.permit(*fields)
    end
  end
end
