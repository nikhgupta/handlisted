RSpec.feature "Site Search", :js, :slow, type: :feature do
  context "default behaviour" do
    scenario "search behaviour matches for frontpage and app page" do
      visit root_path
      click_on "anywhere to search"
      within(".overlay"){ expect(page).to have_text "Instant search" }

      visit products_path
      click_on "anywhere to search"
      within(".overlay"){ expect(page).to have_text "Instant search" }
    end
    scenario "does not require logging in" do
      sign_out_if_logged_in
      visit root_path
      search_using_sitewide_search :bags
      expect(current_path).to eq root_path
      expect(page).to have_field :search, with: :bags
    end
    scenario "search messages should disappear when search field is empty" do
      visit root_path
      search_using_sitewide_search :bags
      expect(page).to have_text("No products were found")
      search_using_sitewide_search nil
      expect_search_to_show_message "Instant search"
    end
    scenario "search should notify when no matching products are found" do
      visit root_path
      search_using_sitewide_search :bags
      expect(page).to have_text "No products were found for your query!"
      expect(page).not_to have_text "FOUND PRODUCTS"
      expect(page).not_to have_css ".product.card"
    end
  end
  context "with existing products" do
    background do
      @user   = sign_in_as :confirmed_user
      @moto   = add_product @user, :moto_x
      @kindle = add_product @user, :kindle
    end
    scenario "should notify when no matching products are found" do
      visit root_path
      search_using_sitewide_search :bags
      expect(current_path).to eq(root_path)
      expect_search_to_show_message "No products were found"
      expect(page).not_to have_text "FOUND PRODUCTS"
      expect_search_not_to have_product_card_for(@moto)
      expect_search_not_to have_product_card_for(@kindle)
    end
    scenario "search should list only matching products" do
      search_using_sitewide_search('kindle')
      expect(current_path).to eq(root_path)
      expect(page).to have_text "FOUND PRODUCTS"
      expect_search_to have_product_card_for(@kindle)
      expect_search_not_to have_product_card_for(@moto)
      expect(page).not_to have_text("No products were found")

      search_using_sitewide_search('moto')
      expect(page).to have_text "FOUND PRODUCTS"
      expect_search_not_to have_product_card_for(@kindle)
      expect_search_to have_product_card_for(@moto)
      expect(page).not_to have_text("No products were found")
    end
    scenario "search is reset when the overlay is closed" do
      search_using_sitewide_search('kindle')
      within(".overlay"){ expect(page).to have_selector ".product.card", count: 1 }

      find(".overlay-close").trigger 'click'
      click_on_link "anywhere to search"
      expect_search_to_show_message "Instant search"
      within(".overlay"){
        expect(page).not_to have_field :search, with: "kindle"
        expect(page).not_to have_selector ".product.card"
      }
    end
  end
  context "when adding products" do
    background do
      @user    = sign_in_as :confirmed_user
      @import  = "http://www.amazon.in/Physique-Grip-Trainer/dp/B00L4VS12S/ref=pd_sbs_200_5"
      @import2 = "http://www.amazon.in/Kingston-Micro-SDHC-class-memory/dp/B007W0NFCG/ref=sr_1_16"
      Product.where(pid: "B00L4VS12S").destroy_all
      Product.where(pid: "B007W0NFCG").destroy_all
    end
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
    # FIXME: we cannot test sidekiq jobs in progress at the moment.
    # A testing server middleware can be introduced to test such cases.
    # Skipping for now.
    scenario "users adds a product url in query" do
      visit root_path
      add_product_via_search_and_perform(@import)
      expect(page).to have_selector('.overlay .progress-bar-success')
      wait_for_traffic
      product = Product.find_by(pid: "B00L4VS12S")
      expect(product).to be_persisted
      expect(current_path).to eq root_path
      expect_search_to_show_message "Import was Successful"
      expect_search_to have_product_card_for(product)
    end
    scenario "user searches for a product after just adding a product" do
      create :product, founder: @user
      visit root_path
      add_product_via_search_and_perform(@import)
      product = Product.find_by(pid: "B00L4VS12S")
      expect_search_to_show_message "Import was Successful"
      expect_search_to have_product_card_for(product)

      search_using_sitewide_search('product')
      expect_search_not_to have_text "Import was successful"
      expect_search_not_to have_text "No products were found"
      expect_search_to have_selector ".product.card", count: 1
    end
    scenario "user adds a product after just adding another one" do
      visit root_path

      add_product_via_search_and_perform(@import, instant: true)
      product = Product.find_by(pid: "B00L4VS12S")
      expect(product).not_to be_nil

      fill_sitewide_search_with(@import2)
      expect(page).not_to have_text "Import was Successful"
      expect_search_not_to have_product_card_for(product)

      click_on_link "Import Product"
      expect(ProductScraperJob.jobs.size).to eq 1
      ProductScraperJob.drain

      product = Product.find_by(pid: "B007W0NFCG")
      expect(product).not_to be_nil
      expect(page).to have_text "Imported: #{product.name}"
      expect(page).not_to have_text "FOUND PRODUCTS"
      expect_search_to_show_message "Import was Successful"
      expect_search_to have_product_card_for(product)
    end
    scenario "detects a product url in a query that has already been imported"
    scenario "user adds product URL that does not exist" do
      add_product_via_sitewide_search :invalid
      expect(page).to have_text "No products were found for your query!"
    end
    scenario "user adds a product which induces an error" do
      allow(ProductScraper).to receive(:fetch).and_raise(ProductScraper::Error, 'Some Error')
      expect {
        add_product_via_search_and_perform @import
      }.to raise_error(ProductScraper::Error)
      expect(page).to have_text "Import Failed. Error: Some Error"
    end
    scenario 'user adds a product which takes a long time to import' do
      # `nil` status specifies job expiration in Sidekiq
      allow(Sidekiq::Status).to receive(:status).and_return("Queued", nil)
      add_product_via_search_and_perform :kindle
      expect(page).to have_text "Import failed due to unknown reasons!"
    end
    scenario 'sidekiq does not complete the import, while progress bar reaches 100%', :very_slow do
      # FIXME: not sure how to stub progress go above 100 using tests
      Capybara.default_max_wait_time = 60
      allow(Sidekiq::Status).to receive(:status).and_return("Queued")
      add_product_via_search_and_perform :kindle
      expect(page).to have_text "Import took a long time!"
      Capybara.default_max_wait_time = ENV['CAPYBARA_TIMEOUT'] ? ENV['CAPYBARA_TIMEOUT'].to_i : 5
    end
    scenario 'user adds a product that has already been imported'
  end

  context "with several products" do
    background do
      @user = sign_in_as :confirmed_user
      create_list :product, 12, founder: @user
    end
    scenario "instant search only displays upto 8 products" do
      search_using_sitewide_search('product')
      within(".overlay"){ expect(page).to have_selector ".product.card", count: 8 }
    end
    scenario "all search results can be seen by clicking view all results" do
      search_using_sitewide_search('product')
      within(".overlay"){ expect(page).to have_selector ".product.card", count: 8 }
      click_on_link "View All"
      expect(current_path).to eq search_or_add_products_path
      expect(page).to have_selector ".product.card", count: 12
    end
    scenario "all search results can be seen by pressing Enter when searching" do
      add_product @user, :moto_x
      search_using_sitewide_search('moto', instant: false)
      expect(page).to have_selector ".product.card", count: 1
      expect(current_path).to eq search_or_add_products_path

      search_using_sitewide_search('product', instant: false)
      expect(page).to have_selector ".product.card", count: 12
      expect(current_path).to eq search_or_add_products_path
    end
    scenario "search should behave similar to product listing"
    scenario "search should prioritize products for revenue and interest"
  end
end
