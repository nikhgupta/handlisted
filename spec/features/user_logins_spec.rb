require 'rails_helper'

feature "user login" do
  context "with correct credentials" do
    background do
      @user = create(:confirmed_user, password: "password")
    end
    scenario "allows logging in with email" do
      sign_in_with @user.email, "password"
      expect(current_path).to eq(root_path)
      expect(page).to have_alert("Signed in successfully").as_notice
    end
    scenario "allows logging in with username" do
      sign_in_with @user.username, "password"
      expect(current_path).to eq(root_path)
      expect(page).to have_alert("Signed in successfully").as_notice
    end
  end

  scenario "with invalid password" do
    user = create(:confirmed_user, password: "password")
    sign_in_with user.email, "wrongpassword"
    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_alert("Invalid login or password").as_error
  end

  scenario "with invalid email" do
    sign_in_with "random@example.com", "password"
    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_alert("Invalid login or password").as_error
    expect(page).to have_link("You can reset your password here.")
  end
end

feature "On user registration page" do
  background do
    visit user_registration_path
  end

  scenario "shows user URL to their profile that will be created", :js do
    expect(page).to have_selector('label', text: "http://localhost:3000/...")

    fill_in "Username", with: "te    s  "
    expect(page).to have_selector('label', text: "http://localhost:3000/...")

    fill_in "Username", with: "testuser"
    expect(page).to have_selector('label', text: "http://localhost:3000/testuser")

    fill_in "Username", with: "      test user   2       "
    expect(page).to have_selector('label', text: "http://localhost:3000/testuser2")

    # simulating empty fill requires us to send `keyup` event
    fill_in 'Username', with: ''
    page.find('#user_username').native.send_keys(:keyup)
    expect(page).to have_selector('label', text: "http://localhost:3000/...")
  end

  context "notifies user of validation errors" do
    scenario "from server side" do
      sign_up_with "", "John Smith", "john@smith.com", "password"
      expect(page).to have_alert("Username can't be blank").as_error
    end

    scenario "from client side", :js do
      fill_in "Username", with: "te s  "
      expect(page).to have_selector('label.state-error #user_username')
      expect(page).to have_selector('em.state-error', text: "valid value with alphabets and numbers only")
    end
  end
end

feature "When user registers" do
  background do
    sign_up_with "john", "John Smith", "john@smith.com", "password"
    @user = User.find_by(email: "john@smith.com")
  end

  scenario "sends a confirmation email in the background" do
    expect(current_path).to eq(root_path)
    expect(page).to have_alert("activate your account").as_notice

    expect(@user).to be_persisted
    expect(@user).not_to be_confirmed
    expect(deliveries).to be_empty

    Sidekiq::Extensions::DelayedMailer.drain
    expect(open_last_email).to be_delivered_to(@user.email)
    expect(read_emails_for(@user.email).size).to eq(1)
    expect(open_last_email.subject).to eq("Confirmation instructions")
  end

  scenario "requires confirming email before allowing logging in" do
    sign_in_with @user.email, "password"
    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_alert("confirm your email address before").as_error
    expect(page).to have_link("Didn't receive confirmation email?")
  end

  scenario "notifies user when email is confirmed" do
    Sidekiq::Extensions::DelayedMailer.drain
    open_last_email
    click_first_link_in_email
    expect(page).to have_alert("successfully confirmed").as_notice
  end

  scenario "logs in user after user has confirmed his email" do
    @user.confirm

    sign_in_with @user.email, "password"
    expect(current_path).to eq(root_path)
    expect(page).to have_alert("Signed in successfully").as_notice

    visit edit_profile_path
    expect(page).to have_content("@john")
    expect(page).to have_field("Name", with: "John Smith")
  end
end
