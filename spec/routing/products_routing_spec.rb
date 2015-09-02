require "rails_helper"

RSpec.describe ProductsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get: "/products").to route_to("products#index")
    end

    it "does not route to #new" do
      expect(get: "/products/new").to route_to("products#show", id: "new")
    end

    it "routes to #show" do
      expect(get: "/products/1").to route_to("products#show", id: "1")
    end

    it "routes to #create" do
      expect(post: "/products").to route_to("products#create")
    end

    it "does not route to #edit" do
      expect(get: "/products/1/edit").not_to be_routable
    end

    it "does not route to #update via PUT" do
      expect(put: "/products/1").not_to be_routable
    end

    it "does not route to #update via PATCH" do
      expect(patch: "/products/1").not_to be_routable
    end

    it "does not route to #destroy" do
      expect(delete: "/products/1").not_to be_routable
    end

    it "routes to #fetch_status" do
      expect(post: "/products/create/status").to route_to("products#fetch_status", format: :json)
      expect(post: "/products/create/status.html").not_to be_routable
    end

    it "routes to #verify_url" do
      expect(post: "/products/create/check").to route_to("products#verify_url", format: :json)
      expect(post: "/products/create/check.html").not_to be_routable
    end

    it "routes to #search" do
      expect(post: "/products/search").to route_to("products#search")
      expect(post: search_or_add_products_path).to route_to("products#search")
    end

    it "routes to #go" do
      expect(get: "/products/1/go").to route_to("products#visit", id: "1")
      expect(get: visit_product_path(id: 1)).to route_to("products#visit", id: "1")
    end

    it "routes to #like" do
      expect(post: "/products/1/like").to route_to("products#like", id: "1", format: :js)
      expect(post: "/products/create/like.json").not_to be_routable
    end
  end
end
