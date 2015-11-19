require 'rails_helper'

RSpec.feature "Services: Newsletter Subscription", :background, :js, type: :feature do
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("MAILCHIMP_DEFAULT_LIST_ID").and_return "abcdef"

    visit root_path
  end

  scenario "users (or guests) are able to subscribe to newsletter" do
    expect(Services::NewsletterSubscriptionJob).to receive(:perform_async)
      .with("someone@example.com", "abcdef")

    within(".subscription-form") do
      fill_in "email", with: "someone@example.com"
      click_on 'Subscribe'

      expect(page).to have_content "Thank you for subscribing with us!"
      expect(page).to have_content /confirm your subscription.*someone@example.com/
    end
  end

  scenario "validation errors are shown for the subscription form" do
    within(".subscription-form") do
      fill_in "email", with: "someone"
      click_on 'Subscribe'
      expect(page).to have_selector "em.state-error", text: "Please enter a valid email address"
    end
  end
end
