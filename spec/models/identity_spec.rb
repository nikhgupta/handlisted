require 'rails_helper'

RSpec.describe Identity, :omniauth, type: :model do
  before do
    @auth = OmniAuth.config.mock_auth[:facebook]
  end
  subject{ build(:identity) }

  it { is_expected.to belong_to(:user).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_uniqueness_of(:uid).scoped_to(:provider).with_message('already exists for this provider') }

  it 'finds or initializes identity with given omniauth data' do
    identity = described_class.find_with_omniauth(@auth)
    expect(identity).to be_nil

    identity = create(:identity, user: create(:user), provider: "facebook", uid: "12345")
    expect(described_class.find_with_omniauth(@auth)).to eq(identity)
    expect(described_class.find_or_initialize_with_omniauth(@auth)).to eq(identity)

    identity.delete
    identity = described_class.find_or_initialize_with_omniauth(@auth)
    expect(identity.user).to be_nil
    expect(identity).to be_new_record
    expect(identity).not_to be_valid
    expect(identity).not_to be_persisted
    expect(identity.provider).to eq("facebook")
    expect(identity.errors[:user]).to eq(["can't be blank"])
  end

  it "checks if identity is already linked with a user" do
    expect(build(:identity)).to be_linked
    expect(build(:identity, user: nil)).not_to be_linked

    user = create(:user)
    expect(build(:identity)).not_to be_linked_with(user)
    expect(build(:identity, user: user)).to be_linked_with(user)
  end

  it "links the identity to given user if not already linked" do
    user = create(:user)
    identity = build(:identity)
    expect(identity.link_with(user)).to be_falsey
    identity = build(:identity, user: nil)
    expect(identity.link_with(user)).to be_truthy
  end

  it "links the identity to given user forcefully" do
    user = create(:user)
    identity = build(:identity)
    expect(identity.link_with!(user)).to be_truthy
  end
end
