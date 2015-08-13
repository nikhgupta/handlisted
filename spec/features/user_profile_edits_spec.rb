require 'rails_helper'

feature "user edit his profile" do
  context "when not signed in" do
    background do
      sign_out_if_logged_in
    end

    scenario "is redirected to login page" do
      visit edit_profile_path
      expect(current_path).to eq new_user_session_path
      expect(page).to have_alert_with_text "need to sign in"
    end
  end

  context "when signed in" do
    background do
      @user = create(:confirmed_user, name: "John Smith")
      sign_in_with @user.email, "password"
      visit edit_profile_path
      expect(page).to have_field("Name", with: "John Smith")
    end

    scenario "without supplying password" do
      fill_in "Name", with: "Another Smith"
      click_on_button "Update info"
      expect(page).to have_notice_with_text("successfully updated")
      expect(page).to have_field("Name", with: "Another Smith")
    end

    scenario "along with password" do
      fill_in "Name", with: "Another Smith"
      fill_in "Password", with: "newpassword", exact: true
      fill_in "Password confirmation", with: "newpassword"
      click_on_button "Update info"
      expect(page).to have_notice_with_text("successfully updated")
      expect(current_path).to eq(root_path)

      sign_in_with @user.email, "newpassword"
      expect(page).to have_notice_with_text("Signed in successfully")

      visit edit_profile_path
      expect(page).to have_field("Name", with: "Another Smith")
      expect(page).to have_empty_field("Password")
      expect(page).to have_empty_field("Password confirmation")
    end

    scenario "with wrong password confirmation" do
      fill_in "Name", with: "Another Smith"
      fill_in "Password", with: "newpassword", exact: true
      fill_in "Password confirmation", with: "newwrongpassword"
      click_on_button "Update info"
      expect(page).to have_alert_with_text("Password confirmation doesn't match")
      expect(current_path).to eq edit_profile_path
    end
  end
end
