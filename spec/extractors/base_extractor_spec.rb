require 'rails_helper'

RSpec.describe Extractor::Base, :omniauth do
  it "finds the class for a given extractor" do
    expect(described_class.class_for(:facebook)).to eq(FacebookExtractor)
    expect{described_class.class_for(:something)}.to raise_error(Extractor::Error)
  end

  it "loads the extractor for the given auth" do
    auth = OmniAuth.config.mock_auth[:facebook]
    auth = described_class.load(auth)
    expect(auth).to be_a(FacebookExtractor)
  end
end
