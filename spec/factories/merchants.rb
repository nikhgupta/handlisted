FactoryGirl.define do
  factory :merchant do
    sequence(:name){ |n| "Merchant #{n}" }
    service "Merchant X's Priority Service"
  end

  factory :flipkart, class: Merchant do
    service 'Flipkart Advantage'
    initialize_with { Merchant.find_or_initialize_by(name: "Flipkart!") }
  end
end
