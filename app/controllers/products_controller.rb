class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    page = params[:page].to_i || 1
    page = 1 if page < 1
    @products = Product.all.offset((page - 1) * 30).limit(30)
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products/search
  # POST /products/search.json
  def search
    # url  = params[:product_url]
    # data = ProductScrapingService.new(url: url).run
    # @product = Product.create data
    # format.html { redirect_to @product, notice: 'Product was successfully created.' }
    # format.json { render :show, status: :created, location: @product }
  end

  # POST /products/scrape
  # POST /products/scrape.json
  def scrape
    url  = params[:product_url]
    data = ProductScrapingService.new(url: url).run
    @product = Product.create data
    format.html { redirect_to @product, notice: 'Product was successfully created.' }
    format.json { render :show, status: :created, location: @product }
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      # @provider = Provider.find(params[:provider])
      match     = params[:id].match(/^(.*?)\/(.*)\/?/)
      _, params[:provider], params[:product] = match.to_a if match
      @provider  = Provider.find params[:provider]
      @product  = @provider.products.find(params[:product])
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
