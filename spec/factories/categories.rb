FactoryGirl.define do
  factory :category do
    name "Category X"
    parent_id nil

    factory :mobile do
      name "Mobile & Accessories"
    end
  end
end
