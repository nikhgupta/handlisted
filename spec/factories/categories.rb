FactoryGirl.define do
  factory :category do
    name "Category X"
    lft 0
    rgt 2
    parent_id 0
    depth 0
    children_count 0

    factory :mobile do
      name "Mobile & Accessories"
    end
  end
end
