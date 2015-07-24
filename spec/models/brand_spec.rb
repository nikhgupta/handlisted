require 'rails_helper'
require "models/concerns/sluggable_examples.rb"

RSpec.describe Brand, type: :model do

  subject{ build(:ws_retail) }

  it { is_expected.to have_many(:products).dependent(:nullify).autosave(true) }
  it { is_expected.to belong_to(:merchant).counter_cache(true).validate }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(60) }
  it { is_expected.to validate_presence_of(:merchant_id) }
  it { is_expected.to validate_inclusion_of(:average_rating).in_range(0..100) }
  it { is_expected.to validate_numericality_of(:ratings_count).only_integer }
  it { is_expected.to validate_numericality_of(:products_count).only_integer }

  it_behaves_like 'sluggable'

  it "has a string representation" do
    expect(subject.to_s).to eq("WS Retail!")
  end

  it "does not allow an invalid merchant" do
    subject.merchant.name = nil      # non existant
    expect(subject).to be_invalid
    expect(subject.errors[:merchant]).to include('is invalid')
  end

  it "validates uniqueness of name scoped to merchant" do
    subject.save

    brand = build(:brand, name: subject.name, merchant: subject.merchant)
    expect(brand).to be_invalid
    expect(brand.errors[:name]).to include("has already been taken")

    brand = build(:brand, name: subject.name, merchant: create(:merchant))
    expect(brand).to be_valid
  end
end
