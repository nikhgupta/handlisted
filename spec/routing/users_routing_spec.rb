require "rails_helper"

RSpec.describe UsersController, type: :routing do
  describe "routing" do

    it "does not route to #index" do
      expect(get: "/users").not_to route_to("users#index")
    end

    it "does not route to #new" do
      expect(get: "/users/new").not_to be_routable
    end

    it "does not route to #show with an id" do
      expect(get: "/users/1").not_to be_routable
    end

    it "routes to #show with username" do
      expect(get: "/someuser").to route_to("users#show", username: "someuser")
    end

    it "does not route to #create" do
      expect(post: "/users").not_to be_routable
    end

    it "does not route to #destroy" do
      expect(delete: "/users/1").not_to be_routable
    end

    # it "routes to #edit" do
    #   expect(get: "/users/1/edit").to route_to("users#edit", id: "1")
    # end

    # it "routes to #update via PUT" do
    #   expect(put: "/users/1").to route_to("users#update", id: "1")
    # end

    # it "routes to #update via PATCH" do
    #   expect(patch: "/users/1").to route_to("users#update", id: "1")
    # end

    # it "does not route edit profile path for guest users" do
    #   expect(get: "/profile/edit").not_to be_routable
    # end
  end
end
