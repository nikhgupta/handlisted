FactoryGirl.define do
  factory :brand do
    merchant
    sequence(:name){ |n| "Brand #{n}" }
    average_rating 0
    ratings_count 0
    products_count 0
  end

  factory :ws_retail, class: Brand do
    name "WS Retail!"
    average_rating 90
    ratings_count  100
    products_count 50

    initialize_with do
      attributes = attributes_for(:flipkart)
      (Merchant.find_by(attributes) || create(:flipkart)).brands.build
    end
  end
end
