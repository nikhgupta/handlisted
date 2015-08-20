class Users::SessionsController < Devise::SessionsController
  before_action :set_instance_for_merit, only: [:destroy]

  def create
    super { |resource| @session = resource }
  end

  private

  def set_instance_for_merit
    @session = current_user
  end
end
