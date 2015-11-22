FactoryGirl.define do
  sequence :username do |n|
    "user#{n}"
  end

  factory :user, aliases: [:founder] do
    username
    email { "#{username}@example.com" }
    password "password"
    password_confirmation { password }
    sequence(:name){ |n| "User #{n}" }

    trait :confirmed do
      initialize_with do
        user = User.new
        user.skip_confirmation! if user.respond_to?(:confirmed?)
        user
      end
    end

    trait :full_info do
      gender "male"
      image  "http://url.to/image.jpg"
      language "hi"
      timezone_offset 19800
    end

    factory :admin do
      admin true
    end

    factory :confirmed_user, traits: [:confirmed]
    factory :user_with_full_info, traits: [:full_info]
  end
end
