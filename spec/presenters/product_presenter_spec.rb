require 'rails_helper'

describe ProductPresenter do
  let(:product) { create :moto_x }
  let(:presenter) { described_class.new product, view }

  it "delegates to scraped name, when product's name is not present" do
    expect(presenter.name).to eq "Moto X (2nd Generation)"
    product.name = "Moto X"
    expect(presenter.name).to eq "Moto X"
  end

  it "presents product's price in a human readable currency format" do
    expect(presenter.price).to eq("₹500")
    expect(presenter.marked_price).to eq("₹1,000")
  end

  it "presents Markdown formatted description for the product" do
    html = Capybara.string presenter.marked_description
    expect(html).to have_selector("h3", text: "Moto X (2nd Gen)")
  end

  it 'provides helper for affiliate link button for product' do
    html = Capybara.string presenter.affiliate_link_action_button
    url  = "/products/moto-x-2nd-generation/go"
    selector = "a.btn.affiliate-button[href='#{url}'][target='_blank']"
    expect(html).to have_selector(selector, text: "₹500 on Flipkart!")
  end

  it "provides helper to add cover image for product" do
    html = Capybara.string presenter.cover_image_tag(width: 40)
    image, name = product.cover_image, presenter.name; nil
    selector = "img[src='#{image}'][alt='#{name}'][width='40']"
    expect(html).to have_selector(selector)
  end

  describe "product like button" do
    it 'produces button with empty heart if user has not liked the product yet' do
      allow(view).to receive(:current_user).and_return(build_stubbed(:user))
      html = Capybara.string presenter.like_button
      url  = "/products/moto-x-2nd-generation/like"
      selector = "a[data-like='off'][href='#{url}'] i.fa.fa-heart-o.fa-2x"
      expect(html).to have_selector(selector)
    end

    it 'produces button with filled heart if user is liking the product' do
      user = build_stubbed(:user)
      user.like(product)
      allow(view).to receive(:current_user).and_return(user)

      html = Capybara.string presenter.like_button
      url  = "/products/moto-x-2nd-generation/like"
      selector = "a[data-like='on'][href='#{url}'] i.fa.fa-heart.fa-2x"
      expect(html).to have_selector(selector)
    end
  end
end
