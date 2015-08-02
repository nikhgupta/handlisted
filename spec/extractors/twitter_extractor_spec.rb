require 'rails_helper'

describe TwitterExtractor, :omniauth do
  let(:auth) { OmniAuth.config.mock_auth[:twitter] }
  subject{ described_class.new(auth) }
  let(:match) {
    {
      uid: "12345",
      provider: "twitter",
      name: "Test Twitter User",
      email: nil,
      image: "http://url.to/profile-image.jpg",
      verified: true,
      username: "testusername",
      gender: nil,
      timezone_offset: 19800,
      url: "https://twitter.com/testusername",
      language: "fr",
      credentials: {
        token: "some-token",
        refresh_token: nil,
        secret: "some-secret",
        expires_at: nil
      }
    }
  }

  it "has a reauth_hash that can be used to supply parameters when reauthenticating" do
    expect(described_class.reauth_hash).to eq(force_login: true)
  end

  it "extracts data from omniauth data" do
    %w[uid provider name email image verified username gender
       timezone_offset url language credentials].each do |field|
      message  = "expected value of #{field}: #{subject.send(field).inspect}\n"
      message += "#{" " * (field.length + 15)}got: #{match[field.to_sym].inspect}"
      expect(subject.send(field)).to eq(match[field.to_sym]), message
    end
  end

  it "has a signature method which can uniquely identity this identity" do
    expect(subject.signature).to eq(uid: match[:uid], provider: match[:provider])
  end

  it "has attributes_data method that returns extracted data as a Hash" do
    match.merge!(match.delete(:credentials))
    expect(subject.attributes_data).to eq(match)
  end
end

