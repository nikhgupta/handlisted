# Sign in with the given provider, and log out
Given(/^I have signed in with provider "(.*?)" before$/) do |provider|

  # Non-email sharing providers
  if %w[twitter].include?(provider)
    step "I am logged in as user with email: \"testuser@#{provider}.com\""
  end

  if @current_user
    step "I click to add provider \"#{provider}\" in my profile"
  else
    steps %Q{
      When I sign in with provider "#{provider}"
      Then I should be on the home page
       And I should see link with text "Logout"
       And I should see notice with message: "authenticated from #{provider.titleize}"
    }
  end

  step "I logout"
end

# User does not provide a specific permission
Given(/^I do not want to expose my "(.*?)" via "(.*?)" provider$/) do |item, provider|
  auth = OmniAuth.config.mock_auth[provider.to_sym]
  auth["info"].delete(item)
  OmniAuth.config.mock_auth[provider.to_sym] = auth
end

# Sign in with given provider, and optionally, check success
When(/^I sign in with provider "(.*?)"$/) do |provider|
  step 'I go to the login page'
  provider_icon_for(provider).click
end

# Add given provider for logged in user
When(/^I click to add provider "(.*?)" in my profile$/) do |provider|
  step 'I go to the edit profile page'
  add_identity_for(provider).click
end
