require 'rails_helper'

RSpec.describe "products/show", type: :view do
  before(:each) do
    @product = assign(:product, Product.create!(
      :brand => "Brand",
      :user => "User",
      :name => "Name",
      :note => "Note",
      :price => "Price",
      :available => "Available",
      :priority_service => "Priority Service"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Brand/)
    expect(rendered).to match(/User/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Note/)
    expect(rendered).to match(/Price/)
    expect(rendered).to match(/Available/)
    expect(rendered).to match(/Priority Service/)
  end
end
