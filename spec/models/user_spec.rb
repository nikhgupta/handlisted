require 'rails_helper'
require "models/concerns/sluggable_examples.rb"

RSpec.describe User, type: :model do
  it_behaves_like "sluggable"

  it "uses name for string representation" do
    user = build(:user, name: "Test User")
    expect(user.to_s).to eq("Test User")
  end
end
