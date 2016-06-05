require 'rails_helper'

RSpec.feature "search products from search bar", :js, :slow do
  background do
    @user    = sign_in_as :confirmed_user
    @moto    = add_product @user, :moto_x
    @kindle  = add_product @user, :kindle
    @import  = "http://www.amazon.in/Physique-Grip-Trainer/dp/B00L4VS12S/ref=pd_sbs_200_5"
    @import2 = "http://www.amazon.in/Kingston-Micro-SDHC-class-memory/dp/B007W0NFCG/ref=sr_1_16"
    Product.where(pid: "B00L4VS12S").destroy_all
    create_list :product, 12, founder: @user
    visit root_path
  end

  scenario "search does not require logging in" do
    sign_out_if_logged_in
    visit root_path
    search_using_sitewide_search :bags
    expect(current_path).to eq root_path
    expect(page).to have_field :search, with: :bags
  end

  scenario "search should notify when no matching products are found" do
    search_using_sitewide_search :bags
    expect(current_path).to eq(root_path)
    expect_search_to_show_message "No products were found"
    expect_search_not_to have_product_card_for(@moto)
    expect_search_not_to have_product_card_for(@kindle)
  end

  scenario "search messages should disappear when search field is empty" do
    search_using_sitewide_search :bags
    expect(page).to have_text("No products were found")
    search_using_sitewide_search nil
    expect_search_to_show_message "Instant search"
  end

  scenario "search should list only matching products" do
    search_using_sitewide_search('kindle')
    expect(current_path).to eq(root_path)
    expect_search_to have_product_card_for(@kindle)
    expect_search_not_to have_product_card_for(@moto)
    expect(page).not_to have_text("No products were found")

    search_using_sitewide_search('moto')
    expect_search_not_to have_product_card_for(@kindle)
    expect_search_to have_product_card_for(@moto)
    expect(page).not_to have_text("No products were found")
  end

  scenario "instant search only displays upto 8 products" do
    search_using_sitewide_search('product')
    within(".overlay"){ expect(page).to have_selector ".product.card", count: 8 }
  end

  scenario "search is reset when the overlay is closed" do
    search_using_sitewide_search('product')
    within(".overlay"){ expect(page).to have_selector ".product.card", count: 8 }

    find(".overlay-close").trigger 'click'
    click_on_link "anywhere to search"
    expect_search_to_show_message "Instant search"
    within(".overlay"){
      expect(page).not_to have_field :search, with: "product"
      expect(page).not_to have_selector ".product.card"
    }
  end

  scenario "all search results can be seen by clicking view all results" do
    search_using_sitewide_search('product')
    within(".overlay"){ expect(page).to have_selector ".product.card", count: 8 }
    click_on_link "View All"
    expect(current_path).to eq search_or_add_products_path
    expect(page).to have_selector ".product.card", count: 12
  end

  scenario "all search results can be seen by pressing Enter when searching" do
    search_using_sitewide_search('moto', instant: false)
    expect(page).to have_selector ".product.card", count: 1
    expect(current_path).to eq search_or_add_products_path

    search_using_sitewide_search('product', instant: false)
    expect(page).to have_selector ".product.card", count: 12
    expect(current_path).to eq search_or_add_products_path
  end

  scenario "search should behave similar to product listing"
  scenario "search should prioritize products for revenue and interest"

  scenario "detects a product url in a query" do
    search_using_sitewide_search @import
    within(".overlay"){ expect(page).to have_button "Import Product" }
    search_using_sitewide_search PRODUCTS_LIST[:invalid][:url]
    within(".overlay"){ expect(page).to have_no_button "Import Product" }
  end

  scenario "adding products from search requires signing in" do
    sign_out_if_logged_in
    visit root_path
    add_product_via_sitewide_search @import, instant: false
    expect(current_path).to eq new_user_session_path

    visit root_path
    add_product_via_sitewide_search @import, instant: true
    click_on_link "Import Product"
    expect(current_path).to eq new_user_session_path
  end

  scenario "users adds a product url in query" do
    add_product_via_search_and_perform(@import) do
      expect(page).to have_selector('nav.header .progress-bar.progress-bar-primary')
      status = progress_status
      expect(status).to be >= 30
      sleep 1
      expect(progress_status).to be_within(0.1).of(status + 3)
    end
    expect(page).to have_selector('nav.header .progress-bar-success')
    wait_for_traffic
    product = Product.find_by(pid: "B00L4VS12S")
    expect(product).to be_persisted
    expect(current_path).to eq root_path
    expect_search_to_show_message "Import was Successful"
    expect_search_to have_product_card_for(product)
  end

  scenario "user searches for a product after just adding a product" do
    add_product_via_search_and_perform(@import)
    product = Product.find_by(pid: "B00L4VS12S")
    expect_search_to_show_message "Import was Successful"
    expect_search_to have_product_card_for(product)

    search_using_sitewide_search('product')
    expect_search_not_to have_text "Import was successful"
    expect_search_not_to have_text "No products were found"
    expect_search_to have_selector ".product.card", count: 8
  end

  scenario "user adds a product after just adding another one" do
    add_product_via_search_and_perform(@import)
    product = Product.find_by(pid: "B00L4VS12S")

    add_product_via_search_and_perform(@import2) do
      expect(page).not_to have_text "Import was Successful"
      expect_search_to have_selector('.progress-bar-master')
      save_and_open_screenshot
      expect_search_not_to have_product_card_for(product)
      status = progress_status
      expect(status).to be >= 30
    end

    product = Product.find_by(pid: "B007W0NFCG")
    expect_search_to_show_message "Import was Successful"
    expect_search_to have_product_card_for(product)
  end

  scenario "detects a product url in a query that has already been imported"

  scenario "user adds product URL that does not exist" do
    expect { add_product_via_search_and_perform :invalid }.not_to raise_error
    expect(page).to have_selector('header .progress-bar-danger', text: "Failed")
    expect(page).to have_selector('.product-adder-errors', text: /no product.*?here/i)
  end

  scenario "user adds a product which induces an error" do
    allow(ProductScraper).to receive(:fetch).and_raise(ProductScraper::Error, 'Some Error')
    expect {
      add_product_via_search_and_perform :invalid
    }.to raise_error(ProductScraper::Error)
    expect(page).to have_selector('header .progress-bar-danger', text: "Failed")
    expect(page).to have_selector('.product-adder-errors', text: /sorry.*some\serror/i)
  end

  scenario 'user adds a product that takes a long time to process' do
    allow(Sidekiq::Status).to receive(:status).and_return(nil)
    add_product_via_search_and_perform :kindle
    expect(page).to have_selector('header .progress-bar-default')
    expect(page).to have_selector('.product-adder-errors', text: /sorry.*took\sa\slong\stime/i)
  end

  scenario 'user adds a product that has already been imported'
end
