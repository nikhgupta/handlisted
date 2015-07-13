require 'rails_helper'

RSpec.describe "products/new", type: :view do
  before(:each) do
    assign(:product, Product.new(
      :brand => "MyString",
      :user => "MyString",
      :name => "MyString",
      :note => "MyString",
      :price => "MyString",
      :available => "MyString",
      :priority_service => "MyString"
    ))
  end

  it "renders new product form" do
    render

    assert_select "form[action=?][method=?]", products_path, "post" do

      assert_select "input#product_brand[name=?]", "product[brand]"

      assert_select "input#product_user[name=?]", "product[user]"

      assert_select "input#product_name[name=?]", "product[name]"

      assert_select "input#product_note[name=?]", "product[note]"

      assert_select "input#product_price[name=?]", "product[price]"

      assert_select "input#product_available[name=?]", "product[available]"

      assert_select "input#product_priority_service[name=?]", "product[priority_service]"
    end
  end
end
