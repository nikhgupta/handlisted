require 'rails_helper'

RSpec.feature "listings on user's public profile", :js do
  def setup(user, options = {})
    liked = create_list(:product, options[:likes] || 1)
    found = create_list(:product, (options[:found] || 1), founder: user)
    liked.each{ |product| user.like(product) }

    visit "/johnsmith" if options[:visit]

    [liked, found]
  end

  background do
    @per_page = Kaminari.config.default_per_page
    @user  = create(:user, name: "John Smith", username: "johnsmith", image: "/some-broken-image")
    @random = create(:product)
  end

  scenario 'users have a public profile' do
    setup @user, likes: 1, found: 2, visit: true
    expect(page).to have_content("@johnsmith")
    expect(page).to have_content("Likes 1 product")
    expect(page).to have_content("Found 2 products")
  end

  # NOTE: test for checking replacement of broken avatar images,
  # but this fails since poltergeist still returns the actual image's src tag.
  #
  # scenario 'missing avatar is displayed for broken avatar images', :js do
  #   create(:user_with_full_info, name: "Stupid user", username: "stupiduser")
  #   visit '/stupiduser'
  #   expect(page).to have_selector("img[src='/images/avatars/missing.jpg']")
  # end

  scenario 'lists the product that the user likes' do
    liked, found = setup @user, likes: 1, found: 2, visit: true

    expect(page).to have_linkhref("#liked-products")
    expect(page).to have_product_card_for(found[0])
    expect(page).not_to have_product_card_for(liked[0])
    expect(page).not_to have_product_card_for(@random)

    expect(page).to have_linkhref("#found-products")
    find(:linkhref, "#liked-products").trigger('click')
    expect(page).to have_product_card_for(liked[0])
    expect(page).not_to have_product_card_for(found[0])
    expect(page).not_to have_product_card_for(@random)
  end

  context 'has infinite scrolling for these listings' do
    scenario "loads more records when 'load more' button is clicked", :slow do
      count = @per_page * 2 + 1
      liked, found = setup @user, likes: count, found: count, visit: true
      expect(page).to have_link("Load More")
      expect(page).to have_css(".productCard", count: @per_page)

      click_on_link "Load More"
      expect(page).not_to have_css('.pagination img')
      expect(page).to have_css(".productCard", count: @per_page * 2)

      page.execute_script('window.scrollTo(0,100000)')
      expect(page).to have_css(".productCard", count: liked.count)
      expect(page).to have_css("p.bg-header", text: "reached the end")
    end
  end
end

RSpec.feature "listings on user's personal profile", :js do
  def setup(user, options = {})
    liked = create_list(:product, options[:likes] || 1)
    found = create_list(:product, (options[:found] || 1), founder: user)
    liked.each{ |product| user.like(product) }

    visit "/profile/edit" if options[:visit]

    [liked, found]
  end

  background do
    @per_page = Kaminari.config.default_per_page
    @random = create(:product)
    @user  = create(:confirmed_user, name: "John Smith", username: "johnsmith")
    sign_in_with @user.email, "password"
  end

  scenario 'users can see their profile' do
    setup @user, likes: 1, found: 2, visit: true
    expect(page).to have_content("@johnsmith")
    expect(page).to have_content("Likes 1 product")
    expect(page).to have_content("Found 2 products")
  end

  scenario 'lists the product that the user likes' do
    liked, found = setup @user, likes: 1, found: 2, visit: true

    expect(page).to have_linkhref("#liked-products")
    expect(page).to have_product_card_for(liked[0])
    expect(page).not_to have_product_card_for(found[0])
    expect(page).not_to have_product_card_for(@random)

    expect(page).to have_linkhref("#found-products")
    find(:linkhref, "#found-products").trigger('click')

    expect(page).to have_product_card_for(found[0])
    expect(page).not_to have_product_card_for(liked[0])
    expect(page).not_to have_product_card_for(@random)
  end

  context 'has infinite scrolling for these listings' do
    scenario "loads more records when 'load more' button is clicked", :slow do
      count = @per_page * 2 + 1
      liked, found = setup @user, likes: count, found: count, visit: true
      expect(page).to have_link("Load More")
      expect(page).to have_css(".productCard", count: @per_page)

      click_on_link "Load More"
      expect(page).not_to have_css('.pagination img')
      expect(page).to have_css(".productCard", count: @per_page * 2)

      page.execute_script('window.scrollTo(0,100000)')
      expect(page).to have_css(".productCard", count: liked.count)
      expect(page).to have_css("p.bg-header", text: "reached the end")
    end
  end
end
