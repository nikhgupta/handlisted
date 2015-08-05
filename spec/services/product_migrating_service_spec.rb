require 'rails_helper'

RSpec.describe ProductMigratingService, type: :service do
  let(:user) { create :confirmed_user }
  let(:data) { ProductScraper.fetch_basic_info(PRODUCTS_LIST[:amazon_echo][:url]) }

  it "raises error if user or data is missing" do
    message = "User or data is missing!"
    expect{ described_class.new }.to raise_error(ArgumentError).with_message(message)
    expect{
      described_class.new(user: build_stubbed(:user))
    }.to raise_error(ArgumentError).with_message(message)
    expect{
      described_class.new(data: { pid: "12345" })
    }.to raise_error(ArgumentError).with_message(message)
    expect{
      described_class.new(user: build_stubbed(:user), data: { pid: "12345" })
    }.not_to raise_error
  end

  it 'creates a new product from the given data attached to the given user' do
    response = described_class.new(user: user, data: data).run
    expect(response[:id]).to eq(Product.last.to_param)
    expect(response[:errors]).to be_nil
  end

  it 'returns existing product id when it can find product with given data' do
    # simulate that the product already exists
    described_class.new(user: user, data: data).run

    # actual test
    expect(Product).not_to receive(:new)
    expect(Product).not_to receive(:create)
    response = described_class.new(user: user, data: data).run
    expect(response[:id]).to eq('amazon-echo')
    expect(response[:errors]).to be_nil
  end

  it 'returns validation errors encountered while migration' do
    data[:original_name] = nil
    response = described_class.new(user: user, data: data).run
    expect(response[:id]).to be_nil
    expect(response[:errors]).to include('Original name can\'t be blank')
  end
end
