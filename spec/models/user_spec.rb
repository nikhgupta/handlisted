require 'rails_helper'
require "models/concerns/sluggable_examples.rb"

RSpec.describe User, type: :model do
  it_behaves_like "sluggable"

  it {
    is_expected.to have_many(
      :found_products
    ).class_name("Product").dependent(:nullify).autosave(true)
  }

  it "uses name for string representation" do
    user = build(:user, name: "Test User")
    expect(user.to_s).to eq("Test User")
  end

  describe ".confirm_via_omniauth" do
    it "confirms an existing user from omniauth data" do
      auth = OmniAuth.config.mock_auth[:facebook]
      record = described_class.confirm_via_omniauth(auth)
      expect(record).to be_nil

      user = create(:user, email: "testuser@facebook.com")
      expect(user).not_to be_confirmed

      record = described_class.confirm_via_omniauth(auth)
      expect(record).to eq(user.reload)
      expect(user).to be_confirmed
    end
  end

  describe ".create_from_omniauth" do
    it "creates a new user from omniauth data" do
      auth = OmniAuth.config.mock_auth[:facebook]
      record = described_class.create_from_omniauth(auth)
      expect(record).to be_a(User)
      expect(record).to be_persisted
      expect(record.email).to eq(auth["info"]["email"])
    end
  end

  describe ".new_with_session" do
    def build_new_user_with_session attributes = {}
      user = build(:user_with_full_info, attributes)
      described_class.new_with_session(user.attributes, @session)
    end
    before do
      @session ||= {}
      @auth = OmniAuth.config.mock_auth[:facebook]
      @session["devise.oauth_data"] = FacebookExtractor.new(@auth).attributes_data
    end
    it "merges information from omniauth session data when missing" do
      data = {
        name: nil, email: nil, image: nil,
        gender: "female", language: "fr",
        timezone_offset: (3.5*3600).to_i
      }
      data.each do |field, value|
        value ||= @auth['info'][field]

        user = build_new_user_with_session(field => nil)
        expect(user.send(field)).to eq(value)

        user = build_new_user_with_session
        expect(user.send(field)).to be_present
        expect(user.send(field)).not_to eq(value)
      end
    end

    it "builds associated identity from omniauth session data" do
      user = build_new_user_with_session
      identity = user.identities.last
      expect(identity).not_to be_persisted
      expect(identity.provider).to eq("facebook")

      # save the user as if the form was submitted
      user.password = user.password_confirmation = Devise.friendly_token[0,20]
      user.save
      user.confirm

      expect(identity).to be_valid
      expect(identity).to be_persisted
    end
  end
end
