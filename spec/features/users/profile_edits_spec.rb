require 'rails_helper'

RSpec.feature "User Profiles" do
  context "when not signed in" do
    background do
      sign_out_if_logged_in
    end

    scenario "is redirected to login page" do
      visit edit_profile_path
      expect(current_path).to eq new_user_session_path
      expect(page).to have_alert("need to sign in").as_error
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
      expect(page).to have_alert("successfully updated").as_notice
      expect(page).to have_field("Name", with: "Another Smith")
    end

    scenario "along with password", js: true do
      fill_in "Name", with: "Another Smith"
      fill_in "Password", with: "newpassword", exact: true
      fill_in "Password confirmation", with: "newpassword"
      expect(page).to have_no_selector(".error")

      click_on_button "Update info"
      expect(current_path).to eq(products_path)
      expect(page).to have_alert("successfully updated").as_notice

      sign_in_with @user.email, "newpassword"
      expect(page).to have_alert("Signed in successfully").as_notice

      visit edit_profile_path
      expect(page).to have_field("Name", with: "Another Smith")
      expect(page).to have_empty_field("Password")
      expect(page).to have_empty_field("Password confirmation")
    end

    scenario "invalidates with wrong password confirmation on page refresh with js disabled" do
      fill_in "Name", with: "Another Smith"
      fill_in "Password", with: "newpassword", exact: true
      fill_in "Password confirmation", with: "newwrongpassword"
      click_on_button "Update info"
      expect(page).to have_alert("Password confirmation doesn't match").as_error
      expect(current_path).to eq edit_profile_path
    end

    scenario "invalidates with wrong password confirmation", :js do
      fill_in "Name", with: "Another Smith"
      fill_in "Password", with: "newpassword", exact: true
      fill_in "Password confirmation", with: "newwrongpassword"
      click_on_button "Update info"
      expect(current_path).to eq edit_profile_path
      expect(page).to have_validation_error("Please enter the same value again.")
    end
  end
end
