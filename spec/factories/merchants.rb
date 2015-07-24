FactoryGirl.define do
  factory :merchant do
    sequence(:name){ |n| "Merchant #{n}" }
    service "Merchant X's Priority Service"

    factory :flipkart do
      service 'Flipkart Advantage'
      initialize_with { Merchant.find_or_initialize_by(name: "Flipkart!") }
    end
  end
end
