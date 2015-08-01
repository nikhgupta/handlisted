class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :destroy]

  # GET /products
  # GET /products.json
  def index
    page = params[:page].to_i || 1
    page = 1 if page < 1
    query = params[:product][:search] rescue nil
    scope = query.present? ? Product.search(query) : Product.order(updated_at: :desc)
    @products = scope.all.offset((page - 1) * 30).limit(30)
  end

  def show
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      # format.json { head :no_content }
    end
  end

  def visit
    set_product
    redirect_to @product.affiliate_link
  end

  def like
    set_product
    method = params[:status] == "on" ? :unlike : :like
    success = current_user.send method, @product
    status = current_user.liking?(@product) ? :on : :off
    respond_to do |format|
      if success
        format.json { render json: { liking: status } }
      else
        message = 'There was an error with your request. Please, try again.'
        format.json { render json: { liking: status, message: message }, status: :unprocessable_entity }
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
    status = 'Failed' if data['errrors'].present?
    response = { status: status, id: data['id'], errors: data['errors'] }
    render json: response.to_json
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    def redirect_if_moved
      return if params[:product] == @product.slug
      redirect_to product_path(@product), status: :moved_permanently
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(
        :brand_id, :user_id, :provider_id,
        :pid, :name, :original_name, :note, :description,
        :price_cents, :price_currency, :marked_price_cents,
        :marked_price_currency, :available, :priority_service
      )
    end
end
