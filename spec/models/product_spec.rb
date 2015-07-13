require 'rails_helper'
require "models/concerns/sluggable_examples.rb"

RSpec.describe Product, type: :model do
  it_behaves_like "sluggable"
  it "scopes slugs to providers" do
    product1 = create(:product)
    product2 = build(:product, name: product1.name)
    expect{product2.save}.not_to raise_error
    expect(product2.slug).to eq(product1.slug)
  end

  it "uses name for string representation" do
    product = build(:product, name: "Product X")
    expect(product.to_s).to eq("Product X")
  end

  it "parameterizes the product using providder name" do
    provider = create(:provider, name: "Provider X")
    product  = create(:product, name: "Product X", provider: provider)
    expect(product.to_param).to eq("provider-x/product-x")
  end

  it "has a cover image" do
    product = create(:product_with_images, cover: "http://url.to/cover.jpg")
    expect(product.cover_image).to eq("http://url.to/cover.jpg")
    product = create(:product_with_images, include_images: ["http://url.to/image.jpg"])
    expect(product.cover_image).to eq("http://url.to/image.jpg")
  end
end
