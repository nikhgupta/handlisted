Given(/^(?:|I )(?:am on|go to) (.+)$/) do |page_name|
  visit path_to(page_name)
end
When(/^I fill in "(.*?)" with "(.*?)"$/) do |field, value|
  fill_in field, with: value, exact: true
end
Then(/^(?:|I )should see "(.*?)"$/) do |text|
  expect(page).to have_content(text)
end
Then(/^(?:|I )should not see "(.*?)"$/) do |text|
  expect(page).not_to have_content(text)
end
When(/^(?:|I )click on "(.*?)" button$/) do |link|
  click_button(link)
end
When(/^(?:|I )click on "(.*?)" link$/) do |link|
  click_link(link)
end
Then(/should see(?:| an?) (\w+) with message: "(.*?)"$/) do |kind, message|
  kind = kind == 'notice' ? '.alert-success,.alert-info' : '.alert-warning,.alert-danger'
  expect(page).to have_selector(kind, text: message)
end




# Navigation
Then /^(?:|I )should( not)? be on (.+)$/ do |negate, page_name|
  if !negate
    expect(page.current_path).to eq(path_to(page_name))
  else
    expect(page.current_path).not_to eq(path_to(page_name))
  end
end

# Page content
Then /^(?:|I )should( not)? see link to "(.*?)"$/ do |negate, link|
  find_link = find(:xpath, "//a[@href='#{link}']")
  if negate
    expect{ find_link }.to raise_error(Capybara::ElementNotFound)
  else
    expect( find_link ).to be_present
  end
end
Then /^(?:|I )should( not)? see link with text "(.*?)"$/ do |negate, link|
  if !negate
    expect(page).to have_link(link)
  else
    expect(page).not_to have_link(link)
  end
end

# Forms
Then /^I should( not)? see field "(.*?)" prefilled with "(.*?)"$/ do |negate, field, value|
  expect(page).to have_field(field)
  if negate
    expect(page.find_field(field).value).not_to eq(value)
  else
    expect(page.find_field(field).value).to eq(value)
  end
end

Then(/save and open page/){ save_and_open_page }
Then(/save and open screenshot/){ save_and_open_screenshot }
