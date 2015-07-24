# Sign in with provider or adding provider
When /^I click to add provider "(.*?)" in my profile$/ do |provider|
  step 'I go to the edit profile page'
  add_identity_for(provider).click
end
When /^I sign in with provider "(.*?)"$/ do |provider|
  step 'I go to the login page'
  provider_icon_for(provider).click
end
Given /( not)? signed in with provider "(.*?)" before$/ do |negate, provider|
  non_email_sharing_providers = %w[twitter]
  if !negate && @current_user.present?
    step "I click to add provider \"#{provider}\" in my profile"
  elsif !negate && non_email_sharing_providers.include?(provider)
    step "I am logged in user with email \"testuser@#{provider}.com\""
    step "I click to add provider \"#{provider}\" in my profile"
    step "I logout"
  elsif !negate
    step "I sign in with provider \"#{provider}\""
    step "I logout"
  else
    auth = OmniAuth.config.mock_auth[provider.to_sym]
    identity = Identity.find_with_omniauth(auth)
    identity.delete if identity.present?
  end
end

# Special
Given /^I do not want to expose my "(.*?)" via "(.*?)" provider$/ do |item, provider|
  auth = OmniAuth.config.mock_auth[provider.to_sym]
  auth["info"].delete(item)
  OmniAuth.config.mock_auth[provider.to_sym] = auth
end
