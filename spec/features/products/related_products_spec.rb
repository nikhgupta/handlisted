require 'rails_helper'

RSpec.feature "related products for a product" do
  background do
    p1, c1, s1 = Category.create_hierarchy :parent1, :child1, :subchild1
    p2, c2, s2 = Category.create_hierarchy :parent2, :child2, :subchild2
    @product1   = create :product, category: s1, name: "Product 1"
    @product2   = create :product, category: s1, name: "Product 2"
    @product3   = create :product, category: c1
    @product4   = create :product, category: s2
  end

  scenario "product has related products from descendants of its category hierarchy" do
    visit product_path(@product3)
    selector = ".panel-related .product.card-mini"

    expect(page).to have_selector("#{selector}[data-pid='#{@product1.pid}']")
    expect(page).to have_selector("#{selector}[data-pid='#{@product2.pid}']")
    expect(page).to have_no_selector("#{selector}[data-pid='#{@product4.pid}']")
  end

  scenario "product does not have related products from ancestors of its category hierarchy" do
    visit product_path(@product1)
    selector = ".panel-related .product.card-mini"

    expect(page).to have_selector("#{selector}[data-pid='#{@product2.pid}']")
    expect(page).to have_no_selector("#{selector}[data-pid='#{@product3.pid}']")
    expect(page).to have_no_selector("#{selector}[data-pid='#{@product4.pid}']")
  end

  scenario "related products can be clicked to view their overview" do
    visit product_path(@product1)
    find(".related-product").click
    expect(page).to have_selector(".product.card-overview[data-pid='#{@product2.pid}']")
    expect(page.current_path).to eq product_path(@product2)
  end

  scenario "related products can be clicked to view their overview", js: true do
    visit product_path(@product1)
    find(".related-product").trigger('click')

    expect(page.current_path).to eq product_path(@product1)
    within "#modal-panel" do
      expect(page).to have_selector(".product.card-overview[data-pid='#{@product2.pid}']")
      expect(page).to have_selector("h1", text: "Product 2")
      find(".related-product").trigger('click')
    end

    within "#modal-panel" do
      expect(page).to have_selector(".product.card-overview[data-pid='#{@product1.pid}']")
      expect(page).to have_selector("h1", text: "Product 1")
    end
  end
end
