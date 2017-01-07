require 'rails_helper'

RSpec.feature "Product Comments" do
  def add_comment(text: nil)
    sign_in_as(:confirmed_user) unless @signed_in_user.present?
    visit product_path(@product)
    expect(page).to have_selector(".panel-comments .commentForm textarea#comment_comment")
    fill_in "comment_comment", with: (text || "this is a comment for this product")
    click_on_button "Add Comment"
  end

  def product_has_existing_comments(total: 10)
    lorem = "lorem ipsum dolor sit amet consectetur adipiscing elit sed do magna aliqua"
    comments = total.times.map do
      { user: User.all.sample, comment: lorem.split(" ").shuffle.join(" ") }
    end
    @product.comments.create comments
  end

  background do
    @product = create(:product)
  end

  scenario "product profile does not allow commenting when logged out" do
    visit product_path(@product)
    expect(page).to have_no_selector(".panel-comments .comment-form")
    expect(page).to have_content("login to add comments")
    expect(page).to have_no_content("No comments were found")
  end

  scenario "product profile allows commenting on product when logged in", :slow, :js do
    add_comment
    # skip "test specific to non-js environment" if js_test?
    expect(page).to have_content("this is a comment for this product")
    expect(page).to have_selector("textarea#comment_comment", text: "")
    expect(page).to have_alert("Your comment has been added").as_success
    expect(page).to have_content("Displaying 1 comment")
  end

  scenario "displays validation errors when they occur" do
    add_comment text: "short comment"
    expect(page).to have_alert("too short").as_error
  end

  scenario "allows loading more comments" do
    comments = product_has_existing_comments total: 13

    visit product_path(@product)
    expect(page).to have_content("Displaying comments 1 - 5 of 13 in total")
    expect(page).to have_content(comments[11].comment)

    click_on_link "2"
    expect(page).to have_content("Displaying comments 6 - 10 of 13 in total")
    expect(page).to have_content(comments[7].comment)

    click_on_link "3"
    expect(page).to have_content("Displaying comments 11 - 13 of 13 in total")
    expect(page).to have_content(comments[1].comment)
  end

  context "with javascript", :js do
    scenario "product profile allows commenting on product when logged in" do
      product_has_existing_comments total: 10
      add_comment

      expect(page).to have_content("this is a comment for this product")
      expect(page).to have_selector("textarea#comment_comment", text: "")
      expect(page).to have_content("Displaying comments 1 - 5 of 11 in total")
    end

    scenario "displays validation errors when they occur" do
      add_comment text: "short comment"
      message = "Please enter at least 20 characters."
      expect(page).to have_selector(".input-footer em.state-error", text: message)

      allow_any_instance_of(Comment).to receive(:save).and_return(false)
      add_comment text: "comment that will not be saved"
      expect(page).to have_no_selector(".input-footer em.state-error")
      expect(page).to have_alert("Encountered an error").as_error
    end

    scenario "allows loading more comments via AJAX" do
      comments = product_has_existing_comments total: 13

      visit product_path(@product)
      expect(page).to have_content("Displaying comments 1 - 5 of 13 in total")
      expect(page).to have_no_content(comments[7].comment)

      click_on_link "2"
      expect(page).to have_content("Displaying comments 6 - 10 of 13 in total")
      expect(page).to have_content(comments[7].comment)
    end
  end

  context "with javascript modals", :js do
    scenario "lists current comments for product, and does not allow comments if not logged in" do
      sign_out_if_logged_in
      visit products_path
      product_has_existing_comments total: 10
      click_for_product_info_modal @product

      expect(page).to have_content("login to add comments")
      expect(page).to have_no_selector("textarea#comment_comment")
      expect(page).to have_selector(".commentsList .commentCard", count: 5)
      expect(page).to have_content("Displaying comments 1 - 5 of 10 in total")
    end

    scenario "product profile nicely renders firstever created comment for the product" do
      sign_in_as :confirmed_user
      visit products_path
      click_for_product_info_modal @product

      fill_in "comment_comment", with: "this is a comment for this product"
      click_on_button "Add Comment"

      expect(page).to have_content("this is a comment for this product")
      expect(page).to have_selector("textarea#comment_comment", text: "")
    end

    scenario "displays validation errors when they occur", :js do
      add_comment text: "short comment"
      message = "Please enter at least 20 characters."
      expect(page).to have_selector(".input-footer em.state-error", text: message)

      allow_any_instance_of(Comment).to receive(:save).and_return(false)
      add_comment text: "comment that will not be saved"
      expect(page).to have_no_selector(".input-footer em.state-error")
      expect(page).to have_alert("Encountered an error").as_error
    end

    scenario "allows loading more comments via AJAX" do
      comments = product_has_existing_comments total: 13

      visit product_path(@product)
      expect(page).to have_content("Displaying comments 1 - 5 of 13 in total")
      expect(page).to have_no_content(comments[7].comment)

      click_on_link "2"
      expect(page).to have_content("Displaying comments 6 - 10 of 13 in total")
      expect(page).to have_content(comments[7].comment)
    end
  end
end
