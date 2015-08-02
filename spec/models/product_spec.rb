require 'rails_helper'
require "models/concerns/sluggable_examples.rb"

RSpec.describe Product, type: :model do

  subject{ build(:moto_x) }

  it {
    is_expected.to belong_to(
      :founder
    ).class_name("User").counter_cache(:found_products_count).validate
  }

  it { is_expected.to belong_to(:brand).counter_cache(true).validate }
  it { is_expected.to belong_to(:category).counter_cache(true).validate }
  it { is_expected.to belong_to(:merchant).validate }

  it { is_expected.to validate_presence_of(:pid) }
  it { is_expected.to validate_presence_of(:original_name) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to validate_presence_of(:price_currency) }
  it { is_expected.to validate_presence_of(:marked_price_currency) }

  it { is_expected.to validate_numericality_of(:price_cents).only_integer }
  it { is_expected.to validate_numericality_of(:marked_price_cents).only_integer }
  it { is_expected.to validate_numericality_of(:ratings_count).only_integer }
  it { is_expected.to validate_inclusion_of(:average_rating).in_range(0..100) }

  it { is_expected.to have_db_index(:pid) }
  it { is_expected.to have_db_column(:lock_version).of_type(:string) }

  it_behaves_like 'sluggable'

  it "uses name for string representation" do
    expect(subject.to_s).to eq("Moto X (2nd Generation)")
  end

  it "parameterizes the product using merchant name" do
    subject.valid? # generates slug
    expect(subject.to_param).to eq("moto-x-2nd-generation")
  end

  it "scopes product uid to merchant" do
    subject.save
    product = build(:product, pid: subject.pid, merchant: subject.merchant)
    expect(product).not_to be_valid
    expect(product.errors.full_messages).to include("Pid has already been taken")
  end

  it "does not allow an invalid merchant" do
    subject.merchant.name = nil      # non existant
    expect(subject).to be_invalid
    expect(subject.errors[:merchant]).to include('is invalid')
  end

  it "does not allow duplicate PID for same merchant" do
    expect(subject).to be_valid
    create(:product, pid: subject.pid, merchant: subject.merchant)
    expect(subject).to be_invalid
  end

  it "does not allow brand which does not belong to given merchant" do
    product = build(:product, brand: subject.brand, merchant: create(:merchant))
    expect(product).not_to be_valid
    expect(product.errors[:brand]).to include("does not belong to this merchant")
  end

  it "automatically fetch merchant info from brand if not provided" do
    product = build(:product, brand: subject.brand, merchant: nil)
    expect(product).to be_valid
    expect(product.merchant).to eq(product.brand.merchant)
  end

  it "has a cover image and some other images" do
    expect(subject.cover_image).to eq("http://url.to/image-1.jpg")
    expect(subject.images).to include("http://url.to/image-2.jpg")
    expect(subject.images.count).to eq(2)
  end
end
