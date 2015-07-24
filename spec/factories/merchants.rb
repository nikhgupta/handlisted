FactoryGirl.define do
  factory :merchant do
    sequence(:name){ |n| "Merchant #{n}" }
    service "Merchant X's Priority Service"

    factory :flipkart do
      name 'Flipkart!'
      service 'Flipkart Advantage'
    end
  end
end
