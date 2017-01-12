RSpec.feature "HomePage" do
  scenario "has navigation links" do
    visit root_path
    expect(page).to have_link("Home", href: "/")
    expect(page).to have_link("Discover", href: "/products")
    expect(page).to have_link("Log in", href: "/login", count: 2)
    expect(page).to have_link("Register", href: "/register", count: 2)

    expect(page).to have_link("About", href: "/pages/about")
    expect(page).to have_link("Add Products", href: "/pages/add-products")
    expect(page).to have_link("Feedback", href: "mailto:feedback@handlisted.in")

    sign_in_as :confirmed_user, username: "testuser"
    visit root_path

    expect(page).to have_link("Profile", href: "/testuser")
    expect(page).to have_link("Log out", href: "/logout")
  end

  scenario "displays featured product", :js do
    products = create_list :product, 3
    visit root_path
    expect(page).to have_product_card_for(products.last)
  end

  scenario "animates number of products that have been curated", :js do
    pending "not sure how to make number animate!"

    products = create_list :product, 3
    visit root_path
    expect(page).to have_content "0 PRODUCTS CURATED"
    page.execute_script "window.scrollBy(0,1000)"
    expect(page).to have_content "1 PRODUCTS CURATED"
  end

  scenario "displays percentage of products reviewed by community"

  scenario "has links to add products and learn more about them" do
    visit root_path
    expect(page).to have_link "Browse Products", href: "/products"
    expect(page).to have_link "Learn More", href: "/pages/add-products"
    expect(page).to have_link "Add a Product", href: "/pages/add-products"
  end

  scenario "has social links" do
    visit root_path
    expect(page).to have_css("a[href='http://twitter.com/handlisted'] i.fa.fa-2x.fa-twitter")
  end

  scenario "displays random category cards", :js do
    categories = create_list :category, 5
    categories.each{|cat| create :product, category: cat }
    visit root_path
    expect(page).to have_css(".category.card", count: 3)
  end

  scenario "has subscription form", :js do
    visit root_path
    within "form[action='/newsletter/subscribe']" do
      expect(page).to have_field "Email"
      expect(page).to have_button "Subscribe"
    end
  end
end
