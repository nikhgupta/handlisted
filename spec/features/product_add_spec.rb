require 'rails_helper'

feature "when not logged in", :slow, :vcr do
  scenario "adding products from search bar requires signing in", js: true do
    sign_out_if_logged_in
    visit root_path
    add_product_via_sitewide_search(:amazon_echo)
    expect(current_path).to eq new_user_session_path
  end
end

# TODO: patch Worker to execute some tests while performing the job
#
feature "add product from search bar", :slow, :vcr, js: true do
  background do
    @user = sign_in_as :confirmed_user
    visit root_path
  end

  scenario "user adds a product", :very_slow do
    add_product_via_search_and_perform(:amazon_echo) do
      expect(page).to have_selector('header .progress-bar.progress-bar-warning')
      status = progress_status
      expect(status).to be >= 30

      # OPTIMIZE: commenting next two lines will shove off 8-10 seconds of test
      # suite run, when combined with a low time interval to check for updated
      # status via Sidekiq here:
      # /app/assets/javascripts/product_adder.js.coffee:26
      sleep 1
      expect(progress_status).to be_within(0.1).of(status + 1)
    end
    expect(page).not_to have_selector('header .progress-bar')
    product = Product.find_by(pid: PRODUCTS_LIST[:amazon_echo][:pid])
    expect(current_path).to eq product_path(product)
  end

  scenario "users adds product URL that does not exist" do
    expect { add_product_via_search_and_perform :invalid }.not_to raise_error
    expect(page).to have_selector('header .progress-bar-danger', text: "Failed")
    expect(page).to have_selector('.product-adder-errors', text: /no product.*?here/i)
  end

  scenario "users adds a product which induces an error" do
    allow(ProductScraper).to receive(:fetch_basic_info).and_raise(ProductScraper::Error, 'Some Error')
    expect {
      add_product_via_search_and_perform :invalid
    }.to raise_error(ProductScraper::Error)
    expect(page).to have_selector('header .progress-bar-danger', text: "Failed")
    expect(page).to have_selector('.product-adder-errors', text: /sorry.*some\serror/i)
  end

  scenario 'users adds a product that takes a long time to process' do
    allow(Sidekiq::Status).to receive(:status).and_return(nil)
    add_product_via_search_and_perform :amazon_echo
    expect(page).to have_selector('header .progress-bar-default')
    expect(page).to have_selector('.product-adder-errors', text: /sorry.*took\sa\slong\stime/i)
  end
end
