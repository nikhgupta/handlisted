require 'rails_helper'

RSpec.describe Services::FeedsController, type: :controller do
  describe "GET #recent" do
    it "assigns all recent products as @products" do
      product1 = create(:product)
      product2 = create(:product)
      get :recent, format: :rss
      expect(assigns(:products)).to eq([product2, product1])
    end
  end
end
