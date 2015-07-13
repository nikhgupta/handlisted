class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update]

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  def update
    respond_to do |format|
      if user_params["password"].present? && @user.update(user_params)
        format.html { redirect_to root_path, notice: 'User was successfully updated.' }
      elsif @user.update_without_password(user_params)
        format.html { redirect_to edit_profile_path, notice: 'User was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(
        :name, :email, :password, :password_confirmation,
        :gender, :language, :image, :timezone_offset
      )
    end
end

