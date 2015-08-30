require 'rails_helper'
require "models/concerns/sluggable_examples.rb"

RSpec.describe Category, type: :model do
  it_behaves_like 'sluggable'

  it { is_expected.to have_many(:products) }
  it { is_expected.to validate_presence_of(:name) }

  it "uses slug for param" do
    category = build :category
    expect(category.to_param).to eq(category.slug)
  end

  describe '.create_hierarchy' do
    it "returns empty list if category list is empty" do
      expect(Category.create_hierarchy([])).to eq []
    end

    it "creates hierarchical categories for the specified category list" do
      actual = Category.create_hierarchy(:parent, :child)
      expect(actual[0]).to be_a(Category).and be_persisted
      expect(actual[1]).to be_a(Category).and be_persisted

      expect(actual[1].reload.self_and_ancestors).to eq(actual)
      expect(actual[0].reload.self_and_descendants).to eq(actual)
    end

    it "reuses categories if they already exist" do
      parent = Category.create(name: :parent, parent: nil)
      actual = Category.create_hierarchy(:parent, :child)
      expect(actual[0]).to eq parent
    end
  end

  describe "#products_for" do
    it "returns all products for a given hierarchical relationship" do
      parent, child = Category.create_hierarchy(:parent, :child)
      product_in_parent = create :product, category: parent
      product_in_child  = create :product, category: child
      all_products = [product_in_parent, product_in_child]

      expect(child.products_for(:ancestors)).to           include product_in_parent
      expect(parent.reload.products_for(:descendants)).to include product_in_child
      expect(child.products_for(:self_and_ancestors)).to       eq all_products
      expect(parent.products_for(:self_and_descendants)).to    eq all_products
    end
  end

  describe "#cover_product" do
    it "returns first product found in the given category or its descendants" do
      parent, child = Category.create_hierarchy(:parent, :child)
      product_in_child  = create :product, category: child

      expect(child.cover_product).to eq product_in_child
      expect(parent.reload.cover_product).to eq product_in_child
    end
  end
end
