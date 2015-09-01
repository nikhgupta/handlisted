require 'rails_helper'

feature "liking a product" do
  background do
    @user = create :confirmed_user
    @product = create :product
  end

  it "requires user to login", :js do
    visit products_path
    expect(page).to have_product_card_for(@product)

    find("[data-pid='#{@product.pid}'] a[data-like]").trigger("click")
    wait_for_traffic

    expect(current_path).to eq new_user_session_path
    expect(page).to have_alert("need to sign in").as_error
  end

  it "toggles like for the user", :js do
    sign_in_with @user.email

    visit products_path
    expect(page).to have_product_card_for(@product)

    find("[data-pid='#{@product.pid}'] a[data-like]").trigger("click")

    expect(page).to have_selector("[data-pid='#{@product.pid}'] a[data-like='on']")
    expect(current_path).to eq products_path
    expect(@user).to be_liking(@product)

    find("[data-pid='#{@product.pid}'] a[data-like]").trigger("click")

    expect(page).to have_selector("[data-pid='#{@product.pid}'] a[data-like='off']")
    expect(current_path).to eq products_path
    expect(@user).not_to be_liking(@product)
  end
end

feature "user likes on product pages" do
  def add_likers(total: 5)
    total -= @product.likers.count
    if total > 0
      create_list(:confirmed_user, total).each do |user|
        user.like @product
      end
    end
    @product.reload.likers
  end
  background do
    @founder = create :confirmed_user
    @product = create :product, founder: @founder
    @likers  = add_likers total: 5
    visit product_path(@product)
  end

  scenario "displays founder as highlighted" do
    expect(page).to have_selector(".user.mini-card.highlight img")
    expect(page).to have_content("Found by @#{@founder.username}")
  end

  scenario "displays likers in a neat grid" do
    selector = ".user.mini-card:not(.highlight) img"
    expect(page).to have_selector(selector, count: 5)

    add_likers total: 15
    visit product_path(@product)
    expect(page).to have_selector(selector, count: 10)
    expect(page).to have_selector(".user.mini-card.counter-card", text: "+5")
  end

  scenario "likes are displayed on info modal box", :js do
    visit products_path
    click_for_product_info_modal @product
    expect(page).to have_selector(".users.mini-list .user.mini-card.highlight")
  end
end
