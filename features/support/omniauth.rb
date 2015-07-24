Before do
  OmniAuth.config.test_mode = true
  load Rails.root.join('spec', 'support', 'omni_auth.rb')
end

After do
  OmniAuth.config.test_mode = false
end
