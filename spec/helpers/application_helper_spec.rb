require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  include Devise::TestHelpers
  it "presents current user when current user is present" do
    expect(helper.current_user).to be_nil
    user = create(:confirmed_user)
    sign_in user
    expect(helper.current_user).to be_a_presenter_for(user)
    expect(helper.current_user).to be_confirmed # checks for method delegation
  end

  it "provides a helper method to link logo" do
    html = helper.link_logo_to '/someurl', class: "brand"
    expect(html).to have_selector('a.brand')
  end

  it "provides a helper method for getting font-awesome icons" do
    html = helper.fa_icon "star", class: "test", style: "display:block"
    expect(html).to have_selector('i.fa.fa-star.test[style="display:block"]')
  end

  it "provides a helper method for getting icon for an OmniAuth provider" do
    html = helper.oauth_icon_for :google_plus
    expect(html).to have_selector('i.fa.fa-2x.fa-google-plus-square.fa-google-plus-colored')

    html = helper.oauth_icon_for :google_plus, title: "Google+", size: '4x', class: 'test'
    expect(html).to have_selector('i.fa-4x.test[title="Google+"]')
  end

  it "provides a helper method to link path to add OmniAuth Identity" do
    html = helper.oauth_link_to :google_plus, 'test_html', class: "test"
    link = helper.omniauth_authorize_path(:user, :google_plus)
    expect(html).to have_link('test_html', href: link)
    expect(html).to have_selector('a.test')
  end
end
