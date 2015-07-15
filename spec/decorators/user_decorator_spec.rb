require 'rails_helper'

describe UserDecorator do
  it "redefines name to name or email, whichever is present" do
    user = build(:user, name: "UserX", email: "userx@example.com")
    expect(user.decorate.name).to eq("UserX")
    user = build(:user, name: nil, email: "userx@example.com")
    expect(user).to be_invalid
    expect(user.decorate.name).to eq("userx@example.com")
  end

  it "defines a helper method to link avatar to a URL" do
    user = build(:user, name: "UserX", image: "http://url.to/avatar.jpg")
    html = user.decorate.link_avatar_to("/someurl", class: "navbar-brand")
    html = Nokogiri::HTML.fragment(html).children[0]
    expect(html.node_name).to eq('a')
    expect(html.children.map(&:node_name)).to eq(['img'])
    expect(html[:class]).to eq('navbar-brand')
    expect(html[:href]).to eq('/someurl')
    expect(html.children[0][:alt]).to eq('UserX')
    expect(html.children[0][:src]).to eq('http://url.to/avatar.jpg')

    user = build(:user, name: "UserZ")
    html = user.decorate.link_avatar_to("/", class: "navbar-brand")
    html = Nokogiri::HTML.fragment(html).children[0]
    expect(html[:href]).to eq('/')
    expect(html.children[0][:alt]).to eq('UserZ')
    expect(html.children[0][:src]).to eq('/assets/absolute-admin/avatars/3.jpg')
  end
end
