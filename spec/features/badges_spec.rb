require 'rails_helper'

RSpec.feature "displaying user badges", :timers do
  background do
    john  = create(:confirmed_user, username: :john)
    diaz  = create(:confirmed_user, username: :diaz)
    omega = Merit::Badge.find_by_name_and_level("omega", nil)
    autob = Merit::Badge.find_by_name_and_level("autobiographer", nil)
    john.add_badge(omega.id)
    diaz.add_badge(autob.id)
  end

  scenario "on user profile pages" do
    visit "/john"
    expect(page).to have_badge("omega").special.unique
    expect(page).not_to have_badge("autobiographer").with_difficulty("bronze")

    visit "/diaz"
    expect(page).not_to have_badge("omega")
    expect(page).to have_badge("autobiographer")
  end

  scenario "on user's edit profile page" do
    sign_in_with "john", "password"
    visit edit_profile_path
    expect(page).to have_badge("omega").special.unique
  end
end

RSpec.feature "user badges", :timers do
  background do
    travel_to "January 1, 2020"
  end

  scenario "user has no badge upon registration" do
    user = create :confirmed_user
    expect(user.reload.badges).to be_empty
  end

  scenario "'Omega' badge is granted to developers" do
    mail = HandListed::Facts::DEVELOPER_EMAILS[0]
    user = User.find_by(email: mail) || create(:confirmed_user, email: mail)
    user.confirm unless user.confirmed?

    sign_in_with user.email
    expect(user).to have_badge('omega')
    expect(user).not_to have_badge('new-user')
  end

  scenario "'Alpha user' badge is granted to users who have registered during the Alpha phase" do
    travel_to(HandListed::Facts::BETA_STARTED_ON - 1.day)
    user = sign_in_as :confirmed_user
    expect(user).to have_badge("alpha-user")
    expect(user).not_to have_badge('new-user')
    sign_out_if_logged_in

    travel_to "January 1, 2020"
    user = sign_in_as :confirmed_user
    expect(user).not_to have_badge("alpha-user")
    expect(user).to have_badge('new-user')
  end

  scenario "'Beta user' badge is granted to users who have registered during the Beta phase" do
    travel_to(HandListed::Facts::BETA_STARTED_ON - 1.day)
    user = sign_in_as :confirmed_user
    expect(user).not_to have_badge("beta-user")
    sign_out_if_logged_in

    travel_to(HandListed::Facts::LAUNCHED_ON - 1.day)
    user = sign_in_as :confirmed_user
    expect(user).to have_badge("beta-user")
    expect(user).not_to have_badge('new-user')
    sign_out_if_logged_in

    travel_to "January 1, 2020"
    user = sign_in_as :confirmed_user
    expect(user).not_to have_badge("beta-user")
    expect(user).to have_badge('new-user')
  end

  scenario "'New User' badge is removed after 10th login, if user registered more than 30 days ago" do
    user = create :confirmed_user
    expect(user).not_to have_badge('new-user')
    with_logged_in(user.email){ expect(user).to have_badge('new-user') }

    allow_any_instance_of(User).to receive(:sign_in_count).and_return 10
    with_logged_in(user.email){ expect(user).to have_badge('new-user') }

    travel 29.days
    with_logged_in(user.email){ expect(user).to have_badge('new-user') }

    # Check if badge is also updated when user logs out?
    sign_in_with user.email
    travel 1.day
    sign_out_if_logged_in
    expect(user).not_to have_badge('new-user')
  end

  scenario "'Autobiographer' badge is granted temporarily to users with completed profile information" do
    user = create :confirmed_user, gender: nil, image: nil
    sign_in_with user.email        # triggers badge generation
    expect(user).not_to have_badge('autobiographer')

    user.update_attributes gender: :male, image: "http://url.to/image.jpg"
    sign_out_if_logged_in          # triggers badge generation
    expect(user).to have_badge('autobiographer')
  end
end
