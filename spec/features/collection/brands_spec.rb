require 'rails_helper'

RSpec.feature "Brands" do
  let(:merch_x){ create :merchant, name: "Merchant X" }
  let(:merch_y){ create :merchant, name: "Merchant Y" }
  let(:brand_a) { create :brand, name: "Brand A", merchant: merch_x }
  let(:brand_b) { create :brand, name: "Brand B", merchant: merch_y }

  background do
    @per_page  = Kaminari.config.default_per_page
  end

  context "Index Page" do
    scenario "lists all brands across a given merchant" do
      visit merchant_brands_path(merch_x)

      expect(page).to     have_content('Available Brands On Merchant X')
      expect(page).not_to have_content('Available Brands On Merchant Y')
      expect(page).to     have_link("Brand A", brand_path(merch_x, brand_a))
      expect(page).not_to have_link("Brand B", brand_path(merch_y, brand_b))
    end
  end
  # background do
  #   @per_page  = Kaminari.config.default_per_page

  #   @merchant1 = create :merchant, name: "Merchant X"
  #   @brand1    = create :brand, name: "Brand Y", merchant: @merchant1
  #   @product1  = create :product, brand: @brand1, merchant: @merchant1

  #   merchant2  = create :merchant, name: "Merchant A"
  #   brand2     = create :brand, name: "Brand B", merchant: merchant2
  #   @product2  = create :product, brand: brand2, merchant: merchant2
  # end


  scenario "lists all products for the given brand", :js do
    visit "/brands/merchant-x/brand-y"

    expect(page).to have_selector('h3', text: "Brand Y, a unique brand on Merchant X")
    expect(page).to have_product_card_for(@product1)
    expect(page).not_to have_product_card_for(@product2)
  end

  scenario "allows loading more products for the given category", :js, :slow do
    create_list :product, @per_page * 2, brand: @brand1, merchant: @merchant1
    visit "/brands/merchant-x/brand-y"

    expect(page).to have_selector('.product.card', count: @per_page)
    expect(page).to have_link("Load More")

    click_on_link "Load More"
    expect(page).not_to have_css('.pagination img')
    expect(page).to have_selector(".product.card", count: @per_page * 2)

    page.execute_script('window.scrollTo(0,100000)')
    expect(page).to have_css('.pagination img')
    expect(page).not_to have_css('.pagination img')
    expect(page).to have_selector(".product.card", count: @per_page * 2 + 1)
  end
end
