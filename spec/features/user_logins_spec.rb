require 'rails_helper'

feature "user login" do
  context "with correct credentials" do
    background do
      @user = create(:confirmed_user, password: "password")
    end
    scenario "allows logging in with email" do
      sign_in_with @user.email, "password"
      expect(current_path).to eq(root_path)
      expect(page).to have_notice_with_text("Signed in successfully")
    end
    scenario "allows logging in with username" do
      sign_in_with @user.username, "password"
      expect(current_path).to eq(root_path)
      expect(page).to have_notice_with_text("Signed in successfully")
    end
  end

  scenario "with invalid password" do
    user = create(:confirmed_user, password: "password")
    sign_in_with user.email, "wrongpassword"
    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_alert_with_text("Invalid login or password")
  end

  scenario "with invalid email" do
    sign_in_with "random@example.com", "password"
    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_alert_with_text("Invalid login or password")
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
      expect(page).to have_warning_with_text("Username can't be blank")
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

  scenario "sends a confirmation email" do
    expect(current_path).to eq(root_path)
    expect(page).to have_notice_with_text "activate your account"

    expect(@user).to be_persisted
    expect(@user).not_to be_confirmed
    expect(open_last_email).to be_delivered_to(@user.email)
    expect(read_emails_for(@user.email).size).to eq(1)
    expect(open_last_email.subject).to eq("Confirmation instructions")
  end

  scenario "requires confirming email before allowing logging in" do
    sign_in_with @user.email, "password"
    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_alert_with_text("confirm your email address before")
    expect(page).to have_link("Didn't receive confirmation email?")
  end

  scenario "notifies user when email is confirmed" do
    open_last_email
    click_first_link_in_email
    expect(page).to have_notice_with_text("successfully confirmed")
  end

  scenario "logs in user after user has confirmed his email" do
    @user.confirm

    sign_in_with @user.email, "password"
    expect(current_path).to eq(root_path)
    expect(page).to have_notice_with_text("Signed in successfully")

    visit edit_profile_path
    expect(page).to have_content("@john")
    expect(page).to have_field("Name", with: "John Smith")
  end
end
