class Users::SessionsController < Devise::SessionsController
  before_action :set_instance_for_merit, only: [:destroy]

  def new
    super do |resource|
      resource.errors.add(:base, params["error"]) if params["error"].present?
    end
  end

  def create
    super do |resource|
      @session = resource
    end
  end

  private

  def set_instance_for_merit
    @session = current_user
  end
end
