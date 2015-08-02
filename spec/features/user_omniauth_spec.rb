require 'rails_helper'

feature "user registers with omniauth provider", :omniauth do
  background do
    sign_out_if_logged_in
  end

  scenario "using facebook" do
    sign_in_with_provider :facebook
    expect(current_path).to eq root_path
    expect(page).to have_notice_with_text("authenticated from Facebook")

    user = User.find_by(email: "testuser@facebook.com")
    expect(user).to be_persisted.and be_confirmed

    visit edit_profile_path
    expect(page).to have_field("Name", with: "Test Facebook User")
    expect(page).to have_field("Image", with: "http://url.to/profile-image.jpg")
    expect(page).to have_selector('a[href="https://facebook.com/testuser"]')
  end

  scenario "using google+" do
    sign_in_with_provider :google_plus
    expect(current_path).to eq root_path
    expect(page).to have_notice_with_text("authenticated from Google Plus")

    user = User.find_by(email: "testuser@google_plus.com")
    expect(user).to be_persisted.and be_confirmed

    visit edit_profile_path
    expect(page).to have_field("Name", with: "Test Google User")
    expect(page).to have_field("Image", with: "http://url.to/profile-image.jpg")
    expect(page).to have_selector('a[href="http://plus.google.com/some-profile-id"]')
  end

  scenario "using twitter" do
    sign_in_with_provider :twitter
    expect(current_path).to eq new_user_registration_path
    expect(page).to have_field "Name", with: "Test Twitter User"

    email = "john@smith.com"
    fill_in "Email", with: email
    fill_in "Password (8 characters minimum)", with: "password"
    fill_in "Password confirmation", with: "password"
    click_on_button "Sign up"

    user = User.find_by(email: email)
    expect(user).to be_persisted
    expect(user).not_to be_confirmed
    expect(open_last_email).to be_delivered_to(user.email)

    user.confirm
    sign_in_with_provider :twitter
    expect(current_path).to eq root_path
    expect(page).to have_notice_with_text "Signed in via Twitter!"

    visit edit_profile_path
    expect(page).to have_field "Name", with: "Test Twitter User"
    expect(page).to have_field "Image", with: "http://url.to/profile-image.jpg"
    expect(page).to have_selector('a[href="https://twitter.com/testusername"]')
  end

  scenario "without specifying email" do
    auth = OmniAuth.config.mock_auth[:facebook]
    auth["info"].delete(:email)
    OmniAuth.config.mock_auth[:facebook] = auth

    sign_in_with_provider :facebook
    expect(current_path).to eq new_user_registration_path
    expect(page).to have_field "Name", with: "Test Facebook User"

    email = "john@smith.com"
    fill_in "Email", with: email
    fill_in "Password (8 characters minimum)", with: "password"
    fill_in "Password confirmation", with: "password"
    click_on_button "Sign up"

    user = User.find_by(email: email)
    expect(user).to be_persisted
    expect(user).not_to be_confirmed
    expect(open_last_email).to be_delivered_to(user.email)

    user.confirm
    sign_in_with_provider :facebook
    expect(current_path).to eq root_path
    expect(page).to have_notice_with_text "Signed in via Facebook!"

    visit edit_profile_path
    expect(page).to have_field "Name", with: "Test Facebook User"
  end
end

feature "user logins using omniauth provider", :omniauth do
  when_already_signed_with_provider :facebook do
    scenario "with facebook" do
      sign_in_with_provider :facebook
      expect(current_path).to eq root_path
      expect(page).to have_notice_with_text "Signed in via Facebook!"
    end
  end

  when_already_signed_with_provider :google_plus do
    scenario "with google+" do
      sign_in_with_provider :google_plus
      expect(current_path).to eq root_path
      expect(page).to have_notice_with_text "Signed in via Google Plus!"
    end
  end

  scenario "confirms email address" do
    user = create(:user, email: "testuser@facebook.com")
    expect(user).not_to be_confirmed

    sign_out_if_logged_in
    sign_in_with_provider :facebook
    expect(page).to have_notice_with_text "Confirmed email: testuser@facebook.com!"
    expect(user.reload).to be_confirmed
  end

  context "when logged in" do
    background do
      @user = sign_in_as :confirmed_user, email: "user@example.com"
      current_user_has_already_authenticated_via_provider_identity :twitter
      visit edit_profile_path
    end

    scenario "adding new identity" do
      add_provider_via_profile :google_plus
      expect(current_path).to eq edit_profile_path
      expect(page).to have_notice_with_text "Successfully linked"
    end

    scenario "adding identity already attached with this user" do
      add_provider_via_profile :twitter
      expect(current_path).to eq edit_profile_path
      expect(page).to have_notice_with_text "already linked"
    end

    scenario "adding identity associated with another user" do
      another_user_has_authenticated_via_provider_identity  :facebook

      sign_in_with @user.email, "password"
      visit edit_profile_path
      add_provider_via_profile :facebook
      expect(current_path).to eq edit_profile_path
      expect(page).to have_alert_with_text "already associated with another"
    end

    scenario "adding identity whose email is associated with another user" do
      create(:user, email: "testuser@google_plus.com")

      add_provider_via_profile :google_plus
      expect(current_path).to eq edit_profile_path
      expect(page).to have_notice_with_text "Successfully linked"
      expect(page).not_to have_alert_with_text "already associated"
    end

    scenario "adding identity with user's current email" do
      sign_out_if_logged_in
      sign_in_as :confirmed_user, email: "testuser@google_plus.com"

      visit edit_profile_path
      add_provider_via_profile :google_plus
      expect(page).to have_notice_with_text "Successfully linked"
      expect(page).not_to have_alert_with_text "already linked"
    end
  end
end
