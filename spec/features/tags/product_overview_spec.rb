RSpec.feature "Product Overview", :js, :slow do
  let(:product) { create :product }

  # FIXME: paragraphs are not preserved here!
  it "presents formatted HTML from the product description's markdown" do
    markdown = "### Heading 3\n[link title](http://example.com)"
    product.update_attribute :description, markdown

    visit product_path(product)
    within(".product.overview .product-description") do
      expect(page).to have_selector("h3", text: "Heading 3")
      expect(page).to have_link("link title", href: "http://example.com")
    end
  end

  context "User Likes" do
    scenario "displays likers in a neat grid" do
      add_likers_for_product product, 2
      visit product_path(product)
      expect(page).to have_selector(".user.card", count: 3) # likers + founder

      add_likers_for_product product, 4
      visit product_path(product)
      expect(page).to have_selector(".user.card", count: 7) # likers + founder
    end
    scenario "displays founder as highlighter user" do
      visit product_path(product)
      expect(page).to have_selector(".user.card.primary a img")
      expect(page).to have_content("Found by @#{product.founder.username}")

      link_selector = "#user-#{product.founder.id}.user.card.primary a"
      expect(find(link_selector)[:href]).to end_with "/#{product.founder.username}"
    end
  end
  context "Logged-in User" do
    scenario "liking a product toggles like by the user" do
      user = sign_in_as :confirmed_user
      visit product_path(product)
      expect(like_status_for(product)).to be_falsey
      expect(user).not_to be_liking product

      toggle_like_for_product product
      expect(current_path).to eq product_path(product)
      expect(like_status_for(product)).to be_truthy
      expect(user).to be_liking product

      toggle_like_for_product product
      expect(like_status_for(product)).to be_falsey
      expect(user).not_to be_liking product
    end
  end
  context "Site Visitor" do
    scenario "liking product requires signing-in" do
      visit product_path(product)
      toggle_like_for_product product
      expect(current_path).to eq new_user_session_path
      expect(page).to have_alert("need to sign in").as_error
    end
  end
end
