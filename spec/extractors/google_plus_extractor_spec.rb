require 'rails_helper'

describe GooglePlusExtractor do
  let(:auth) { OmniAuth.config.mock_auth[:google_plus] }
  subject{ described_class.new(auth) }
  let(:match) {
    {
      uid: "12345",
      provider: "google_plus",
      name: "Test Google User",
      email: "testuser@google_plus.com",
      image: "http://url.to/profile-image.jpg",
      verified: true,
      username: nil,
      gender: "female",
      timezone_offset: 0,
      url: "http://plus.google.com/some-profile-id",
      language: "fr",
      credentials: {
        token: "some-long-token" * 100,
        refresh_token: "some-refresh-token",
        secret: nil,
        expires_at: auth['credentials']['expires_at']
      }
    }
  }

  it "has a reauth_hash that can be used to supply parameters when reauthenticating" do
    expect(described_class.reauth_hash).to eq(prompt: 'consent')
  end

  it "extracts data from omniauth data" do
    %w[uid provider name email image verified username gender
       timezone_offset url language credentials].each do |field|
      message  = "expected value of #{field}: #{subject.send(field).inspect}\n"
      message += "#{" " * (field.length + 15)}got: #{match[field.to_sym].inspect}"
      expect(subject.send(field)).to eq(match[field.to_sym]), message
    end
  end

  it "extracts username from gmail address" do
    new_auth = auth.dup
    new_auth["info"]["email"] = "testuser@gmail.com"
    expect(described_class.new(new_auth).username).to eq("testuser")
  end

  it "has a signature method which can uniquely identity this identity" do
    expect(subject.signature).to eq(uid: match[:uid], provider: match[:provider])
  end

  it "has attributes_data method that returns extracted data as a Hash" do
    match.merge!(match.delete(:credentials))
    expect(subject.attributes_data).to eq(match)
  end
end


