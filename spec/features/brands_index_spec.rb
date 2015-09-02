require 'rails_helper'

feature "brands index" do
  background do
    @per_page  = Kaminari.config.default_per_page

    @merchant1 = create :merchant, name: "Merchant X"
    @brand1    = create :brand, name: "Brand Y", merchant: @merchant1
    @product1  = create :product, brand: @brand1, merchant: @merchant1

    merchant2  = create :merchant, name: "Merchant A"
    brand2     = create :brand, name: "Brand B", merchant: merchant2
    @product2  = create :product, brand: brand2, merchant: merchant2
  end

  scenario "lists all brands across a given merchant" do
    visit "/brands/merchant-x"

    expect(page).to have_content("Brand Y")
    expect(page).to have_content('Available Brands On Merchant X')
    expect(page).to have_linkhref('/brands/merchant-x/brand-y')

    expect(page).not_to have_content("Brand B")
    expect(page).not_to have_content('Available Brands on Merchant A')
    expect(page).not_to have_linkhref('/brands/merchant-a/brand-b')
  end

  scenario "lists all products for the given brand", :js do
    visit "/brands/merchant-x/brand-y"

    expect(page).to have_selector('h3', text: "Brand Y, a unique brand on Merchant X")
    expect(page).to have_product_card_for(@product1)
    expect(page).not_to have_product_card_for(@product2)
  end

  scenario "allows loading more products for the given category", :js do
    create_list :product, @per_page * 2, brand: @brand1, merchant: @merchant1
    visit "/brands/merchant-x/brand-y"

    expect(page).to have_selector('.product-card', count: @per_page)
    expect(page).to have_link("Load More")

    click_on_link "Load More"
    expect(page).not_to have_css('.pagination img')
    expect(page).to have_selector(".product-card", count: @per_page * 2)

    page.execute_script('window.scrollTo(0,100000)')
    expect(page).to have_css('.pagination img[src="/assets/ajax-loader.gif"]')
    expect(page).not_to have_css('.pagination img[src="/assets/ajax-loader.gif"]')
    expect(page).to have_selector(".product-card", count: @per_page * 2 + 1)
  end
end
