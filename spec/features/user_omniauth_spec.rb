require 'rails_helper'

feature "user registers with omniauth provider", :omniauth do
  background do
    sign_out_if_logged_in
  end

  scenario "using facebook" do
    email  = "testuser@facebook.com"

    sign_in_with_provider :facebook
    expect(current_path).to eq new_user_registration_path
    expect(page).to have_field "Name", with: "Test Facebook User"
    expect(page).to have_field "Email", with: email
    expect(page).to have_alert("complete your sign up").as_notice

    fill_in "Username", with: "john"
    fill_in "Password (8 characters minimum)", with: "password"
    fill_in "Password confirmation", with: "password"
    click_on_button "Sign up"

    user   = User.find_by(email: email)
    emails = unread_emails_for(email)

    expect(emails.size).to be 0
    expect(user).to be_persisted.and be_confirmed
    expect(current_path).to eq root_path
    expect(page).to have_alert("signed up successfully").as_notice

    visit edit_profile_path
    expect(page).to have_field("Name", with: "Test Facebook User")

    sign_out_if_logged_in
    sign_in_with_provider :facebook
    expect(page).to have_alert("Signed in via Facebook").as_notice
  end

  scenario "sign up using provider but changed email address" do
    email = "testuser@facebook.com"
    newemail = "john@example.com"

    sign_in_with_provider :facebook
    expect(current_path).to eq new_user_registration_path
    expect(page).to have_field "Email", with: email

    fill_in "Username", with: "john"
    fill_in "Email", with: newemail
    fill_in "Password (8 characters minimum)", with: "password"
    fill_in "Password confirmation", with: "password"
    click_on_button "Sign up"

    user = User.find_by(email: newemail)

    expect(user).to be_persisted
    expect(user).not_to be_confirmed
    expect(open_last_email).to be_delivered_to(user.email)
  end

  scenario "using google+" do
    sign_in_with_provider :google_plus

    email  = "testuser@gmail.com"
    user   = User.find_by(email: email)
    emails = unread_emails_for(email)

    expect(emails.size).to be 0
    expect(user).to be_persisted.and be_confirmed
    expect(current_path).to eq root_path
    expect(page).to have_alert("authenticated from Google Plus").as_notice

    visit edit_profile_path
    expect(page).to have_content("@testuser - Test Google User")
    expect(page).to have_field("Name", with: "Test Google User")
    expect(page).to have_field("Email", with: "testuser@gmail.com")

    sign_out_if_logged_in
    sign_in_with_provider :google_plus
    expect(page).to have_alert("Signed in via Google Plus").as_notice
  end

  scenario "using twitter" do
    sign_in_with_provider :twitter
    expect(current_path).to eq new_user_registration_path
    expect(page).to have_field "Name", with: "Test Twitter User"
    expect(page).to have_field "Username", with: "testusername"

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
    expect(page).to have_alert("Signed in via Twitter!").as_notice

    visit edit_profile_path
    expect(page).to have_field "Name", with: "Test Twitter User"

    sign_out_if_logged_in
    sign_in_with_provider :twitter
    expect(page).to have_alert("Signed in via Twitter").as_notice
  end

  scenario "without specifying email" do
    auth = OmniAuth.config.mock_auth[:facebook]
    auth["info"].delete(:email)
    OmniAuth.config.mock_auth[:facebook] = auth

    sign_in_with_provider :facebook
    expect(current_path).to eq new_user_registration_path
    expect(page).to have_field "Name", with: "Test Facebook User"

    fill_in "Username", with: "john"
    fill_in "Email", with: "john@smith.com"
    fill_in "Password (8 characters minimum)", with: "password"
    fill_in "Password confirmation", with: "password"
    click_on_button "Sign up"

    user = User.find_by(email: "john@smith.com")
    expect(user).to be_persisted
    expect(user).not_to be_confirmed
    expect(open_last_email).to be_delivered_to(user.email)

    user.confirm
    sign_in_with_provider :facebook
    expect(current_path).to eq root_path
    expect(page).to have_alert("Signed in via Facebook!").as_notice

    visit edit_profile_path
    expect(page).to have_field "Name", with: "Test Facebook User"
  end
end

feature "user logins using omniauth provider", :omniauth do
  scenario "confirms email address" do
    user = create(:user, email: "testuser@facebook.com")
    expect(user).not_to be_confirmed

    sign_out_if_logged_in
    sign_in_with_provider :facebook
    expect(page).to have_alert("Confirmed email: testuser@facebook.com!").as_notice
    expect(user.reload).to be_confirmed
  end

  context "when logged in" do
    background do
      @user = sign_in_as :confirmed_user, email: "user@example.com"
      visit edit_profile_path
    end

    scenario "adding new identity" do
      add_provider_via_profile :google_plus
      expect(current_path).to eq edit_profile_path
      expect(page).to have_alert("Successfully linked").as_notice
    end

    scenario "adding identity already attached with this user" do
      current_user_has_already_authenticated_via_provider_identity :twitter

      selector = "a.btn-social.twitter"
      expect(page).to have_selector(selector, text: "Authenticated via Twitter")

      element = find(selector)
      expect(element[:href]).to eq "#"
      expect(element[:style]).to include("opacity: 0.")

      visit user_omniauth_authorize_path(:twitter)
      expect(current_path).to eq edit_profile_path
      expect(page).to have_alert("already linked").as_notice
    end

    scenario "adding identity associated with another user" do
      another_user_has_authenticated_via_provider_identity  :facebook

      sign_in_with @user.email, "password"
      visit edit_profile_path
      add_provider_via_profile :facebook
      expect(current_path).to eq edit_profile_path
      expect(page).to have_alert("already associated with another").as_error
    end

    scenario "adding identity whose email is associated with another user" do
      create(:user, email: "testuser@gmail.com")

      add_provider_via_profile :google_plus
      expect(current_path).to eq edit_profile_path
      expect(page).to have_alert("Successfully linked").as_notice
      expect(page).to have_no_alert("already associated")
    end

    scenario "adding identity with user's current email" do
      sign_out_if_logged_in
      sign_in_as :confirmed_user, email: "testuser@gmail.com"

      visit edit_profile_path
      add_provider_via_profile :google_plus
      expect(page).to have_alert("Successfully linked").as_notice
      expect(page).to have_no_alert "already linked"
    end
  end
end
