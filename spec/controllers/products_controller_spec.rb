require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe ProductsController, type: :controller do

  def stub_status!(jid, status, data = {})
    data = Hash[data.map{|k,v| [k.to_s, v]}] # sidekiq-status returns string keys
    allow(Sidekiq::Status).to receive(:status).with(jid).and_return(status)
    allow(Sidekiq::Status).to receive(:get_all).with(jid).and_return(data)
  end

  # This should return the minimal set of attributes required to create a valid
  # Product. As you add validations to Product, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    build(:moto_x).attributes
  }

  let(:invalid_attributes) {
    build(:moto_x).attributes.merge(original_name: nil)
  }

  let(:user) { create :confirmed_user }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ProductsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    render_views

    it "assigns all products as @products when search is empty" do
      product = Product.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:products)).to eq([product])
    end

    it "assigns products matching a given query when search is requested" do
      product = Product.create! valid_attributes
      get :index, { product: { search: 'moto x' } }, valid_session
      expect(assigns(:products)).to eq([product])
    end

    it "alerts user when no product matching query are found" do
      get :index, { product: { search: 'random keyword' } }, valid_session
      expect(response.body).to include("No matching products were found")
    end
  end

  describe "GET #show" do
    it "assigns the requested product as @product" do
      product = Product.create! valid_attributes
      get :show, { id: product.to_param }, valid_session
      expect(assigns(:product)).to eq(product)
    end
  end

  describe "GET #visit" do
    it "redirects the user to product's affiliate link" do
      product = Product.create! valid_attributes
      get :visit, { id: product.to_param }, valid_session
      expect(response).to redirect_to(product.affiliate_link)
    end
  end

  describe "POST #like" do
    # render_views
    # NOTE: this is actually happening via JS, but rack-test passes since devise
    # sends a redirect anyways on no auth.
    it "requires a user to be logged in" do
      sign_in nil
      product = Product.create! valid_attributes
      post :like, { id: product.to_param }, valid_session
      expect(response).to redirect_to(new_user_session_path)
    end
    it "toggles user's like for a product" do
      sign_in user
      product = Product.create! valid_attributes
      post :like, { id: product.to_param, format: :json }, valid_session
      expect(response).to be_successful
      expect(user).to be_liking(product)
      json = JSON.parse response.body
      expect(json['states']['liked']).to be_truthy

      post :like, { id: product.to_param, format: :json }, valid_session
      expect(response).to be_successful
      expect(user).not_to be_liking(product)
    end
    it "throws an error when product like can not be toggled" do
      sign_in user
      product = Product.create! valid_attributes
      allow(user).to receive(:like).with(product).and_return(nil)
      post :like, { id: product.to_param, format: :json }, valid_session
      expect(response).to be_bad_request
      json = JSON.parse response.body
      expect(json['states']['liked']).to be_falsey
    end
  end

  describe "POST #verify_url" do
    it "checks if the url provided to search is parseable by the scraper" do
      url = PRODUCTS_LIST[:kindle][:url]
      post :verify_url, { search: url, format: :json }, valid_session
      expect(response).to be_successful
      json = JSON.parse response.body
      expect(json['valid']).to be_truthy
      expect(json['existing']).to be_nil
    end

    it "returns existing product path if url provided has already been scraped" do
      product = create(:moto_x)
      post :verify_url, { search: product.url, format: :json }, valid_session
      expect(response).to be_successful
      json = JSON.parse response.body
      expect(json['valid']).to be_truthy
      expect(json['existing']).to eq(product_path(product))
    end
  end

  describe "POST #create" do
    let(:url) { 'http://www.amazon.com/dp/B00X4WHP5E' }
    it "redirects the user to login page when not logged in" do
      sign_in nil
      post :create, { url: url }, valid_session
      expect(response).to redirect_to(new_user_session_path)
    end

    it "queues the product creation in background job queue" do
      sign_in user
      expect(ProductScraperJob).to receive(:perform_async).with(user.id, url).twice.and_return(:some_job_id)

      post :create, { url: url }, valid_session
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to include("Successfully queued")

      post :create, { url: url, format: :json }, valid_session
      expect(response).to be_successful
      json = JSON.parse response.body
      expect(json['id']).to eq("some_job_id")
    end
  end

  describe "POST #fetch_status" do
    let(:jid) { 'aa045b92xxxxxxxx8baa1b13' }
    it "returns product's status from Sidekiq queue" do
      stub_status!(jid, 'Working')

      post :fetch_status, { job_id: jid, format: :json }, valid_session
      expect(response).to be_successful
      expect(response).to have_json('status' => 'Working', 'id' => nil, 'errors' => nil)
    end

    it "returns product's status and ID of the new product when created" do
      stub_status!(jid, 'Completed', id: 1)

      post :fetch_status, { job_id: jid, format: :json }, valid_session
      expect(response).to be_successful
      expect(response).to have_json('status' => 'Completed', 'id' => 1, 'errors' => nil)
    end

    it "returns product's status and any errors, if so" do
      stub_status!(jid, 'Working', errors: "Name can't be blank")

      post :fetch_status, { job_id: jid, format: :json }, valid_session
      expect(response).to be_successful
      expect(response).to have_json('status' => 'Failed', 'id' => nil, 'errors' => 'Name can\'t be blank')
    end
  end
end
