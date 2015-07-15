FactoryGirl.define do
  factory :product do
    transient do
      provider "Amazon"
    end
    user
    brand_name "Brand X"
    product_type { "#{provider.to_s.camelize}Product" }
    sequence(:pid){ |n| "#{product_type}ID#{n}" }
    sequence(:name){ |n| "Product #{n}" }
    original_name { "#{brand_name} #{name}" }
    description nil
    note "Some Editor's Note"
    available true
    priority_service true
    price_cents 80
    price_currency "USD"
    marked_price_cents 100
    marked_price_currency "USD"

    initialize_with do
      product_type.constantize.new
    end

    trait(:unavailable)  { available false }
    trait(:not_priority) { priority_service false }

    trait :with_images do
      transient do
        images_count 5
        include_images []
      end

      after(:build) do |product, evaluator|
        images = evaluator.images_count.times.map{|i| "http://url.to/image-#{i}.jpg"}
        images << evaluator.include_images if evaluator.include_images.present?
        product.images = images.flatten.last(evaluator.images_count).reverse
        product.save
      end
    end

    factory :unavailable_product, traits: [:unavailable]
    factory :product_without_priority_service, traits: [:not_priority]
    factory :product_with_images, traits: [:with_images]
  end
end
