require 'rails_helper'

RSpec.feature "infinite scrolling for products listing", :js do
  background do
    @per_page = Kaminari.config.default_per_page
  end

  scenario "loads more records when 'load more' button is clicked" do
    create_list(:product, @per_page + 1)
    expect(Product.count).to be > @per_page
    visit root_path

    expect(page).to have_link("Load More")
    expect(page).to have_css(".product-card", count: @per_page)

    click_on_link "Load More"
    expect(page).not_to have_css('.pagination img')
    expect(page).to have_css(".product-card", count: Product.count)
  end

  scenario "loads more records when scrolled to bottom of page once 'load more' has been clicked", :slow do
    create_list(:product, @per_page * 2 + 1)
    expect(Product.count).to be > @per_page * 2
    visit products_path

    expect(page).to have_link("Load More")

    click_on_link "Load More"
    expect(page).to have_css(".product-card", count: @per_page * 2)

    page.execute_script('window.scrollTo(0,100000)')
    expect(page).to have_css('.pagination img[src="/assets/ajax-loader.gif"]')
    expect(page).not_to have_css('.pagination img[src="/assets/ajax-loader.gif"]')
    expect(page).to have_css(".product-card", count: Product.count)
    expect(page).to have_css("p.bg-header", text: "reached the end")
  end
end
