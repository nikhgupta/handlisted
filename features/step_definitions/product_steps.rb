When(/^I enter the source url of product: "(.*?)" in sitewide search$/) do |product|
  fill_in 'product_search', with: product_source_for(product)
  click_button "Search", visible: false
  # find("#product_search").send_keys(:return)
end
