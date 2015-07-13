FactoryGirl.define do
  factory :like do
    user
    target_product_id { create(:product).id }
  end
end
