require 'rails_helper'

describe ProductDecorator do
  it "redefines name to name or original name, whichever is present" do
    product = build(:product, name: "ProductZ", original_name: "BrandZ ProductZ")
    expect(product.decorate.name).to eq("ProductZ")
    product = build(:product, name: nil, original_name: "BrandZ ProductZ")
    expect(product.decorate.name).to eq("BrandZ ProductZ")
  end

  it "defines a short name for the product" do
    decorated = build(:product, name: "A" * 40).decorate
    expect(decorated.short_name).to eq("A" * 40)

    decorated = build(:product, name: "A" * 100).decorate
    expect(decorated.short_name).to eq("A" * 56 + " ...")
    expect(decorated.short_name(80)).to eq("A" * 76 + " ...")
  end

  it "defines a helper to easily add cover image for a product in HTML" do
    cover = "http://url.to/cover.jpg"
    product = build(:product_with_images, name: "Product Z", include_images: [cover])
    html = product.decorate.cover_image_tag width: 40
    html = Nokogiri::HTML.fragment(html)
    expect(html.children.count).to eq(1)

    image   = html.children.first
    expect(image[:src]).to eq(cover)
    expect(image[:alt]).to eq("Product Z")
    expect(image[:width]).to eq("40")
  end

  it "defines price to be human representatio of product's price with currency" do
    decorated = build(
      :product,
      price_cents: 100_00, price_currency: "GBP",
      marked_price_cents: 125_00, marked_price_currency: "USD"
    ).decorate
    expect(decorated.price).to eq("£100")
    expect(decorated.marked_price).to eq("$125")
  end

  it "defines path to easily access product's show path" do
    decorated = create(:moto_x).decorate
    expect(decorated.path).to eq("/product/flipkart/moto-x-2nd-generation")
  end

  # it "defines an action button for affiliate link" do
  #   decorated = build(
  #     :product, pid: "123", price_cents: 80_00,
  #     price_currency: "GBP", provider: :amazon
  #   ).decorate
  #   html = decorated.affiliate_link_action_button style: "display: block"
  #   selector = 'a.btn.btn-large.btn-primary.fs28[style="display: block"]'
  #   expect(html).to have_selector(selector, text: "£80 on Amazon")
  # end
end
