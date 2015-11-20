class UsersController < ApplicationController
  before_action :set_user, only: [:show]
  before_action :set_current_user, only: [:edit, :update]
  before_action :set_kind_and_counts, only: [:show, :edit]

  # GET /users/1/edit
  def edit
    key = 'devise.user_errors'
    @user.errors.add(:base, *session.delete(key)) if session[key]
    @products = {
      liked: @user.liking.scope.page(params[:page]),
      found: @user.found_products.scope.page(params[:page]),
    }
  end

  def show
    @products = {
      liked: @user.liking.scope.page(params[:page]),
      found: @user.found_products.scope.page(params[:page]),
    }
  end

  # PATCH/PUT /users/1
  def update
    respond_to do |format|
      if user_params["password"].present? && @user.update(user_params)
        format.html { redirect_to root_path, notice: 'User was successfully updated.' }
      elsif @user.update_without_password(user_params)
        format.html { redirect_to edit_profile_path, notice: 'User was successfully updated.' }
      else
        # NOTE: This does not preserve changes made by the user
        session['devise.user_errors'] = @user.errors.full_messages
        format.html { redirect_to action: :edit }
      end
    end
  end

  private
    def set_user
      @user  = User.find(params[:username])
    end

    def set_current_user
      @user = current_user
    end

    def set_kind_and_counts
      @kind  = params[:kind]
      @liked = @user.likes.count
      @found = @user.found_products_count
    end

    def user_params
      params.require(:user).permit(
        :name, :email, :password, :password_confirmation, :gender, :image
      )
    end
end

