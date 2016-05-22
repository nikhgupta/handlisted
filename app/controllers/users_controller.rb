class UsersController < ApplicationController
  before_action :set_user, only: [:show, :liked, :found]
  before_action :set_current_user, only: [:edit, :update]
  before_action :set_group_and_counts, only: [:show, :edit]
  before_action :set_found_and_liked_products, only: [:show, :edit]
  set_pagination_headers :products, only: [:liked, :found]

  # GET /users/1/edit
  def edit
    key = 'devise.user_errors'
    @user.errors.add(:base, *session.delete(key)) if session[key]
  end

  def show
    respond_to do |format|
      format.html
      format.json{ render json: @user }
    end
  end

  def liked
    @products = @user.liking
    @products = @products.includes(:merchant, :brand, :category, :founder)
    @products = paginate @products, 4
    respond_to do |format|
      format.json { render json: @products }
    end
  end

  def found
    @products = @user.found_products
    @products = @products.includes(:merchant, :brand, :category, :founder)
    @products = paginate @products, 4
    respond_to do |format|
      format.json { render json: @products }
    end
  end

  # PATCH/PUT /users/1
  def update
    respond_to do |format|
      if user_params["password"].present? && @user.update(user_params)
        format.html { redirect_to products_path, notice: 'User was successfully updated.' }
      elsif @user.update_without_password(user_params)
        format.html { redirect_to profile_edit_path, notice: 'User was successfully updated.' }
      else
        # NOTE: This does not preserve changes made by the user
        session['devise.user_errors'] = @user.errors.full_messages
        format.html { redirect_to action: :edit }
      end
    end
  end

  private
    def set_user
      @user = User.includes(sash: :badges_sashes).find_by username: params[:username]
    end

    def set_current_user
      @user = User.includes(sash: :badges_sashes).find current_user.id
    end

    def set_found_and_liked_products
      products  = { found: :found_products, liked: :liking }
      products  = Hash[products.map{|k,m| [k, @user.send(m).includes(:merchant, :brand, :category, :founder)]}]
      products  = Hash[products.map{|k,scope| [k, paginate(scope, 3)]}]
      @products = products
    end

    def set_group_and_counts
      @kind, @group = params[:kind], params[:group]
      @liked = @user.likes.count
      @found = @user.found_products_count
    end

    def user_params
      params.require(:user).permit(
        :name, :email, :password, :password_confirmation, :gender, :image
      )
    end

    def paginate(relation, per_page = nil)
      per_page = params[:per_page] || per_page
      per_page ||= Kaminari.config.default_per_page
      relation.page(params[:page]).per(per_page)
    end
end

