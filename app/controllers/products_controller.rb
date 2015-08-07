class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :visit, :like]
  before_action :authenticate_user!, only: [:like, :unlike, :create]

  # GET /products
  # GET /products.json
  def index
    query = params[:product][:search] rescue nil
    scope = query.present? ? Product.search(query) : Product.order(updated_at: :desc)
    if scope.empty?
      scope = Product.order(updated_at: :desc)
      flash[:alert] = "No matching products were found. Showing all products."
    end
    @products = scope.all.limit(30)
  end

  def show
  end

  def visit
    redirect_to @product.affiliate_link
  end

  def like
    method = current_user.liking?(@product) ? :unlike : :like
    respond_to do |format|
      if current_user.send method, @product
        format.js { render :like }
      else
        format.js { render :toggle_error, action: :like }
      end
    end
  end

  # if product exists, redirect to it, else queue it.
  def create
    job_id = ProductScraperJob.perform_async current_user.id, params[:url]
    respond_to do |format|
      format.html { redirect_to root_path, notice: "Successfully queued.." }
      format.json { render json: { id: job_id }.to_json }
    end
  end

  # Quick-dirty API check to see if the search term is indeed a Merchant URL?
  def parseable
    hash = ProductScraper.url_hash_for(params[:search])
    existing = Product.find_by(url_hash: hash) if hash
    existing = existing ? product_path(existing) : nil
    respond_to do |format|
      format.json { render json: { valid: hash.present?, existing: existing } }
    end
  end

  # Quick-dirty API to query the status of a sidekiq job
  def status
    id = params[:job_id]
    status = Sidekiq::Status::status(id).to_s.camelize
    data = Sidekiq::Status::get_all id
    status = 'Failed' if data['errors'].present?
    response = { status: status, id: data['id'], errors: data['errors'] }
    render json: response.to_json
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end
end
