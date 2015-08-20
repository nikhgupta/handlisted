module LoginHelpers
  def sign_in_with(email_or_username, password = "password")
    visit new_user_session_path
    fill_in "Login", with: email_or_username
    fill_in "Password", with: password
    click_on_button 'Log in'            # driver agnostic
  end

  def sign_in_as(factory, attributes = {})
    pass = attributes["password"] || "password"
    # NOTE: we check for values to be present on attributes hash, as this will
    # filter out virtual_attributes.
    user = User.find_by(attributes) if attributes.values.compact.any?
    if user && [:user, :confirmed_user].include?(factory)
      user.confirm
    elsif user.present?
      puts "\e[33mFound existing user.. Your `factory` setting might not be consistent.\e[0m"
    else
      attributes["password_confirmation"] = pass
      user = create(factory, attributes)
    end

    sign_in_with user.email, pass
    @signed_in_user = user
  end

  def sign_up_with(username, name, email, password = "password")
    visit new_user_registration_path
    fill_in "Name", with: name
    fill_in "Username", with: username
    fill_in "Email", with: email
    fill_in "Password (8 characters minimum)", with: password, exact: true
    fill_in "Password confirmation", with: password
    click_on_button 'Sign up'     # driver agnostic
  end

  def sign_out_if_logged_in
    # click_on_button("Logout") if page.has_button?("Logout")
    visit destroy_user_session_path
  end

  def with_logged_in(*args)
    sign_in_with(*args)
    yield if block_given?
    sign_out_if_logged_in
  end

  def sign_in_with_provider(provider)
    visit new_user_session_path
    provider = provider.to_s.camelize.parameterize
    click_on_selector "a.btn-social.#{provider}", match: :first
  end

  def add_provider_via_profile(provider)
    selector = "a.btn-social.#{provider.to_s.camelize.parameterize}"
    click_on_selector selector, match: :first
  end

  # TODO: preferably, restore login and url path
  def another_user_has_authenticated_via_provider_identity(provider)
    sign_out_if_logged_in
    visit new_user_session_path
    send "sign_in_with_#{provider}"
    sign_out_if_logged_in
  end

  def current_user_has_already_authenticated_via_provider_identity(provider)
    visit edit_profile_path
    add_provider_via_profile provider
  end

  def sign_in_with_facebook
    sign_in_with_provider :facebook
    fill_in "Username", with: "john"
    fill_in "Password (8 characters minimum)", with: "password"
    fill_in "Password confirmation", with: "password"
    click_on_button "Sign up"
    expect(page).to have_alert("signed up successfully").as_notice
  end

  def sign_in_with_google_plus
    sign_in_with_provider :google_plus
    expect(page).to have_alert("authenticated from Google Plus").as_notice
  end

  def sign_in_with_twitter
    sign_in_with_provider :twitter
    fill_in "Email", with: "john@example.com"
    fill_in "Password (8 characters minimum)", with: "password"
    fill_in "Password confirmation", with: "password"
    click_on_button "Sign up"

    click_first_link_in_email

    sign_in_with_provider :twitter
    expect(page).to have_alert("signed up successfully").as_notice
  end
end
