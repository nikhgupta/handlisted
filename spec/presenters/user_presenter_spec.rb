require 'rails_helper'

describe UserPresenter do
  let(:user) { build_stubbed :user_with_full_info }
  let(:presenter) { described_class.new user, view }

  it "uses email as name when user's name is not present" do
    expect(presenter.name).to eq(user.name)

    user.name  = nil
    expect(presenter.name).to eq(user.email)
  end

  it "provides helper to link to user's avatar" do
    html = Capybara.string(presenter.link_avatar_to '#', class: 'test')
    expect(html).to have_selector('a.test[href="#"]')
    expect(html).to have_selector("a img.img-responsive[alt='#{user.name}']")
    expect(html).to have_selector("a img[src='#{user.image}']")
  end

  it "links to default avatar when user has no avatar" do
    user.image = nil
    html = Capybara.string(presenter.link_avatar_to '#', class: 'test')
    expect(html).to have_selector('a.test[href="#"]')
    expect(html).to have_selector("a img.img-responsive[alt='#{user.name}']")
    expect(html.find('img')[:src]).to include("avatars/missing.jpg")
  end
end
