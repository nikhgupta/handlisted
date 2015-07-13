FactoryGirl.define do
  factory :product do
    user
    provider
    brand { create(:brand, provider: provider) }
    pid "somepid"
    sequence(:name){ |n| "Product #{n}" }
    original_name { "#{brand.name} #{name}" }
    description nil
    note "Some Editor's Note"
    available true
    priority_service true

    trait(:unavailable)  { available false }
    trait(:not_priority) { priority_service false }

    trait :with_images do
      transient do
        images_count 5
        include_images []
      end

      after(:create) do |product, evaluator|
        count  = evaluator.images_count
        count -= evaluator.include_images.count if evaluator.include_images.respond_to?(:any?)

        create_list(:image, count, product: product)
        evaluator.include_images.each do |image|
          create(:image, product: product, url: image)
        end
      end
    end

    trait :with_cover do
      transient do
        cover nil
      end
      after(:create) do |product, evaluator|
        if evaluator.cover.present?
          create_list(:image, 2, product: product) if product.images.blank?
          image = product.images.last
          image.cover = true
          image.url   = evaluator.cover if evaluator.cover.is_a?(String)
          image.save
        end
      end
    end

    factory :unavailable_product, traits: [:unavailable]
    factory :product_without_priority_service, traits: [:not_priority]
    factory :product_with_images, traits: [:with_images, :with_cover]
  end
end
