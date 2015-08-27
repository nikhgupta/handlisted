FactoryGirl.define do
  factory :product do
    founder
    merchant
    category
    brand nil
    sequence(:pid){ |n| "#{merchant.to_s.upcase}ID#{n}" }
    sequence(:name){ |n| "Product #{n}" }
    original_name { "#{merchant} #{name}" }
    description nil
    note nil
    available false
    prioritized false
    price_cents { rand(100000) }
    price_currency { %w[INR USD AUD GBP].sample }
    marked_price_cents { price_cents + rand(40000) }
    marked_price_currency { price_currency }
    url 'http://url.to/product/'
    url_hash { Digest::MD5.hexdigest url }

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

    factory :product_with_images, traits: [:with_images]
  end

  factory :moto_x, class: Product do
    founder
    association :category, factory: :mobile

    initialize_with do
      brand = Brand.find_by(attributes_for(:ws_retail)) || create(:ws_retail)
      product = brand.products.build
      product.merchant = brand.merchant
      product
    end

    pid "MOBDZ3FVVZT38WQH"
    name nil
    original_name "Moto X (2nd Generation)"
    description "### Moto X (2nd Gen)\nPure Style. Pure Performance. Pure Voice."
    available true
    prioritized true
    price_cents 500_00
    price_currency "INR"
    marked_price_cents 1000_00
    marked_price_currency "INR"
    images %w( http://url.to/image-1.jpg http://url.to/image-2.jpg )
    url 'http://www.amazon.com/dp/B00X4WHP5E'
    url_hash '3410f59232bc883c02ce418bd0317ac0'

    average_rating 95
    ratings_count 1000
  end
end
