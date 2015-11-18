require 'rails_helper'
require "models/concerns/sluggable_examples.rb"

RSpec.describe Merchant, type: :model do
  subject{ build(:flipkart) }

  it { is_expected.to have_many(:brands).dependent(:destroy).autosave(true) }
  it { is_expected.to have_many(:products).dependent(:destroy).autosave(true) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(20) }
  # it { is_expected.to validate_numericality_of(:brands_count).only_integer }

  it_behaves_like 'sluggable'

  it 'has a string representation' do
    expect(subject.to_s).to eq('Flipkart!')
  end

  it 'has an identifier' do
    expect(subject.identifier).to eq(:flipkart)
    subject.name = "Flip Kart"
    expect(subject.identifier).to eq(:'flip-kart')
  end

  it "validates uniqueness of name" do
    subject.save

    merchant = build(:merchant, name: subject.name)
    expect(merchant).to be_invalid
    expect(merchant.errors[:name]).to include("has already been taken")
  end
end
