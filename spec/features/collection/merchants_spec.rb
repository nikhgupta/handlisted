require 'rails_helper'

RSpec.feature "merchants index" do
  background do
    @per_page  = Kaminari.config.default_per_page

    @merchant1 = create :merchant, name: "Merchant X"
    @product1  = create :product, merchant: @merchant1

    @merchant2 = create :merchant, name: "Merchant A"
    @product2  = create :product, merchant: @merchant2
  end

  scenario "lists all merchants across the site" do
    visit "/merchants"

    expect(page).to have_content("Merchant X")
    expect(page).to have_content('All Available Merchants')
    expect(page).to have_linkhref('/merchants/merchant-x')
  end

  scenario "lists all products for the given merchant", :js do
    visit "/merchants/merchant-x"

    expect(page).to have_selector('h3', text: "Products from Merchant X")
    expect(page).to have_product_card_for(@product1)
    expect(page).not_to have_product_card_for(@product2)
  end

  scenario "allows loading more products for the given category", :js, :slow do
    create_list :product, @per_page * 2, merchant: @merchant1
    visit "/merchants/merchant-x"

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
