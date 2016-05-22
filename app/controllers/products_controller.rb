class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :visit, :like]
  before_action :authenticate_user!, only: [:like, :create]
  set_pagination_headers :users, only: [:likers]
  set_pagination_headers :products, only: [:index, :search, :related]

  include Commentable
  include Sidekiq::Statusable
  include ProductScraper::Checkable

  # GET /products
  # GET /products.json
  def index
    scope = Product.includes(:merchant, :brand, :category, :founder, :likers)
    scope = scope.order(updated_at: :desc)
    @products = paginate scope.all
    respond_to do |format|
      format.html
      format.json { render json: @products }
    end
  end

  def search
    query = params[:search] rescue nil
    scope = Product.search query
    scope = scope.includes :merchant, :brand, :founder, :category
    @products = paginate scope.all
    respond_to do |format|
      format.html
      format.json { render json: @products }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @product }
    end
  end

  def likers
    @users = paginate Product.includes(:likers).find(params[:id]).likers
    respond_to do |format|
      format.json { render json: @users }
    end
  end

  def related
    @products = paginate Product.find(params[:id]).related_products, 4
    respond_to do |format|
      format.json { render json: @products }
    end
  end

  # NOTE: Brakeman reports this falsely under insecure redirect, but the
  # affiliate link is not generated by the user, and hence, the vulnerability
  # does not apply here.
  def visit
    redirect_to @product.affiliate_link
  end

  def like
    method = current_user.liking?(@product) ? :unlike : :like
    @success = current_user.send method, @product
    flash = { alert: "Product could not be #{method}d for some reason."}
    flash = { notice: "Product was successfully #{method}d by you!" } if @success
    respond_to do |format|
      format.json { render json: @product, status: (@success ? :ok : :bad_request) }
      format.html { redirect_to products_path, flash }
    end
  end

  def reimport
    @product = Product.find(params[:id])
    @job_id  = ProductScraperJob.perform_async @product.founder_id, @product.url, force: true if @product
    respond_to do |format|
      format.json { render json: { job_id: @job_id }.to_json }
      format.html { redirect_to root_path, notice: "Successfully queued.." }
    end
  end

  # NOTE: this action simply queues the given product inside Sidekiq. When
  # sidekiq reports that the product has been imported (maybe, already), the
  # user is then redirected to product page using JS.
  def create
    job_id = ProductScraperJob.perform_async current_user.id, params[:url]
    respond_to do |format|
      format.html { redirect_to root_path, notice: "Successfully queued.." }
      format.json { render json: { id: job_id }.to_json }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      scope = Product.includes(:merchant, :founder, :category, :brand)
      @product = scope.find(params[:id])
    end

    def paginate(relation, per_page = nil)
      per_page = params[:per_page] || per_page
      per_page ||= Kaminari.config.default_per_page
      relation.page(params[:page]).per(per_page)
    end
end
