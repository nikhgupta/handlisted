FactoryGirl.define do
  factory :follow do
    transient do
      target_user { create(:user) }
    end

    user
    target_user_id { target_user.id }
  end
end
