FactoryGirl.define do
  factory :user do
    sequence(:name){ |n| "User #{n}" }
    sequence(:email){|n| "user#{n}@example.com"}
    password "password"
    password_confirmation "password"

    trait :confirmed do
      initialize_with do
        user = User.new
        user.skip_confirmation! if user.respond_to?(:confirmed?)
        user
      end
    end

    factory :confirmed_user, traits: [:confirmed]
  end
end

