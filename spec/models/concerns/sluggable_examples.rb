require 'rails_helper'

RSpec.shared_examples_for "sluggable" do |options = {}|
  let(:model) { described_class.to_s.underscore.to_sym }
  let(:slug_field){ options[:slug_field] || :name }

  it "generates a slug when missing" do
    instance = create(model, slug_field => "SomeModelName", slug: nil)
    expect(instance.slug).to eq("somemodelname")
  end

  it "auto guesses field names to be used for slug generation" do
    allow(described_class).to receive(:method_defined?) do |arg|
      !%w[name username title display_name].include?(arg.to_s)
    end
    instance = build model
    candidates = instance.send :friendly_id_methods
    expect(candidates).to eq([:full_name, :full_title, :to_s])
  end

  it "moves invalidation errors to appropriate name/title field" do
    instance = build(model, slug_field => "SomeModelName", slug: nil)
    expect(instance).to be_valid

    instance.update_attributes(slug: "")
    expect(instance).not_to be_valid
    expect(instance.errors).not_to have_key(:friendly_id)
    expect(instance.errors[slug_field]).to include("can't be blank")
  end

  it "makes sure generated slugs are unique" do
    instance1 = create(model)
    instance2 = build(model, instance1.attributes.except("id", "slug", "lft", "rgt", "depth"))
    instance2.valid? # triggers slug generation
    expect(instance2.slug).not_to eq(instance1.slug)
  end
end
