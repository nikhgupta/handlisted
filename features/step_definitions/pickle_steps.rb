# create a model
Given(/^#{capture_model} exists?(?: with #{capture_fields})?$/) do |name, fields|
  create_model(name, fields)
end

# create n models
Given(/^(\d+) #{capture_plural_factory} exist(?: with #{capture_fields})?$/) do |count, plural_factory, fields|
  create_models(count, plural_factory.singularize, fields)
end

# create models from a table
Given(/^the following #{capture_plural_factory} exists?:?$/) do |plural_factory, table|
  create_models_from_table(plural_factory, table)
end

# delete a model
Given(/^no #{capture_model} exists? with #{capture_fields}$/) do |name, fields|
  find_model(name, fields).try(:destroy)
end

# find a model
Then(/^#{capture_model} should exist(?: with #{capture_fields})?$/) do |name, fields|
  find_model!(name, fields)
end

# not find a model
Then(/^#{capture_model} should not exist(?: with #{capture_fields})?$/) do |name, fields|
  expect(find_model(name, fields)).to be_nil
end

# find models with a table
Then(/^the following #{capture_plural_factory} should exist:?$/) do |plural_factory, table|
  expect(find_models_from_table(plural_factory, table)).not_to be_any(&:nil?)
end

# not find models with a table
Then(/^the following #{capture_plural_factory} should not exists?:?$/) do |plural_factory, table|
  find_models_from_table(plural_factory, table).should be_all(&:nil?)
end

# find exactly n models
Then(/^(\d+) #{capture_plural_factory} should exist(?: with #{capture_fields})?$/) do |count, plural_factory, fields|
  expect(find_models(plural_factory.singularize, fields).size).to eq(count.to_i)
end

# assert equality of models
Then(/^#{capture_model} should be #{capture_model}$/) do |a, b|
  expect(model!(a)).to eq(model!(b))
end

# assert model is in another model's has_many assoc
Then(/^#{capture_model} should be (?:in|one of|amongst) #{capture_model}(?:'s)? (\w+)$/) do |target, owner, association|
  expect(model!(owner).send(association)).to include(model!(target))
end

# assert model is not in another model's has_many assoc
Then(/^#{capture_model} should not be (?:in|one of|amongst) #{capture_model}(?:'s)? (\w+)$/) do |target, owner, association|
  expect(model!(owner).send(association)).not_to include(model!(target))
end

# assert model is another model's has_one/belongs_to assoc
Then(/^#{capture_model} should be #{capture_model}(?:'s)? (\w+)$/) do |target, owner, association|
  expect(model!(owner).send(association)).to eq(model!(target))
end

# assert model is not another model's has_one/belongs_to assoc
Then(/^#{capture_model} should not be #{capture_model}(?:'s)? (\w+)$/) do |target, owner, association|
  expect(model!(owner).send(association)).not_to eq(model!(target))
end

# assert model.predicate?
Then(/^#{capture_model} should (?:be|have) (?:an? )?#{capture_predicate}$/) do |name, predicate|
  if model!(name).respond_to?("has_#{predicate.gsub(' ', '_')}")
    expect(model!(name)).to send("have_#{predicate.gsub(' ', '_')}")
  else
    expect(model!(name)).to send("be_#{predicate.gsub(' ', '_')}")
  end
end

# assert not model.predicate?
Then(/^#{capture_model} should not (?:be|have) (?:an? )?#{capture_predicate}$/) do |name, predicate|
  if model!(name).respond_to?("has_#{predicate.gsub(' ', '_')}")
    expect(model!(name)).not_to send("have_#{predicate.gsub(' ', '_')}")
  else
    expect(model!(name)).not_to send("be_#{predicate.gsub(' ', '_')}")
  end
end

# expect(model.attribute).to eq(value)
# expect(model.attribute).not_to eq(value)
Then(/^#{capture_model}'s (\w+) (should(?: not)?) be #{capture_value}$/) do |name, attribute, expectation, expected|
  actual_value  = model(name).send(attribute)
  expectation   = expectation.gsub("should", "to").gsub(" ", "_")

  case expected
  when 'nil', 'true', 'false'
    expect(actual_value).send(expectation, eq(eval(expected)))
  when /^[+-]?[0-9_]+(\.\d+)?$/
    expect(actual_value).send(expectation, eq(expected.to_f))
  else
    expect(actual_value.to_s).send(expectation, eq(eval(expected)))
  end
end

# assert size of association
Then /^#{capture_model} should have (\d+) (\w+)$/ do |name, size, association|
  expect(model!(name).send(association).size).to eq(size.to_i)
end
