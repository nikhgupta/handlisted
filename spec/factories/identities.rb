FactoryGirl.define do
  sequence :uid do |n|
    "UID #{n}"
  end

  factory :identity do
    uid
    user
    name     "Identity 1"
    token    "SOMESECRETTOKEN"
    provider "Provider 1"

    factory :identity_with_full_info do
      url   "http://some.url/"
      image "http://url.to/image.jpg"
      token "a-secret-token"
      gender   "male"
      verified true
      language "hi"
      timezone_offset 19800
      expires_at { 1.hour.since }
    end

    factory :expired_identity do
      expires_at { 4.hours.ago }
    end
  end
end
