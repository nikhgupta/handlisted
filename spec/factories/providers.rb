FactoryGirl.define do
  factory :provider do
    sequence(:name){ |n| "Provider #{n}" }
    priority_service_name { "#{name} Priority Service!" }
  end
end
