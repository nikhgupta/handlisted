require 'rails_helper'

RSpec.feature "Product Overview Card" do
  let(:product){ create :product }
  def toggle_like_for_product(product)
    find("[data-pid='#{product.pid}'] a[data-like]").trigger('click')
    wait_for_traffic
  end

  def like_status_for(product)
    find("[data-pid='#{product.pid}'] a[data-like]")['data-like']
  end

  context "when not logged in" do
    scenario "product can not be liked", :js do
      visit product_path(product)
      toggle_like_for_product product
      expect(current_path).to eq new_user_session_path
      expect(page).to have_alert("need to sign in").as_error
    end
  end

  context "when logged in" do
    scenario "product can be liked", :js do
      user = sign_in_as :confirmed_user
      visit product_path(product)
      expect(like_status_for(product)).to eq "off"
      expect(user).not_to be_liking product

      toggle_like_for_product product
      expect(current_path).to eq product_path(product)
      expect(like_status_for(product)).to eq "on"
      expect(user).to be_liking product

      toggle_like_for_product product
      expect(like_status_for(product)).to eq "off"
      expect(user).not_to be_liking product
    end
  end
end
