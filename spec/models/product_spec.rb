require 'rails_helper'
require "models/concerns/sluggable_examples.rb"

RSpec.describe Product, type: :model do

  subject{ build(
    :product_with_images,
    pid: "1234", name: "Product X", provider: :amazon,
    include_images: %w[image1 http://url.to/image2.jpg cover]
  )}

  it { is_expected.to validate_uniqueness_of(:pid).scoped_to(:product_type) }
  it { is_expected.to validate_presence_of(:product_type) }

  it "cannot be instantiated directly" do
    message = "Cannot directly instantiate a Product"
    expect{ described_class.new }.to raise_error(NotImplementedError).with_message(message)
  end

  it_behaves_like "sluggable"

  it "uses name for string representation" do
    expect(subject.to_s).to eq("Product X")
  end

  it "returns the name of the provider" do
    expect(subject.provider).to eq("Amazon")
    expect(subject.provider_slug).to eq("amazon")
  end

  it "parameterizes the product using providder name" do
    expect(subject.to_param).to eq("amazon/product-x")
  end

  it "scopes product uid to provider" do
    subject.save
    product = build(:product, pid: subject.pid, provider: :amazon)
    expect(product).not_to be_valid
    expect(product.errors.full_messages).to include("Pid has already been taken")
  end

  it "has a cover image and some other images" do
    expect(subject.cover_image).to be_present
    expect(subject.cover_image).to eq("http://ecx.images-amazon.com/images/I/cover.jpg")

    expect(subject.images).to include("http://url.to/image2.jpg")
    expect(subject.images).to include("http://ecx.images-amazon.com/images/I/image1.jpg")
    expect(subject.images.count).to eq(5)
  end

  it "provides affiliate link for the product" do
    url = "http://www.amazon.com/dp/1234/?tag=shabd-20"
    expect(subject.affiliate_link).to eq(url)
  end

  it "provides the name of the priority service for the provider" do
    expect(subject.priority_service_name.downcase).to eq("fulfilled by amazon")
  end
end
