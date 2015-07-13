FactoryGirl.define do
  factory :follow do
    user
    target_user { create(:user) }
  end
end
