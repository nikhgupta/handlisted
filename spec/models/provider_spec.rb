require 'rails_helper'
require "models/concerns/sluggable_examples.rb"

RSpec.describe Provider, type: :model do
  it_behaves_like "sluggable"

  it "uses name for string representation" do
    provider = build(:provider, name: "Test FlipKart")
    expect(provider.to_s).to eq("Test FlipKart")
  end
end
