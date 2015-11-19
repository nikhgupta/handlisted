require 'rails_helper'

RSpec.feature "related products for a product" do
  background do
    p1, c1, s1 = Category.create_hierarchy :parent1, :child1, :subchild1
    p2, c2, s2 = Category.create_hierarchy :parent2, :child2, :subchild2
    @product1   = create :product, category: s1
    @product2   = create :product, category: s1
    @product3   = create :product, category: c1
    @product4   = create :product, category: s2
  end

  scenario "product has related products from descendants of its category hierarchy" do
    visit product_path(@product3)
    selector = ".panel-related .product.mini-card"

    expect(page).to have_selector("#{selector}[data-pid='#{@product1.pid}']")
    expect(page).to have_selector("#{selector}[data-pid='#{@product2.pid}']")
    expect(page).to have_no_selector("#{selector}[data-pid='#{@product4.pid}']")
  end

  scenario "product does not have related products from ancestors of its category hierarchy" do
    visit product_path(@product1)
    selector = ".panel-related .product.mini-card"

    expect(page).to have_selector("#{selector}[data-pid='#{@product2.pid}']")
    expect(page).to have_no_selector("#{selector}[data-pid='#{@product3.pid}']")
    expect(page).to have_no_selector("#{selector}[data-pid='#{@product4.pid}']")
  end
end
