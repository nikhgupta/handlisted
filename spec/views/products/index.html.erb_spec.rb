require 'rails_helper'

RSpec.describe "products/index", type: :view do
  before(:each) do
    assign(:products, [
      Product.create!(
        :brand => "Brand",
        :user => "User",
        :name => "Name",
        :note => "Note",
        :price => "Price",
        :available => "Available",
        :priority_service => "Priority Service"
      ),
      Product.create!(
        :brand => "Brand",
        :user => "User",
        :name => "Name",
        :note => "Note",
        :price => "Price",
        :available => "Available",
        :priority_service => "Priority Service"
      )
    ])
  end

  it "renders a list of products" do
    render
    assert_select "tr>td", :text => "Brand".to_s, :count => 2
    assert_select "tr>td", :text => "User".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Note".to_s, :count => 2
    assert_select "tr>td", :text => "Price".to_s, :count => 2
    assert_select "tr>td", :text => "Available".to_s, :count => 2
    assert_select "tr>td", :text => "Priority Service".to_s, :count => 2
  end
end
