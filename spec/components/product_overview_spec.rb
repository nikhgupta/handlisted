RSpec.feature "Product Overview", :js, :slow, type: :feature do
  let(:product) { create :product }

  def add_comment(product, text: nil)
    sign_in_as(:confirmed_user) unless @signed_in_user.present?
    visit product_path(product)
    expect(page).to have_selector(".product-comments .comment-form textarea#comment_comment")
    fill_in "comment_comment", with: (text || "this is a comment for this product")
    click_on_button "Add Comment"
  end

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

  context "Product Comments" do
    scenario "product profile does not allow commenting when logged out" do
      visit product_path(product)
      expect(page).to have_no_selector(".panel-comments .comment-form")
      expect(page).to have_content("login to add comments")
      expect(page).to have_content("No comments were found")
    end
    scenario "product profile allows commenting on product when logged in" do
      add_comment product, text: "this is a comment for this product"

      expect(page).to have_content("this is a comment for this product")
      expect(page).to have_selector("textarea#comment_comment", text: "")
      expect(page).to have_no_alert("Your comment has been added")
      expect(page).to have_css(".comment-result.text-success", text: "Comment Posted!")
    end
    scenario "displays validation errors when they occur" do
      add_comment product, text: "short comment"
      expect(page).to have_css(".comment-result.text-danger", text: "is too short")
    end
  end

  context "Related Products" do
    background do
      p1, c1, s1 = Category.create_hierarchy :parent1, :child1, :subchild1
      p2, c2, s2 = Category.create_hierarchy :parent2, :child2, :subchild2
      @product1   = create :product, category: s1, name: "Product 1"
      @product2   = create :product, category: s1, name: "Product 2"
      @product3   = create :product, category: c1
      @product4   = create :product, category: s2
    end
    scenario "are populated from descendants of its category hierarchy" do
      visit product_path(@product3)
      selector = ".panel.related-products .product.card.mini"

      expect(page).to have_selector("#{selector}[data-pid='#{@product1.pid}']")
      expect(page).to have_selector("#{selector}[data-pid='#{@product2.pid}']")
      expect(page).to have_no_selector("#{selector}[data-pid='#{@product4.pid}']")
    end
    scenario "are not populated from ancestors of its category hierarchy" do
      visit product_path(@product1)
      selector = ".panel.related-products .product.card.mini"

      expect(page).to have_selector("#{selector}[data-pid='#{@product2.pid}']")
      expect(page).to have_no_selector("#{selector}[data-pid='#{@product3.pid}']")
      expect(page).to have_no_selector("#{selector}[data-pid='#{@product4.pid}']")
    end
    scenario "show overview of the product in a modal, when clicked" do
      pending "issue #116"
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
    scenario "related products has load more view"
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
    scenario "comments are allowed", :slow, :js do
      pending
      sign_in_as(:confirmed_user) unless @signed_in_user.present?
      visit product_path(@product)
      expect(page).to have_selector(".panel-comments .commentForm textarea#comment_comment")
      fill_in "comment_comment", with: (text || "this is a comment for this product")
      click_on_button "Add Comment"
      # skip "test specific to non-js environment" if js_test?
      expect(page).to have_content("this is a comment for this product")
      expect(page).to have_selector("textarea#comment_comment", text: "")
      expect(page).to have_alert("Your comment has been added").as_success
      expect(page).to have_content("Displaying 1 comment")
    end
  end
  context "Site Visitor" do
    scenario "liking product requires signing-in" do
      visit product_path(product)
      toggle_like_for_product product
      expect(current_path).to eq new_user_session_path
      expect(page).to have_alert("need to sign in").as_error
    end
    scenario "comments are visible" do
      pending
      visit product_path(product)
      expect(page).to have_no_selector(".panel-comments .comment-form")
      expect(page).to have_content("login to add comments")
      expect(page).to have_no_content("No comments were found")
    end
    scenario "commenting is disabled" do
      pending
      visit product_path(product)
      expect(page).to have_no_selector(".panel-comments .comment-form")
      expect(page).to have_content("login to add comments")
      expect(page).to have_no_content("No comments were found")
    end
  end
end
