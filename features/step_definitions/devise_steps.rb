Given /^I sign ?up with email "(.*?)" and password "(.*?)"$/ do |email, password|
  visit new_user_registration_path
  fill_in 'user_email', with: email
  fill_in 'user_password', with: password
  fill_in 'user_password_confirmation', with: password
  fill_in 'user_name', with: "Test User" if find_field('Name').value.blank?
  click_button "Sign up"
  step "I should be on the home page"
end

Then /^user with email "(.*?)" should( not)? (exist|be confirmed)$/ do |email, negate, status|
  user = User.find_by(email: email)
  case
  when status == "be confirmed" && !negate
    expect(user).to be_persisted.and be_confirmed
  when status == "exist" && !negate
    expect(user).to be_persisted
  when status == "be confirmed"
    expect(user).to be_persisted
    expect(user).not_to be_confirmed
  else
    expect(user).to be_nil
  end
end

Given /^I am not authenticated$/ do
  link = first(:link, 'Logout') if has_link?('Logout')
  link.click if link
end

When /^I logout$/ do
  steps %Q{
    Given I am not authenticated
    Then  I should be on the home page
    And   I should see "Signed out successfully"
  }
end

Given /^I am a new, authenticated, and confirmed user$/ do
  step "I am logged in user with email \"notexistant@email.com\""
end

Given /^user with email address "(.*?)" exists$/ do |email|
  create(:confirmed_user, email: email)
end

Given /^I (?:am logged in user|log ?in) with email "(.*?)"$/ do |email|
  user = User.find_by(email: email) || create(:confirmed_user, email: email)
  visit new_user_session_path
  fill_in 'user_email', with: user.email
  fill_in 'user_password', with: user.password
  click_button 'Log in'
  @current_user = user
end

Given /^I am(?:| a)( not)? logged in(?:| user)$/ do |negate|
  if negate
    step "I am not authenticated"
  else
    step "I am a new, authenticated, and confirmed user"
  end
end

When /^I follow the confirmation link in the confirmation email$/ do
  steps %Q{
    When I open the email
    Then I should see "confirm" in the email body
    When I follow "Confirm my account" in the email
  }
end
