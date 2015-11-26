require 'rails_helper'

RSpec.feature "search products from search bar", :js, :slow do
  background do
    @user = sign_in_as :confirmed_user
    @moto = add_product @user, :moto_x
    @kindle = add_product @user, :kindle
    visit root_path
  end

  scenario "search does not require logging in" do
    sign_out_if_logged_in
    visit root_path
    search_using_sitewide_search('bags')
    expect(current_path).not_to eq new_user_session_path
    expect(page).to have_selector('#product_search')
    expect(page).to have_no_selector('header .progress-bar')
  end

  scenario "search should notify when no matching products are found" do
    search_using_sitewide_search('bags')
    expect(current_path).to eq(products_path)
    expect(page).to have_alert("No matching products were found").as_pastel
    expect(page).not_to have_product_card_for(@kindle)
    expect(page).not_to have_product_card_for(@kindle)
  end

  scenario "search should list only matching products" do
    search_using_sitewide_search('kindle')
    expect(page).to have_product_card_for(@kindle)
    expect(page).not_to have_product_card_for(@moto)
    expect(page).to have_no_alert("No matching products were found")
  end

  scenario "search should behave similar to product listing"
  scenario "search should prioritize products for revenue and interest"
end
