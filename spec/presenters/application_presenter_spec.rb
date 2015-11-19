require 'rails_helper'

RSpec.describe ApplicationPresenter, type: :presenter do
  subject { described_class.new({ a: 'a' }, view) }

  it "provides helper method to render markdown" do
    html = Capybara.string subject.markdown("### title")
    expect(html).to have_selector('h3', text: 'title')
  end

  it "allows accessing the underlying object by specifying a name" do
    subject.class.presents :some_object
    expect(subject).to be_respond_to(:some_object)
    expect(subject.some_object).to eq({ a: 'a' })
  end

  it "delegates missing methods to underlying object" do
    expect(subject).to be_respond_to(:has_key?)
    expect(subject.fetch(:a)).to eq('a')
  end
end
