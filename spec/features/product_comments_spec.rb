require 'rails_helper'

feature "product comments" do
  def add_comment(text: nil)
    sign_in_as(:confirmed_user) unless @signed_in_user.present?
    visit product_path(@product)
    expect(page).to have_selector(".panel-comments .comment-form textarea#comment_comment")
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
  end

  scenario "product profile allows commenting on product when logged in" do
    add_comment
    expect(page).to have_content("this is a comment for this product")
    expect(page).to have_selector("textarea#comment_comment", text: "")
    expect(page).to have_alert("Your comment has been added").as_success
    expect(page).to have_no_content("Displaying 1 comment")
  end

  scenario "product profile allows commenting on product when logged in", :js do
    product_has_existing_comments total: 10
    add_comment

    expect(page).to have_content("this is a comment for this product")
    expect(page).to have_selector("textarea#comment_comment", text: "")
    expect(page).to have_content("Displaying comments 1 - 5 of 11 in total")

    # TODO: new comment should be highlighted for a brief moment
    # selector = ".comments-index .media:first-child .media-body"
    # expect(page).to have_selector("#{selector}.bg-active")
    # expect(page).not_to have_selector("#{selector}.bg-active")    # takes 2 seconds
    # expect(page).to have_selector("#{selector}")
  end

  scenario "displays validation errors when they occur" do
    add_comment text: "short comment"
    expect(page).to have_alert("too short").as_error
  end

  scenario "displays validation errors when they occur", :js do
    add_comment text: "short comment"
    expect(page).to have_selector(".input-footer em.state-error", "too short")

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

    click_on_button "2"
    expect(page).to have_content("Displaying comments 6 - 10 of 13 in total")
    expect(page).to have_content(comments[7].comment)
  end
end
