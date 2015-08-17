class UsersController < ApplicationController
  before_action :set_user, only: [:show]
  before_action :set_current_user, only: [:edit, :update]

  # GET /users/1/edit
  def edit
  end

  def show
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
    def set_user
      @user = User.find(params[:username])
    end

    def set_current_user
      @user = current_user
    end

    def user_params
      params.require(:user).permit(
        :name, :email, :password, :password_confirmation, :gender, :image
      )
    end
end

