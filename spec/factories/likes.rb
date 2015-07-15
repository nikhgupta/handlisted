FactoryGirl.define do
  factory :like do
    transient do
      target_product { create(:product) }
    end

    user
    target_product_id { target_product.id }
  end
end
