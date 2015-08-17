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
    expect(page).to have_alert_with_text("Invalid email or password")
  end

  scenario "with invalid email" do
    sign_in_with "random@example.com", "password"
    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_alert_with_text("Invalid email or password")
  end
end

feature "User registration" do
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
