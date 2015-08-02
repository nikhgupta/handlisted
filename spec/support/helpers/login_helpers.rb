module LoginHelpers
  def sign_in_with(email, password)
    visit new_user_session_path
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_on_button 'Log in'            # driver agnostic
  end

  def sign_in_as(factory, attributes = {})
    pass = attributes["password"] || "password"
    attributes["password_confirmation"] = pass

    user = create(factory, attributes)
    sign_in_with user.email, pass
    user
  end

  def sign_up_with(name, email, password)
    visit new_user_registration_path
    fill_in "Name", with: name
    fill_in "Email", with: email
    fill_in "Password (8 characters minimum)", with: password, exact: true
    fill_in "Password confirmation", with: password
    click_on_button 'Sign up'     # driver agnostic
  end

  def sign_out_if_logged_in
    click_on_button("Logout") if page.has_button?("Logout")
    visit destroy_user_session_path
  end

  def sign_in_with_provider(provider)
    visit new_user_session_path
    provider = provider.to_s.camelize.parameterize
    click_on_selector "a.btn-social.#{provider}", match: :first
  end

  def add_provider_via_profile(provider)
    click_on_selector ".add_identities .icon-#{provider}", match: :first
  end

  # TODO: preferably, restore login and url path
  def another_user_has_authenticated_via_provider_identity(provider)
    sign_out_if_logged_in
    visit new_user_session_path
    sign_in_with_provider provider
    sign_out_if_logged_in
  end

  def current_user_has_already_authenticated_via_provider_identity(provider)
    visit edit_profile_path
    add_provider_via_profile provider
  end

  module Macros
    def when_already_signed_with_provider(provider)
      context "when user has already signed in with provider #{provider} in past" do
        background do
          sign_in_with_provider(provider)
          @user = User.find_by(email: "testuser@#{provider}.com")
          expect(@user).to be_persisted.and be_confirmed
          sign_out_if_logged_in
        end

        yield
      end
    end
  end
end
