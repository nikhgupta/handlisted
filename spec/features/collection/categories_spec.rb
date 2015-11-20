require 'rails_helper'

RSpec.feature "category index" do
  background do
    @p1, c1, s1 = Category.create_hierarchy :parent1, :child1, :subchild1
    @p2, c2, s2 = Category.create_hierarchy :parent2, :child2, :subchild2
    @p3, c3, s3 = Category.create_hierarchy :parent3, :child3, :subchild3
    @product1   = create :product, category: c1
    @product2   = create :product, category: s2
    @per_page   = Kaminari.config.default_per_page
  end
  scenario "lists all root categories across the site with atleast one product" do
    visit shop_path

    expect(page).to have_content('Parent1')
    expect(page).to have_content('Parent2')

    expect(page).to have_no_content('Child1')
    expect(page).to have_no_content('Subchild2')
    expect(page).to have_no_content('Parent3')

    expect(page).to have_linkhref('/shop/parent1')
    expect(page).to have_linkhref('/shop/parent2')
  end

  scenario "lists products for the given root category without any products" do
    visit category_path(@p3)
    expect(page).to have_content("No products were found for this category")
  end

  scenario "lists all products for the given root category", :js do
    visit category_path(@p1)

    expect(page).to have_selector('h3', text: "Parent1")
    expect(page).to have_product_card_for(@product1)
    expect(page).not_to have_product_card_for(@product2)
  end

  scenario "allows loading more products for the given category", :js, :slow do
    create_list :product, @per_page * 2, category: @p2
    visit category_path(@p2)

    expect(page).to have_selector('h3', text: "Parent2")
    expect(page).to have_selector('.productCard', count: @per_page)
    expect(page).to have_link("Load More")

    click_on_link "Load More"
    expect(page).not_to have_css('.pagination img')
    expect(page).to have_selector(".productCard", count: @per_page * 2)

    page.execute_script('window.scrollTo(0,100000)')
    expect(page).to have_css('.pagination img')
    expect(page).not_to have_css('.pagination img')
    expect(page).to have_selector(".productCard", count: @per_page * 2 + 1)
  end
end
