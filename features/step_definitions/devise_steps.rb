# log out any user that is signed in
Given(/^I am not(?:| an?) (?:authenticated|signed in|logged in)(?:| user)$/) do
  step "I log out"
end

# log in as a user with given attributes (assuming password is default 'password')
Given(/^I am logged in as #{capture_model} with #{capture_fields}$/) do |user, fields|
  steps %Q{
    Given confirmed #{user} exists with #{fields}
    When  I sign in as #{user} with #{fields} and password: "password"
    Then  I should see notice with message: "Signed in successfully"
  }
end

# sign out current session
When(/^I log ?out$/) do
  visit destroy_user_session_path
  step "I should be logged out"
end

# sign in as a user and given password
When(/^I sign ?in as(?:| this) #{capture_model}(?: with #{capture_fields})? and password: "(.*?)"$/) do |user, fields, password|
  user = find_model!(user, fields)
  step "I sign in with email \"#{user.email}\" and password \"#{password}\""
end

# sign in with given email and password
When(/^I sign ?in with email "(.*?)" and password "(.*?)"$/) do |email, password|
  step 'I go to the login page'
  fill_in 'user_email', with: email
  fill_in 'user_password', with: password
  click_button 'Log in'
  @current_user = User.find_by(email: email)
end

# register with given email and password
When(/^I sign ?up with email: "(.*?)"(?: and password: "(.*?)")?$/) do |email, password|
  visit new_user_registration_path
  fill_in 'user_email', with: email
  fill_in 'user_password', with: (password || "password")
  fill_in 'user_password_confirmation', with: (password || "password")
  fill_in 'user_name', with: "Test User" if find_field('Name').value.blank?
  click_button "Sign up"
  step "I should be on the home page"
  step "I should see notice with message: \"activate your account\""
end

# assert that user has been logged out
Then(/should be logged in$/) do
  step "I should be on the home page"
  step "I should see link with text \"Logout\""
  step "I should see notice with message: \"Signed in successfully\""
end

# assert that user has been logged out
Then(/should be logged out$/) do
  steps %Q{
    Then I should be on the home page
     And I should see "Signed out successfully"
  }
end
